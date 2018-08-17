export DOCKER_HOST="tcp://127.0.0.1:2375"

CONTAINER=$(docker run --rm -d -v "$WORKSPACE:/build:rw" ansible-ubuntu /bin/bash -c 'cd /build && bash ./test.sh <directory name>')

echo "CONTAINER: $CONTAINER"
docker attach $CONTAINER

RC=$(docker wait $CONTAINER)
echo "RC: $RC"

#docker rm $CONTAINER
exit $RC
