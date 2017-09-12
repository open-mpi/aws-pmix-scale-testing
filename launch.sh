#!/bin/bash

#Modify config file
makeconfig()
{
    #Add bucket information to end of $line
    source buckets.sh
    
    line="$1 $backend $builds $logs"
    #remove previous run's post_install_args
    sed -i '/^post_install_args/d' config
    #remove previous queue sizes
    sed -i '/^.*_queue_size/d' config
    #add new post_install_args
    echo "$line" >> config
    #add new queue sizes
    #queue size is the number of compute nodes to create
    echo "initial_queue_size=$(echo $line | cut -d' ' -f5)" >> config
    echo "max_queue_size=$(echo $line | cut -d' ' -f5)" >> config
}

#Launch cluster
launch()
{
    #remove --nowait to block when creating a cluster.
    #This can be used as a rudimentary way to prevent
    #too many clusters running at once
    cfncluster --nowait --config config create $cluster_name
}

main()
{
    base_name=$1
    echo $base_name
    # If no cluster name was given, auto generate and print the name
    if [ "$base_name" = "" ]; then
	base_name="test"$(date +%m%d%Y%N)
    fi

    readfile="postinstallargs.cfg"
    count=0
    #Loop over each line in postinstallargs.cfg
    while IFS= read -r line
    do
	#if line is not a comment start a cluster
	if [[ $line != '#'* ]]; then
	    cluster_name=$base_name"_"$((count++))
	    makeconfig "$line"
	    launch
   	    echo $cluster_name
	fi
    done < $readfile
}

main $@ #> out.log &
