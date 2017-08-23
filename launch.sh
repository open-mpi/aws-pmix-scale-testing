#!/bin/bash

#Modify config file
makeconfig()
{
    line=$1
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
    cfncluster --nowait --config config create test$(date +%m%d%Y%N)
}

main()
{
    readfile="postinstallargs.cfg"
    #Loop over each line in postinstallargs.cfg
    while IFS= read -r line
    do
	#if line is not a comment start a cluster
	if [[ $line != '#'* ]]; then
	    makeconfig "$line"
	    launch
	fi
    done < $readfile
}

main #> out.log &
