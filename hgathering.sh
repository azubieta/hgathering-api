#! /bin/bash

# Management script for hgathering service.

## Environment variables with sensible defaults

PORT=${PORT:-"3000"}

NODE_TAG=${NODE_TAG:-"8.5-alpine"}
MONGO_TAG=${MONGO_TAG:-"3.4"}
REDIS_TAG=${REDIS_TAG:-"3.2-alpine"}

MONGO_CONT=${MONGO_CONT:-"mongo-$MONGO_TAG"}
MONGO_HOST=${MONGO_HOST:-"localhost"}
MONGO_LINKED=${MONGO_LINKED:-"linked-mongo"}

REDIS_CONT=${REDIS_CONT:-"redis-$REDIS_TAG"}

## Service functions

function start_interactive_service {
    echo "When service image is ready, launch with -it option"
    exit 1
}

function start_detached_service {
    echo "When service image is ready, launch with -d option"
    exit 1
}

function start_service_on_the_fly {
    start_mongo_container
    docker run --rm -it \
        --name hgathering-dev \
        -v $(pwd):/app \
        -p $PORT:$PORT \
        --link $MONGO_CONT:$MONGO_LINKED \
        -e MONGO_HOST=$MONGO_LINKED \
        -e MONGO_PORT=27017 \
        node:$NODE_TAG \
        sh -c "node /app"
}

function fetch_dependencies {
    docker run --rm -it \
        --name hgathering-fetch-deps \
        -v $(pwd):/app \
        node:$NODE_TAG \
        sh -c "cd /app; npm install"
}

function build_service_image {
    echo "When service Dockerfile is ready, build it here"
    exit 1
}

function clear_node_modules {
    docker run --rm -it \
        --name hgathering-clear \
        -v $(pwd):/app \
        node:$NODE_TAG \
        sh -c "cd /app; rm -rf node_modules"
}

## Mongo functions

## TODO Factor out mongo port to env var

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

## Redis functions

## TODO Factor out redis port to env var

function run_redis_container {
    docker run --name $REDIS_CONT -d -p 6379:6379 redis:$REDIS_TAG
}

function start_redis_container {
    docker start $REDIS_CONT
}

function remove_redis_container {
    docker rm -f $REDIS_CONT
}

## Help functions

function show_help {
    local help="\
$(basename $0) <comando> [<arg1>]

Donde <comando> es una de las siguientes opciones:

    dev           - Inicia el servicio desde un contenedor efimero basado en node:$NODE_TAG.
    start         - Inicializa la imagen del servicio en modo interactivo.
    startd        - Inicializa la imagen del servicio en modo 'detached'.
    deps          - Usa docker para descargar todas las dependencias en node_modules.
    build         - Construye la imagen de docker para liberar a producción.
    clear         - Elimina node_modules (fetch-deps descarga dependencias como el usuario
                    de dockerd)
    mongo-fresh   - Crea un nuevo contenedor basado en la imagen de mongo:3.4.
    mongo-start   - Inicia el contenedor de mongo ya existente.
    mongo-rmf     - Elimina el contenedor de mongo existente.
    mongo-restore - Restaura el dump de una bd en la instancia local de mongo. Aquí se
                    utiliza <arg1> como el directorio en donde se encuentran los
                    archivos del dump.
    redis-fresh   - Crea un nuevo contenedor basado en la imagen de redis:3.4-alpine.
    redis-start   - Inicia el contenedor de redis ya existente.
    redis-rmf     - Elimina el contenedor de redis existente.

Ayuda a México contribuyendo a este u otros proyectos relacionados:
https://github.com/azubieta/hgathering-api"
    echo "$help"
}

case "$1" in
    # Service commands
    start)
        start_interactive_service
        ;;
    startd)
        start_detached_service
        ;;
    dev)
        start_service_on_the_fly
        ;;
    deps)
        fetch_dependencies
        ;;
    build)
        build_service_image
        ;;
    clear)
        clear_node_modules
        ;;
    # Mongo commands
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
    # Redis commands
    redis-fresh)
        run_redis_container
        ;;
    redis-start)
        start_redis_container
        ;;
    redis-rmf)
        remove_redis_container
        ;;
    # Help
    *)
        show_help $0
        ;;
esac
