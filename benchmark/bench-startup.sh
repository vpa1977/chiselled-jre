#!/bin/bash
# run ./bench-startup 192.168.20.14 acmeair-standalone-chisel
./startup.sh $1 $2 | grep "JVM running" | awk '{print $18}' | sed 's/)//g'

