#!/bin/bash

# Install all needed packages
update()
{
    #yum -y update
    yum -y install python35 python35-pip m4 autoconf automake libtool git gcc-c++ flex htop mysql numactl-devel hwloc
    sudo pip-3.5 install PyMySQL
    echo "updated"
}

#compile openmpi based either from git or from supplied tarball
#TODO: if given git check if hash has already been compiled and grab that
#allow forcing new build (gitf instead of git?)
#store in database completed compilations and shasums of patches?
#put a text file with each tarball (*.txt) with info on the compilation
#any metadata also
compile()
{
    if [ "$1" = "git" ]; then
        git clone https://github.com/open-mpi/ompi
        cd ompi
        ./autogen.pl
    else
        filename=$(basename $1)
        wget "$1"
        tar xf $filename
        cd ${filename%.tar*}
    fi

    #Get patchfiles from s3
    aws s3 cp --recursive s3://$s3backend/V2/patches/ /tmp/patches/
    #Apply patchfiles
    for patchfile in /tmp/patches/*.patch; do patch -p1 < $patchfile; done

    #vpath build, prefix is /opt/openmpi
    mkdir build
    cd build
    ../configure --prefix=/opt/openmpi --with-devel-headers CFLAGS="-g -O2" #--enable-pmix3-dstore
    make -j $2 install
    echo "Compiled"
}

#upload tar of ompi build
upload()
{
    ompihash=$(ompi_info --parseable | awk "/ompi:version:repo:/" | awk -F'g' '{print $NF}') #grab everything after first occurrence of g
    tar_name=ompi-"$ompihash".tar.gz
    tar czf $tar_name /opt/openmpi
    aws s3 cp $tar_name s3://$s3builds/$tar_name
    aws s3 cp $tar_name s3://$s3builds/ompi_latest.tar.gz
    echo "uploaded"
}

#Pull tar of ompi build and unpack 
download()
{
    aws s3 cp s3://$s3builds/ompi_latest.tar.gz ompi_latest.tar.gz
    tar xf ompi_latest.tar.gz -C /
    echo "downloaded"
}

#pull required files from s3
#make all tests and symlink the test being run to /shared/test
#TODO: don't symlink /share/test, make scripts use the real path
get_reqd_files()
{
    testname=$1
    aws s3 cp --recursive s3://$s3backend/V2/shared /shared
    make -C /shared/tests/
    ln -s $testname /shared/test
    aws s3 cp s3://$s3backend/V2/credentials /home/ec2-user/.aws/credentials
    chmod +x /shared/memdata.py
    echo "Got Reqd Files"
}

#Insert all metadata into metadata table
insert_metadata()
{
    ompihash=$(ompi_info --parseable | awk "/ompi:version:repo:/" | awk -F'g' '{print $NF}') 
    ompibranch=$(ompi_info --parseable | awk "/ompi:version:repo:/" | awk -F'-' '{print $1}' | awk -F':' '{print $NF}')
    numcores=$2
    testname=$3
    echo "numcores: " $numcores
    echo "testname: " $testname
    echo "branch: " $ompibranch
    echo "hash: " $ompihash

   runnum="$(bash /shared/query_db.sh "INSERT INTO metadata(runnum, hash, branch, nproc, testname, rundate)  VALUES(0, '$ompihash', '$ompibranch', $numcores, '$testname', NOW()); SELECT last_insert_id();" "-s")"
    echo "Inserted Metadata"
}

#Allow many simulatneous connections to sshd on each server
#ssh was rejecting some connections and causing issues
fix_ssh()
{
    echo "inserting sshd stuff"
    aws s3 cp s3://$s3backend/V2/ssh_config /home/ec2-user/.ssh/config
    chown ec2-user:ec2-user /home/ec2-user/.ssh/config
    echo "MaxStartups 1100:1:1100" >> /etc/ssh/sshd_config
    echo "MaxSessions 1100" >> /etc/ssh/sshd_config
    /etc/init.d/sshd reload
    echo "inserted"
}

#Create a shutdown crontab
#This is currently being handled by the first slurm job
#Which prevents shutting down before tests start
create_cron()
{
    echo "creating crontab"
    echo "runnum=$runnum" > /shared/cronvars
    crontab -u ec2-user /shared/crontab.txt
    chmod +x /shared/shutdown.sh
    echo "done"
}

#Change core pattern to something readable
fix_core()
{
    echo "core.%e-%t-%p" > /proc/sys/kernel/core_pattern 
}

#Create slurm jobs for timing tests
#TODO: HIGH PRIORITY! Make this its own script which doesn't need to be manually changed
#runcluster()
#{
#    computecores=$1
#    computetotal=$2
#    for rep in $(seq 1 5); do
#        iteration=0
#
#        while :; do
#            lowproc=$((2**iteration-3))
#
#            midproc=$((2**iteration))
#            
#            highproc=$((2**iteration+3))
#
#            set -x
#            if [ $iteration -lt 3 ]; then
#                su -c "runnum=$runnum rep=$rep sbatch -n $midproc /shared/memtest.sh" - ec2-user
#                #We do not break here, don't think it is a typo and add the break again
#            elif [ $lowproc -gt $computetotal ]; then
#                break
#            elif [ $midproc -gt $computetotal ]; then
#
#                su -c "runnum=$runnum rep=$rep sbatch -n $lowproc /shared/memtest.sh" - ec2-user
#                break
#            elif [ $highproc -gt $computetotal ]; then
#                su -c "runnum=$runnum rep=$rep sbatch -n $lowproc /shared/memtest.sh" - ec2-user
#                su -c "runnum=$runnum rep=$rep sbatch -n $midproc /shared/memtest.sh" - ec2-user
#                break
#            else
#                su -c "runnum=$runnum rep=$rep sbatch -n $lowproc /shared/memtest.sh" - ec2-user
#                su -c "runnum=$runnum rep=$rep sbatch -n $midproc /shared/memtest.sh" - ec2-user
#                su -c "runnum=$runnum rep=$rep sbatch -n $highproc /shared/memtest.sh" - ec2-user
#            fi
#            set +x
#
#            ((iteration+=1))
#
#        done
#    done
#    echo "Ran Cluster"
#}

#Create memtest jobs
#TODO: combine this with creating jobs for other tests (i.e. timing test)
runcluster()
{
    #Another slurm hack!
    #Slurm complains if you ask for nodes before they are up
    #So you make a job asking for cores instead
    #That job just spawns all of the slurm jobs which require -N
    totalcores=$(($1*$2))
    su -c "runnum=$runnum ncores=$1 nnodes=$2 sbatch -n $totalcores /shared/runcluster.sh" - ec2-user
}

#main function
main()
{
    #For debugging purposes echo all of the inputs
    method=$1
    echo "method: "$method
    hostcores=$2
    echo "hostcores: " $hostcores
    computecores=$3
    echo "computecores: " $computecores
    computenum=$4
    echo "computenum: " $computenum
    testname=$5
    echo "testname: " $testname
    s3backend=$6
    s3builds=$7
    s3logs=$8

    #ppn*np
    computetotal=$(($computecores*$computenum))

    #install needed software
    update

    #get cfncluster variables, used to check if master or compute
    source /opt/cfncluster/cfnconfig
    if [ $cfn_node_type = MasterServer ]; then
	#compile ompi and add it to path&lib path
        compile $method $hostcores
        echo 'PATH=$PATH:/opt/openmpi/bin' >> /etc/bashrc
        echo 'LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/openmpi/lib' >> /etc/bashrc

	#Limit SBATCH to 1 minute before it kills
	#Note that it will not kill -9, that occurs
	#30 seconds later if it needs to
        echo 'export SBATCH_TIMELIMIT=1' >> /etc/bashrc

        source /etc/bashrc
        #echo $PATH

	#upload compile tarball to s3 to be pulled by computefleet
        upload

	#Pulled needed files from s3
        get_reqd_files $testname

	#insert run metadata
        insert_metadata $computenum $computetotal $testname
        #create_cron
	#apply config patches
        fix_ssh
        fix_core

	#create slurm jobs
        #runcluster $computecores $computetotal
        runcluster $computecores $computenum
    elif [ $cfn_node_type = ComputeFleet ]; then
	#pull ompi build from s3
        download
        echo 'PATH=$PATH:/opt/openmpi/bin' >> /etc/bashrc
        echo 'LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/openmpi/lib' >> /etc/bashrc
        echo 'export SBATCH_TIMELIMIT=1' >> /etc/bashrc
        source /etc/bashrc
        #echo $PATH
	#apply ssh patch
        fix_ssh
    fi
    echo "All done!"
}

#entry point
main "${@:2}"
