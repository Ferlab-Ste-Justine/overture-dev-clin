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