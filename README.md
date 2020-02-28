# About

This repo contains the dependencies to run the overture stack whose implementation details are dependent on the clin project.

But isolating those dependencies in a separate repo, we can duplicate the project-specific parts across projects while keeping the Overture core the same no matter the project.

# Components

This repo contains the following components so far:
- An elasticsearch database (and accompanying Kibana dashboard) that should have the same structure as clin
- An transient Aidbox system to migrate dummy spreadsheet data to ndjson documents
- A transient etl to migrate ndjson documents to the elasticsearch database
- A SONG-compatible id service to map submitter ids to system ids using the elasticsearch database

# Usage

1. Put your aidbox license credentials in fhir-import/aidbox/.env
2. Run the entire migration of dummy data from the spreadsheet to the elasticsearch database: **./setup.sh**
3. Run the following to lauch the id service and kibana: **docker-compose up -d**

The id service is on port **8787** and Kibada on port **5601**. The index is named **patient**.