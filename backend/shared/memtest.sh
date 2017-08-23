#!/bin/bash
#gather information from environment variables/slurm/ompi_info
runnum=${runnum}
rep=${rep}
ppn=${ppn}
x=${SLURM_NTASKS}
nnodes=${SLURM_NNODES}
nodes=$(scontrol show hostname ${SLURM_JOB_NODELIST})

ompi_version=$(echo $(/opt/openmpi/bin/ompi_info --parseable | grep ompi:version:full) | awk '{split($1, arr, "[:.]"); print arr[4]}')

#assemble hostlist based on openmpi version
#for 1.X repeat the hostname for each slot
#for 2.X+ <hostname>:<slots>
for node in $nodes; do
    if [ "$ompi_version" -eq "1" ]; then
	for i in $(seq 1 $ppn); do
	    nodelist=$nodelist$node","
	done
    else
	nodelist=$nodelist$node":"$ppn","
    fi
done


#Run test and pipe output to memdata.py
set -x
#cmd="/opt/openmpi/bin/mpirun -np $x --mca plm rsh --mca ras '^slurm' --mca btl tcp,vader,self --map-by node --host $nodelist /shared/test"
cmd="/opt/openmpi/bin/mpirun -np $x --map-by node --host $nodelist /shared/test"
eval $cmd |& /shared/memdata.py $runnum $rep $nnodes $ppn "$cmd"

set +x
