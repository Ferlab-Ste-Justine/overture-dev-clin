export KEYCLOAK_CLIENT_SECRET=8c06ee4d-461b-45a9-b50f-1ed176699c1b

(
    cd clin-overture-client;
    docker build -t overture-clin-client:latest .;
)

docker run --rm \
           --network overture \
           -e "ELASTICSEARCH_URL=http://elasticsearch:9200" \
           -e "SONG_URL=http://song-reverse-proxy:8888" \
           -e "KEYCLOAK_URL=https://keycloak:8443" \
           -e "KEYCLOAK_USERNAME=test" \
           -e "KEYCLOAK_PASSWORD=testpassword99" \
           -e "KEYCLOAK_SECRET=$KEYCLOAK_CLIENT_SECRET" \
           -v $(pwd)/clin-overture-schemas/clinReadAlignment_schema.json:/opt/clinReadAlignment_schema.json \
           overture-clin-client:latest \
           bash -c "overturecli keycloak-login && overturecli create-study --id=ET00011 --name=ET00011 --description=ET00011 --organization=ET00011 && overturecli create-analysis-definition --schema-path=/opt/clinReadAlignment_schema.json";
