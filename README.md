# Chiselled JRE

The different releases of this chiselled Ubuntu image are maintained via
channel branches (e.g. `channels/8/edge`).

Read more about the repository structure and build automation in [here](<https://github.com/ubuntu-rocks/.github/blob/main/profile/README.md#-joining-the-ubuntu-rocks-project>).


## Image characteristics

This section highlights differences with `eclipse-temurin:8u352-b08-jre-jammy` image (as at the time of writing 8u362 is not yet deployed to Jammy).

### Image size

|Image|Tag|Uncompressed Size| Compressed Size|
|-----|---|----| ----------------------------|
| eclipse-temurin|8u352-b08-jre-jammy|221MB|80M|
| ubuntu/chiselled-jre|8_edge| 123MB|46M |

The major points of difference are:
- /bin and /usr/bin are removed, which occupy 20MB compressed in Temurin
- /var is removed, which occupies 7.7MB due to dpkg
- only minimal set of libraries is present in /usr/lib/x86_64-linux-gnu, saving 39M
- contents of /usr/share are not present (31MB), assuming that for things like local time zone information, it is either mapped into the container, or containers run in GMT.

The JRE differences itself are minimal. Chiselled image removes libawt_xawt.so and libsplashscren.so along with accessibility support.
Note: chiselled docker at the moment removes classes.jsa which affects startup time.

Below are examples of size comparison between


## License

The source code in this project is licensed under the [Apache 2.0 LICENSE](./LICENSE).
**This is not the end-user license for the resulting container image.**
The software pulled at build time and shipped with the resulting image is licensed under a separate [LICENSE](./chiselled-jre/LICENSE).