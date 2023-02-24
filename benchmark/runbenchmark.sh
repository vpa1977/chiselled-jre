#!/bin/bash

pushd ./acmeair-monolithic-java/jmeter/

./apache-jmeter-5.5/bin/jmeter -n -t AcmeAir-v5.jmx -DusePureIDs=true -JHOST=localhost -JPORT=9080 -j performance.log -JTHREAD=1 -JUSER=9999 -JDURATION=120 -JRAMP=60 ;

popd