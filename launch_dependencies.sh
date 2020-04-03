KEYCLOAK_UP=$(docker stack ls | grep keycloak)
if [ -z "$KEYCLOAK_UP" ]; then
    source default_keycloak_login.sh;
    (
        cd devops/Keycloak;
        ./launchLocal.sh;
    )
    echo "Launched Keycloak. You will need to create a '$KEYCLOAK_USERNAME' user with a password of '$KEYCLOAK_PASSWORD'. You will also need to assign him the role of 'clin_administrator'";
fi

AIDBOX_UP=$(docker stack ls | grep aidbox)
if [ -z "$AIDBOX_UP" ]; then
    (
        cd devops/aidbox;
        ./launch.sh
    )
    sleep 20;
    (
        cd devops/clin-workflows;
        ./update_aidbox.sh
    )
fi

ELASTICSEARCH_UP=$(docker stack ls | grep elasticsearch)
if [ -z "$ELASTICSEARCH_UP" ]; then
    (
        cd devops/ES;
        ./launchLocal.sh
    )
    sleep 20;
    (
        cd devops/clin-workflows;
        ./update_elasticsearch.sh;
    )
fi

OVERTURE_CORE_UP=$(docker stack ls | grep overture-core)
if [ -z "$OVERTURE_CORE_UP" ]; then
    export KEYCLOAK_CLIENT_SECRET=${KEYCLOAK_CLIENT_SECRET-01b99f28-1331-4fec-903b-c2e8043cec77}
    (
        cd overture-dev;
        ./launch-services.sh;
    )
    sleep 20;
    KEYCLOAK_CLIENT_SECRET=$KEYCLOAK_CLIENT_SECRET ./setup_song_structures.sh;
fi