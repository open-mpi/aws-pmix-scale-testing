#!/bin/bash

#Source authentication for mysql
source $(dirname $0)/mysqlauth.sh

#process query without password if none is provided
#returns output from query
query=$1
options=$2
if [ -z "$password" ]; then
    echo "$query" | mysql $options --host=$url --port=$port -u$username $database
else
    echo "$query" | mysql $options --host=$url --port=$port -u$username -p$password $database
fi
