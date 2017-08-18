#!/bin/bash
source ./buckets.sh

#upload all files to s3
aws s3 cp --acl public-read backend/preinstall.sh s3://$backend/V2/preinstall.sh
aws s3 cp --acl public-read backend/setup.sh s3://$backend/V2/setup.sh
aws s3 cp --acl public-read backend/ssh_config s3://$backend/V2/ssh_config
aws s3 cp --acl public-read ~/.aws/credentials s3://$backend/V2/credentials

aws s3 sync backend/shared/ s3://$backend/V2/shared/
aws s3 sync backend/patches/ s3://$backend/V2/patches
