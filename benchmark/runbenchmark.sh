#!/bin/bash
pushd ./acmeair-monolithic-java/jmeter/
for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 ;
do
wget http://${ACMEAIR_HOST}:9080/rest/info/loader/load?numCustomers=10000
./apache-jmeter-5.5/bin/jmeter -n -t AcmeAir-v5.jmx -DusePureIDs=true -JHOST=${ACMEAIR_HOST} -JPORT=9080 -j ../../performance-${ACMEAIR_HOST}-${i}.log -JTHREAD=1 -JUSER=10 -JDURATION=60 -JRAMP=0 ;
done
popd
