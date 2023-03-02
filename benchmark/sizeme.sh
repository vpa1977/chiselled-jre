#!/bin/bash

docker create --name $1 $1
docker export $1 > /tmp/unzipped-$1.tar
ls -lh /tmp/unzipped-$1.tar
gzip /tmp/unzipped-$1.tar
ls -lh /tmp/unzipped-$1.tar.gz
rm /tmp/unzipped-$1.tar.gz
docker rm $1
