#! /bin/bash

PORT=${PORT:-"3000"}

NODE_TAG=${NODE_TAG:-"8.5-alpine"}
MONGO_CONT=${MONGO_CONT:-"mongo-3.4"}
MONGO_TAG=${MONGO_TAG:-"3.4"}
MONGO_LINKED=${MONGO_LINKED:-"linked-mongo"}
REDIS_CONT=${REDIS_CONT:-"redis-3.2-alpine"}
REDIS_TAG=${REDIS_TAG:-"3.2-alpine"}

function show_help {
    local help="\
$0 <comando>

Donde <comando> es una de las siguientes opciones:

    start         - Inicia el servicio con npm start
    app-develop   - Inicia el servicio desde un contenedor efimero de node:8.5-alpine.
    mongo-fresh   - Crea un nuevo contenedor basado en la imagen de mongo:3.4.
    mongo-start   - Inicia el contenedor de mongo ya existente.
    mongo-rmf     - Elimina el contenedor de mongo existente.
    mongo-restore - Restaura el dump de una bd en la instancia local de mongo. Aquí se utiliza <arg1> como el directorio en donde se encuentran los archivos del dump.
    redis-fresh   - Crea un nuevo contenedor basado en la imagen de redis:3.4-alpine.
    redis-start   - Inicia el contenedor de redis ya existente.
    redis-rmf     - Elimina el contenedor de redis existente."
    echo "$help"
}

function start_app_with_docker {
    start_mongo_container
    docker run --rm -it \
        -v $(pwd):/app \
        -p $PORT:$PORT \
        --link $MONGO_CONT:$MONGO_LINKED \
        -e MONGO_HOST=$MONGO_LINKED \
        -e MONGO_PORT=27017 \
        node:$NODE_TAG \
        sh -c "cd /app; npm install; node ."
}

function run_mongo_container {
    docker run --name $MONGO_CONT -d -p 27017:27017 mongo:$MONGO_TAG
}

function start_mongo_container {
    docker start $MONGO_CONT
}

function remove_mongo_container {
    docker rm -f $MONGO_CONT
}

function restore_mongo_data {
    mongorestore --host=localhost --db=help_mx $1
}

function run_redis_container {
    docker run --name $REDIS_CONT -d -p 6379:6379 redis:$REDIS_TAG
}

function start_redis_container {
    docker start $REDIS_CONT
}

function remove_redis_container {
    docker rm -f $REDIS_CONT
}

case "$1" in
    start)
        start_app_with_docker
        ;;
    mongo-fresh)
        run_mongo_container
        ;;
    mongo-start)
        start_mongo_container
        ;;
    mongo-rmf)
        remove_mongo_container
        ;;
    mongo-restore)
        restore_mongo_data $1
        ;;
    redis-fresh)
        run_redis_container
        ;;
    redis-start)
        start_redis_container
        ;;
    redis-rmf)
        remove_redis_container
        ;;
    *)
        show_help $0
        ;;
esac
