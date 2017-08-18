#!/bin/bash

#get uptime and if it is greater than 50 mins shutdown
#uncomment to enable

#uptime=$(awk -F'.' '{print $1}' /proc/uptime)
#uptime_min=$(($uptime/60))
#if [ $uptime_min -lt 50 ]; then
#    exit 0
#fi

#Check if there are no queued jobs (1 line due to heading)
#If no jobs are available push logs and output to s3
#then delete self
if [[ $(/opt/slurm/bin/squeue | wc -l) -eq 1 ]]; then
    source /shared/cronvars
    tar cvf ${runnum}_output.tar.gz /home/ec2-user /var/log
    aws s3 cp ${runnum}_output.tar.gz s3://$logs/
    source /opt/cfncluster/cfnconfig
    clustername=${stack_name#*-}
    #This is a hack and I don't like it
    #using awscli to delete the stack means the aws credentials
    #must be on the machine, which means storing them in s3
    #TODO: not this
    aws cloudformation delete-stack --stack-name cfncluster-$clustername --region us-east-1
fi
