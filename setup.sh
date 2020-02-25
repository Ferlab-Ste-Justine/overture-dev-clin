if [ ! -d clin-etl-FHIR/ndjson ]; then
    #Import spreadsheet dummy data in a Fhir database
    (
        cd fhir-import;
        cd aidbox; 
        docker-compose up -d;
        sleep 20;
        cd ..;
        docker build -t fhir-import:latest .;
        docker run --rm --network aidbox -e "AIDBOX_URL=http://devbox:8888" -e "AIDBOX_AUTH_TOKEN=cm9vdDpzZWNyZXQ=" fhir-import:latest /bin/bash -c "/opt/upsert.sh";
    )

    #Dump content of Fhir database in ndjson files
    (
        export FHIR_CREDENTIAL="root:secret"
        cd clin-etl-FHIR;
        ./download.sh;
    )

    #Shutdown Fhir database
    (
        cd fhir-import/aidbox;
        docker-compose down -v;
    )

fi

#Launch elasticsearch database
docker-compose up -d elasticsearch;

#Upload ndjson files in elasticsearch database
(
    cd clin-etl-FHIR;
    docker run -ti --rm -v $(pwd):/app/clin-etl \
    -v ~/.m2:/root/.m2 \
    -v ~/.ivy2:/root/.ivy2 \
    -v ~/.sbt:/root/.sbt \
    -w /app/clin-etl hseeberger/scala-sbt:8u181_2.12.8_1.2.8 \
    sbt clean assembly;
    docker build -t clin-etl-fhir:latest .;
    docker run --rm --network container:clin-elasticsearch -v "$(pwd)/ndjson:/ndjson" -e "es.nodes=clin-elasticsearch" -e "es.port=9200" clin-etl-fhir:latest;
)