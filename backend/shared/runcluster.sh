#!/bin/bash

runnum=${runnum}
computecores=${ncores}
computenum=${nnodes}
#multiple runs to filter out noise
for rep in $(seq 1 5); do
    #vary number of nodes from 1 to max
    for numnodes in $(seq 1 $computenum); do
	#vary number of procs per node from 1 to max
	for ppn in $(seq  1 $computecores); do
	    ntasks=$(($ppn*$numnodes))
	    set -x
	    ppn=$ppn runnum=$runnum rep=$rep sbatch -N $numnodes -n $ntasks /shared/memtest.sh
	    set +x
	done
    done
done

#Create shutdown cron after new jobs have been submitted
echo "creating crontab"
echo "runnum=$runnum" > /shared/cronvars
crontab /shared/crontab.txt
echo "done"
