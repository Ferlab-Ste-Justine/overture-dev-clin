if [ -z "$KEYCLOAK_CLIENT_SECRET" ]; then
    echo "Keycloak secret is not defined."
fi

if [ -z "$KEYCLOAK_USERNAME" ]; then
    source default_keycloak_login.sh;
fi

#Get full client image name. Version default to value in info.json if not specified
export IMAGE_REPO=$(cd clin-overture-client; cat ./info.json | jq -r ".image_repo")
export INFO_VERSION=$(cd clin-overture-client; cat ./info.json | jq -r ".version")
export VERSION=${OVERTURE_CLIENT_VERSION:-$INFO_VERSION}
export OVERTURE_CLIENT_IMAGE=$IMAGE_REPO:$VERSION

#If version was specified to 'local', build the image locally
if [ "$VERSION" = "local" ]; then
    (cd clin-overture-client; docker build -t $OVERTURE_CLIENT_IMAGE .);
fi

#Define defaults based on implicit local environment values if parameters are not passed
export OVERTURE_NETWORK=${OVERTURE_NETWORK:-overture}
export ELASTICSEARCH_URL=${ELASTICSEARCH_URL:-http://elastic:9200}
export SONG_URL=${SONG_URL:-http://song-reverse-proxy:8888}
export SCORE_URL=${SCORE_URL:-http://score-reverse-proxy:8888} 
export KEYCLOAK_URL=${KEYCLOAK_URL:-https://keycloak:8443}
export MAIN_STUDY=${MAIN_STUDY:-ET00011}
export SCORE_CLIENT_IMAGE=${SCORE_CLIENT_IMAGE:-chusj/overture-score:0.3}
export CONTAINER_NAME=${CONTAINER_NAME:-overture-client}

docker create --rm \
              --network $OVERTURE_NETWORK \
              -e "ELASTICSEARCH_URL=$ELASTICSEARCH_URL" \
              -e "SONG_URL=$SONG_URL" \
              -e "KEYCLOAK_URL=$KEYCLOAK_URL" \
              -e "KEYCLOAK_USERNAME=$KEYCLOAK_USERNAME" \
              -e "KEYCLOAK_PASSWORD=$KEYCLOAK_PASSWORD" \
              -e "KEYCLOAK_SECRET=$KEYCLOAK_CLIENT_SECRET" \
              -e "SCORE_CLIENT_IMAGE=$SCORE_CLIENT_IMAGE" \
              -e "CONTAINER_NAME=$CONTAINER_NAME" \
              -e "OVERTURE_NETWORK=$OVERTURE_NETWORK" \
              -v $(pwd)/clin-overture-schemas/clinReadAlignment_schema.json:/opt/clinReadAlignment_schema.json \
              --name song-setup \
              $OVERTURE_CLIENT_IMAGE \
              bash -c "overturecli keycloak-login && overturecli create-study --id=$MAIN_STUDY --name=$MAIN_STUDY --description=$MAIN_STUDY --organization=$MAIN_STUDY && overturecli create-analysis-definition --schema-path=/opt/clinReadAlignment_schema.json";
docker network connect proxy song-setup;
docker start song-setup;