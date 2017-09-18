#!/bin/bash

# Get needed cluster information from AWS only once
get_cluster_info()
{
    #The info gathered here is the name and head node ip of each stack
    info=$(aws cloudformation describe-stacks --no-paginate\
	       --query "Stacks[*].{Name:StackName,IP:Outputs[0].OutputValue}")
}

# List clusters you can connect to and get user's choice
list_clusters()
{
    selection=-1
    # Loop until user inputs a valid cluster
    while [ $selection -lt 0 ]; do
	  echo "Enter the number of the cluster to connect to:"
	  # names is an array of the name of each cluster
	  names=($(echo $info | jq -r .[].Name))
	  # Print the name and number of each possible cluster
	  for num in ${!names[@]}; do
	      echo $num ${names[num]}
	  done

	  # Read in chosen cluster and validate it
	  read -a selection
	  if [ $selection -ge ${#names[@]} ]; then
		 selection=-1
	  fi
    done
}

# ssh into selected cluster
connect()
{
    # Get the IP of the selected cluster
    addr=$(echo $info | jq -r .[$selection].IP)
    if [ "$addr" = "null" ]; then
	echo "Cluster head node does not have a public IP yet, wait a few minutes then try again"
	exit 1
    fi
    ssh -i $keyfile ec2-user@$addr
}

main()
{
    # Check if correct number of arguments are supplied
    if [ $# -eq 0 ]; then
	echo "Usage:   ./connect.sh <path-to-keyfile>"
	exit 1
    fi
    # Path to private key
    keyfile=$1
    get_cluster_info
    list_clusters
    connect
}

main $@
