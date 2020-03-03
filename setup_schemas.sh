export KEYCLOAK_CLIENT_SECRET=01729864-1f9f-4d16-b728-2fa87767541c

(
    cd clin-overture-schemas;
    docker build -t clin-overture-schemas:latest .;
)

docker run --rm --network overture \
           -e "KEYCLOAK_URL=https://keycloak:8443" \
           -e "KEYCLOAK_REALM=clin" \
           -e "KEYCLOAK_CLIENT=clin-proxy-api" \
           -e "KEYCLOAK_CLIENT_SECRET=$KEYCLOAK_CLIENT_SECRET" \
           -e "KEYCLOAK_USER=test" \
           -e "KEYCLOAK_USER_PASSWORD=testpassword99" \
           -e "SONG_URL=http://song-reverse-proxy:8888" \
           -w /opt \
           clin-overture-schemas:latest python applyClinReadAlignment.py;