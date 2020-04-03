SWARM=$(docker node ls -q 2>&1 >/dev/null)
if [[ $SWARM = Error* ]]; then
    echo "Docker must be running in swarm mode to execute this script";
    exit 1;
fi

#figure out the kind of environment and corresponding docker-compose files
export ENV=${ENV:-dev}

if [ "$ENV" = "dev" ]; then
    export DOCKER_COMPOSE_FILE="docker-compose.yml";
else
    export DOCKER_COMPOSE_FILE="dc-prodlike.yml";
fi

#Launch services
if [ "$ENV" = "dev" ]; then
    ./build-local-images.sh;
    docker stack deploy --resolve-image never -c $DOCKER_COMPOSE_FILE overture-clin
else
    docker stack deploy -c $DOCKER_COMPOSE_FILE overture-clin
fi