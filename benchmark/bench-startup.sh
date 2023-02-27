#!/bin/bash
./startup.sh > $1-raw.txt
grep "JVM running" $1-raw.txt > $1-running.txt
awk '{print $18}' $1-running.txt > $1-list.txt
