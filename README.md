# About

This repo contains the dependencies to run the overture stack whose implementation details are dependent on the clin project.

By isolating those dependencies in a separate repo, we can duplicate the project-specific parts across projects while keeping the Overture core the same no matter the project.

# Components

This repo contains the following components so far:
- Pointers to all dependencies to run the project in the clin environment (needed for local development) and a script (**launch_dependencies.sh**) to launch them
- A script (**setup_song_structures.sh**) to setup the song structures (study and analysis schema) that clin depends on
- An id-service for SONG, setup to get the right ids from clin's elasticsearch database
- A client to perform analysis batch upload jobs

# Usage

## Repo setup

After first cloning the repo, you will need to also clone the submodule hiearchy of the repo and its subrepos.

You can simply run the **set_submodules.sh** script.

## Launch Dependencies

You can launch all dependencies of the repo by running the **launch_dependencies.sh** script.

## Run the id service

You can launch the id-service by running the **launch-services.sh** script.

If you want to run a prodlike version using the image on docker hub, set the following variable before running the script:

```
export ENV=prodlike
```

You can teardown the service by running the **teardown-services.sh** script.

## Running the client to test batch upload

You can run the client with a workspace setup using the client repo's example, by typing:

```
cd clin-overture-client
./run_shell.sh
```