#!/bin/bash

#Get run data from environment/ompi_info/scontrol
runnum=${runnum}
rep=${rep}
x=${SLURM_NTASKS}
ompi_version=$(echo $(ompi_info --parseable | grep ompi:version:full) | awk '{split($1, arr, "[:.]"); print arr[4]}')
ncpu=$(grep -c ^processor /proc/cpuinfo)
nodes=$(scontrol show hostname ${SLURM_JOB_NODELIST})

#assemble hostlist based on openmpi version
#for 1.X repeat the hostname for each slot
#for 2.X+ <hostname>:<slots>
for node in $nodes; do 
    if [ "$ompi_version" -eq "1" ]; then
        for i in $(seq 1 $ncpu); do
            nodelist=$nodelist$node","
        done
    else
        nodelist=$nodelist$node":"$ncpu","
    fi
done

#get time before test
before=$(awk "/^now/ {print \$3; exit}" /proc/timer_list)

set -x
#/opt/openmpi/bin/mpirun --mca ras_base_multiplier $ncpu -np $x --mca plm rsh --mca ras '^slurm' --mca btl tcp,vader,self --map-by node --host $nodelist /shared/test
/opt/openmpi/bin/mpirun -np $x --mca plm rsh --mca ras '^slurm' --mca btl tcp,vader,self --map-by node --host $nodelist /shared/test
set +x

#get time after test
after=$(awk "/^now/ {print \$3; exit}" /proc/timer_list)

#throw away first result by setting runtime to -1
numvals="$(bash /shared/query_db.sh "SELECT count(*) FROM data WHERE runnum=$runnum AND x=$x" "-N")"
if [ $numvals -gt 0 ] ; then 
    runtime=$((($after-$before)/1000000))
else
    runtime=-1
fi

#insert runtime into database
$(bash /shared/query_db.sh "INSERT INTO data VALUES($runnum, $rep, $x, $runtime)" "")
