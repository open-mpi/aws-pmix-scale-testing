#!/bin/bash

#allow user to select which run to graph
choose_run()
{
    metadata="$(bash ../query_db.sh "SELECT * FROM metadata" "-B")"
    header=$(echo "$metadata" | head -n 1)
    echo "$metadata" | tail -n +2 | fzf --tac --prompt "Select run to graph >" --header "$header" --height 40% | awk '{print $1}'
}

#allow user to choose which graphs to make
choose_graphs()
{
    local graph

    #get all inf files in an array
    options=(graphs/*.inf)

    #prompt user for input
    echo "Select graphs to create, separate with spaces"

    #for each inf print the name and description
    for num in ${!options[@]}; do
	source ${options[num]}
	echo $num $name - $desc
    done

    #read user input and return array of graphs to make
    read -a graph_nums
    for graph in graph_nums; do
	graphs+=${options[$graph]}
    done
}


main()
{
    #list options for run
    run=$(choose_run)
    #create directory
    if [ ! -d $run ]; then
	mkdir $run
    fi
    #list options for graphing
    choose_graphs
    echo ${graphs[@]}
    for graph in ${graphs[@]}; do
	#get metadata
	branch=$(bash ../query_db.sh "SELECT branch FROM metadata WHERE runnum=$run" "-NB")
	hash=$(bash ../query_db.sh "SELECT hash FROM metadata WHERE runnum=$run" "-NB")
	source $graph
	#get data from db
	$(bash ../query_db.sh "$(cat graphs/$name.sql)" > $run/$name.raw)
	#write graph
	gnuplot -e "plottitle='$title'" -e "datapoints='$run/$name.raw'" -e "out='$run/$name.pdf'" plot.gnu
    done

}

#entry point
main
