#!/bin/bash
./startup.sh $1 $2 | grep "JVM running" | awk '{print $18}' | sed 's/)//g'

