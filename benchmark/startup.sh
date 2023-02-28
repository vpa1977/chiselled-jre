MONGO_HOST=$1

docker run -d -p 27017:27017 --name mongo mongo
for x in 1 2 3 4 5 6 7 8 9 10 11 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33
do
docker run --env MONGO_HOST=$MONGO_HOST --tmpfs /tmp --name test $2&
sleep 5
docker kill test
docker rm test
done
docker kill mongo
docker rm mongo