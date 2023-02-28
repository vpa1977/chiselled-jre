# Chiselled JRE

The different releases of this chiselled Ubuntu image are maintained via
channel branches (e.g. `channels/8/edge`).

Read more about the repository structure and build automation [here](<https://github.com/ubuntu-rocks/.github/blob/main/profile/README.md#-joining-the-ubuntu-rocks-project>).


## Image Characteristics

According to JetBrains' 2022 [Java Developer Ecosystem](https://www.jetbrains.com/lp/devecosystem-2022/java/) survey, 60% of the developers still regularly used Java 8, 59% developed applications for Apache Tomcat and 67% used Spring Boot as an alternative to an application server.

New Relic 2022 [Java Ecosystem report](https://newrelic.com/resources/report/2022-state-of-java-ecosystem) listed the following top JDK vendors:
 - Oracle Corporation 34.48%
 - Amazon 22.04%
 - Eclipse Adoptium 11.48%
 - Azul Zulu build of OpenJDK 16%

Snyk 2021 [JVM Ecosystem](https://snyk.io/jvm-ecosystem-report-2021/) had the following breakdown:
 - Eclipse Adoptium 44%
 - Oracle Corporation OpenJDK 28%
 - Oracle Corporation JDK 23%
 - Azul Zulu build of OpenJDK 16%
 - Amazon Coretto 8%

The differences in vendor distribution could be attributed to the audience providing survey responses.

The chiselled JRE container is built based on the Ubuntu 22.04 version of Java 8 runtime - `8u362-ga`.

This section provides a comparison with readily-available JRE 8 images for Ubuntu 22.04:
 - Eclipse Adoptium: `eclipse-temurin:8u362-b09-jre-jammy`
 - Amazon: `amazoncorretto:8u362-alpine3.14-jre`

Azul Zulu does not provide a JRE image: https://hub.docker.com/r/azul/zulu-openjdk and it was not evaluated.
Oracle does not provide an official image of the Java Runtime Environment 8 and it was not evaluated.

### Image size

|Image|Tag|Uncompressed Size| Compressed Size| % Compressed |
|-----|---|----| ----------------------------| -------------|
| eclipse-temurin|8u362-b09-jre-jammy|221MB|80M| 100% |
| amazoncorretto| 8u362-alpine3.14-jre| 110MB | 41M| 51.3% |
| ubuntu/chiselled-jre|8-22.04_edge| 118MB |44M | 55% |

The points of difference with the Temurin image are:
- `/bin` and `/usr/bin` are removed, which occupy 20MB (compressed) in Temurin
- `/var` is removed, which occupies 7.7MB due to `dpkg`
- only a minimal set of libraries is present in /usr/lib/x86_64-linux-gnu, saving 39M
- contents of /usr/share are not present (31MB), meaning that container always assumes GMT timezone.
- `glib` libraries imported by the URL proxy selector are absent. `java.net.ProxySelector.getDefault()` call will always return `Direct Proxy`.

The points of difference with the Amazon Corretto image are:
 - Corretto deploys busybox as a shell
 - Corretto does not have fontconfig/fonts libraries. This causes `java.awt.Font.createFont()` to fail with `java.lang.UnsatisfiedLinkError`.

The JRE differences themselves are minimal. The chiselled image removes `libawt_xawt.so` and `libsplashscren.so` along with accessibility support. Only 'java' executable is left in `jre/bin`.
Note: chiselled images, at the moment, do not provide classes.jsa (Class Data Cache) in line with Temurin JRE.

Below are image sizes of the deployed `acmeair` benchmark application
#### `acmeair` as a standalone Spring Boot application
|Base Image|Uncompressed Size| Compressed Size| % Compressed |
|---|----| ----------------------------|----|
| eclipse-temurin:8u362-b08-jre-jammy | 244MB | 99MB |  100% |
| ubuntu/chiselled-jre:8_edge | 146MB | 65MB| 65.6% |
| amazoncorretto:8u362-alpine3.14-jre | 133MB | 61MB| 61.6% |

#### `acmeair` deployed to Apache Tomcat
|Base Image|Uncompressed Size| Compressed Size| % Compressed |
|---|----| ----------------------------|----------|
| 10.0.27-jre8-temurin-jammy | 258MB | 108MB | 100% |
| ubuntu/chiselled-jre:8_edge | 159MB | 74M | 68.5% |
| amazoncorretto:8u362-alpine3.14-jre | 151MB | 71M | 65.7% |

#### `acmeair` deployed to WebSphere Liberty
|Base Image|Uncompressed Size| Compressed Size|% Compressed |
|---|----| ----------------------------|---|
| websphere-liberty:23.0.0.1-full-java8-ibmjava| 772MB| 507MB| 100% |
| ubuntu/chiselled-jre:8-22.04_edge | 626MB | 405MB | 79.9% |
| amazoncorretto:8u362-alpine3.14-jre | 618MB | 402MB | 79.2% |

### Test Environment

The tests were performed using amd64 m1.medium canonistack instance (2 vCPUs, 4096MB RAM, 10GB disk).

### Startup time

The startup times were evaluated by starting a Spring Boot standalone container repeatedly and measuring the total JVM time until the start of the application as per Spring Boot logs, taking an average of 60 runs.

The table below shows startup times:
|Image| Minimum (seconds) | Average (seconds) | Maximum (seconds) | Standard Deviation|
|-----|-------------------|-------------------|-------------------|-------------------|
| chiselled-jre | 3.18 | 3.59 | 4.126 | 0.19|
| chiselled-jre with Class Data Caching | 3.08 | 3.48 | 4.02 | 0.19|
| Temurin | 3.26 | 3.67 | 4.01 | 0.19 |
| Temurin with Class Data Caching| 3.20 | 3.54 | 4.26 | 0.19 |
| Coretto | 3.75 | 4.03 | 4.48 | 0.19 |
| Coretto with Class Data Caching| 3.60 | 3.97 | 4.37 | 0.21 |

Adding CDS (Class Data Sharing) to `acmeair` allows a 5% startup improvement at expense of a 6MB compressed (and 20MB uncompressed) image size increase.

There is no significant difference between Ubuntu 22.04 chiselled and Temurin images, Alpine-based Amazon Corretto shows slowest startup time and biggest variance.

### Throughput tests

The throughput tests were performed using Apache JMeter 5.5 on the `acmeair` application with the following command: ``../apache-jmeter-5.5/bin/jmeter -n -t AcmeAir-v5.jmx -DusePureIDs=true -JHOST=(cloud host ip) -JPORT=9080 -j performance.log -JTHREAD=1 -JUSER=10 -JDURATION=600 -JRAMP=60 ;`` The load was driven from the second cloud m2.medium instance.

The table below shows the average requests per second:

| WebSphere Liberty | WebSphere Liberty (chiselled) | Apache Tomcat | Apache Tomcat (chiselled) | Standalone (Temurin) | Standalone (chiselled) |  Standalone (corretto) |
|-------------------|-------------------------------|---------------|-------------|---------|--------| ---|
| 1553.7 | 1704.5 | 1687.7 | 1733.2 | 1778 | 1773.6 | 1798 |

This test shows no significant differences in performance for OpenJDK-based tests.

### Conclusion

The chiselled JRE image of OpenJDK 8 provides a 42.5% reduction in the size of the compressed image compared to Temurin and is 7% larger than the Amazon Corretto image.
The chiselled JRE image does not degrade throughput or startup performance.

## License

The source code in this project is licensed under the [Apache 2.0 LICENSE](./LICENSE).
**This is not the end-user license for the resulting container image.**
The software pulled at build time and shipped with the resulting image is licensed under a separate [LICENSE](./chiselled-jre/LICENSE).