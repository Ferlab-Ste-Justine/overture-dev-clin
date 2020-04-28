# About

This repo contains the dependencies to run the overture stack whose implementation details are dependent on the clin project.

By isolating those dependencies in a separate repo, we can duplicate the project-specific parts across projects while keeping the Overture core the same no matter the project.

# Overview

This repo contains the following components so far:
- Pointers to all dependencies to run the project in the clin environment (needed for local development) and a script (**launch_dependencies.sh**) to launch them
- A script (**setup_song_structures.sh**) to setup the song structures (study and analysis schema) that clin depends on
- An id-service for SONG, setup to get the right ids from clin's elasticsearch database
- A metadata service for SONG, leveraging the elasticsearch database of clin, to bridge the gap between payloads the client sends and what SONGs expect
- A client to perform analysis batch upload jobs

## Components

### Services

- Overture client: https://github.com/cr-ste-justine/clin-overture-client/tree/master
- Overture Id Service: https://github.com/cr-ste-justine/overture-id-service/tree/master
- Overture Metadata Service: https://github.com/cr-ste-justine/song-metadata-resolver/tree/master
- SONG: https://github.com/cr-ste-justine/SONG
- SONG Reverse Proxy: https://github.com/cr-ste-justine/song-auth
- Score: https://github.com/cr-ste-justine/score
- Score Reverse Proxy: https://github.com/cr-ste-justine/score-auth
- Overture external proxy: To be implemented, it will be an existing reverse-proxy solution with a configuration file to add a header
- Keycloak: https://github.com/cr-ste-justine/devops/tree/dev/Keycloak
- ElasticSearch: https://github.com/cr-ste-justine/devops/tree/dev/ES
- An Object Store (Minio currently): https://github.com/cr-ste-justine/overture-dev/blob/32448bf1e2fbab53af52871dd7d0a21a4a18bae4/docker-compose.yml#L48

See the **Schemas/Overview.pdf** file for an overview of how the services talk to each other. Also note that the network segmentation can be achieved in production via actual networks or access policies.

### Workflow

- Clin's Aidbox and Elasticsearch data migration: https://github.com/cr-ste-justine/devops/tree/dev/clin-workflows/fhir-import
- Clin's study and analysis schema setup in SONG: https://github.com/cr-ste-justine/overture-dev-clin/blob/master/setup_song_structures.sh

## Core Workflow

### Jobs When the System Boots the First Time

- The system has to run the migration to populate clin's elasticsearch database with the aidbox data. The elasticsearch will have to be kept in sync after that once aidbox changes, but this is beyond the scope of this documentation.
- The system will have to call the script to setup the clin's study and analysis schema

### Steps to Allow Operator to Upload Files Once System is Running 

Note that the human operation is done once. The other operations (analysis creation, file uploads and analysis publication) is repeated for each analysis.

#### Human Interaction

- The human operator creates a metadata file combined with genomic files to submit to the overture stack
- The human operator logins to keycloak using the **overture client**
- The human operator calls the **overture client** to upload the files in the system

#### Analysis Creation

- The **Overture Client** reads the metadata file, populate the uploaded file entries with metadata from the files (size, md5checksum, etc) and sends an analysis submission payload to **SONG**
- The **Overture External Proxy** marks the request as external and forwards the request to the **SONG Reverse Proxy**
- The **SONG Reverse Proxy** ensures the auth token is valid and that the caller has the right privileges to create an analysis.
- The **SONG Reverse Proxy** will resolve missing sample metadata by calling the **Overture Metadata Service**
- The **Overture Metadata Service** will get the sample metadata from **Elasticsearch** and send it to the **SONG Reverse Proxy**
- The **SONG Reverse Proxy** will forward the request to **SONG**
- **SONG** will map the submitter ids in the request to system ids by calling the **Overture Id Service**
- The **Overture Id Service** will get the system ids from **Elasticsearch** and send them back to **SONG**
- **SONG** will create an unpublished analysis and will send the reply back to the **SONG Reverse Proxy** who will send it to the **Overture External Proxy** who will send it to the **Overture Client**
- The **Overture Client** records that the analysis has been created. This operation will not be repeated on successive attempts if there is a failure.

#### Files Manifest Generation

- The **Overture Client** makes a request get have the files manifest from **SONG**
- The **Overture External Proxy** marks the request as external and forwards the request to the **SONG Reverse Proxy**
- The **SONG Reverse Proxy** ensures the auth token is valid and that the caller has the right privileges to get the files manifest for the analysis.
- The **SONG Reverse Proxy** forwards the request to SONG
- **SONG** gets the analysis files manifest and sends it back to the **SONG Reverse Proxy** who will send it to the **Overture External Proxy** who will send it to the **Overture Client**
- The **Overture Client** Creates the files manifest

#### Files Upload

For each file in the manifest:
- The **Overture Client** (calling the blackbox **Score Client** underneat the hood) will call to **Score** to get a valid url to upload a file.
- The **Overture External Proxy** marks the request as external and forwards the request to the **Score Reverse Proxy**
- The **Score Reverse Proxy** ensures the auth token is valid and that the caller has the right privileges to upload a file
- The **Score Reverse Proxy** forwards the request to **Score**
- Score sends an url to upload the file in the **Object Store** back to the **Score Reverse Proxy** who will send it to the **Overture External Proxy** who will send it to the **Overture Client**
- The **Overture Client** (again calling the blackbox **Score Client** underneat the hood) will use the url to upload the file in the **Object Store**
Finally:
- The **Overture Client** records that the files have been uploaded. This operation will not be repeated on successive attempts if there is a failure.

#### Analysis Publication

- The **Overture Client** makes a request to publish the analysis to **SONG**
- The **Overture External Proxy** marks the request as external and forwards the request to the **SONG Reverse Proxy**
- The **SONG Reverse Proxy** ensures the auth token is valid and that the caller has the right privileges to publish the analysis.
- The **SONG Reverse Proxy** forwards the request to SONG
- **SONG** publishes the analysis and sends the result back to the **SONG Reverse Proxy** who will send it to the **Overture External Proxy** who will send it to the **Overture Client**
- The **Overture Client** records that the analysis has been published. This operation will not be repeated on successive attempts if there is a failure.

# Usage

## Repo setup

After first cloning the repo, you will need to also clone the submodule hiearchy of the repo and its subrepos.

You can simply run the **set_submodules.sh** script.

## Launch Dependencies

You can launch all dependencies of the repo by running the **launch_dependencies.sh** script.

This will launch:

- SONG (and its dependencies)
- SONG Reverse Proxy
- Score (and its dependencies)
- Score Reverse Proxy
- Keycloak
- ElasticSearch

It will also run the following workflows to setup the environment:
- The migration to setup the clin Elastic from the Dummy Data
- The Setup of the SONG structures (study and analysis schema) for Clin

## Run the Clin Overture Services

You can launch the following clin-specific overture services by running the **launch-services.sh** script:
- The id service
- The metadata service
- The external reverse proxy

If you want to run a prodlike version using the images on docker hub, set the following variable before running the script:

```
export ENV=prodlike
```

You can teardown the services by running the **teardown-services.sh** script.

## Running the client to test batch upload

You can run the client with a workspace setup using the client repo's example, by typing:

```
cd clin-overture-client
./run_shell.sh
```