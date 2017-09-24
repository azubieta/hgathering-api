#! /bin/bash

MONGO_CONT=${MONGO_CONT:-"mongo-3.4"}
MONGO_TAG=${MONGO_TAG:-"3.4"}

case "$1" in
    mongo-fresh)
        docker run --name $MONGO_CONT -d -p 27017:27017 mongo:$MONGO_TAG
        ;;
    mongo-start)
        docker start $MONGO_CONT
        ;;
    mongo-rmf)
        docker rm -f $MONGO_CONT
        ;;
    start)
        npm start
        ;;
    *)
        echo "Usage: $0 {mongo-fresh|mongo-start|mongo-rmf|start}"
        ;;
esac
