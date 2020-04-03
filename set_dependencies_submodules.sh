repos=( overture-dev devops clin-overture-client )
for repo in "${repos[@]}"
do
	(
        cd $repo;
        git submodule init;
        git submodule sync;
        git submodule update;
    )
done