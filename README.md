# Requirements

* CfnCluster - launches cluster, get from pip
* `awscli` - for uploading files to S3
  * Comes as part of `CfnCluster` from pip
* AWS Credentials

# Initial Setup

1. Put your aws credentials in your `~/.aws` directory and the
   CfnCluster config file (`./config`)
1. Create and download your private key from AWS
1. Change the name of the private key from CfnClusterKey to `<your_key>`
   in `./config`
1. Move `mysqlauth.sh.template` to `mysqlauth.sh` and fill in database info

# Usage

1. Once set up, just run `launch.sh`
1. After any changes to the backend run `sync.sh`

# sync.sh

Uploads all off the files in `./backend`, `~/.aws/credentials` to s3.
Uses the sync functionality for incremental changes, so any moved
files will also be moved in S3 as opposed to duplicated.

# query_db.sh

Usage: `./query_db.sh "<query>" "<args>"`

* `<args>` is passed to `mysql`
* A universal helper script which sends a query to the database
* Database is determined from `mysqlauth.sh`

# mysqlauth.sh

* File containing database information
* All values must be in quotes to ensure proper parsing
  in `memdata.py` (in `./backend/shared`)

# config:

CfnCluster configuration file.

# postinstallargs.cfg

* File containing a list of tests to run
* Each line is appended to the previously mentioned CfnCluster
  config file when a cluster is launched
* To add a new test copy a previous line and follow the format outlined
  in the header:
  * The source can either be git or a url for a tarball
  * Cores on Head and Cores on Compute are the number of cores on
    the head node and compute nodes respectively
  * Number of compute is the number of compute nodes to start
  * Test name is the location of the test to be run on the cluster

# launch.sh

Used to launch a cluster using the information found in
`postinstallargs.cfg`

# Subdirectories

* `backend`: all of the files put on the cluster are contained here
  tests to be run are in `backend/tests`
* `data`: Contains all graphs and scripts to generate them

# Possible Improvements

* Have `launch.sh` detect rollbacks and retry launch.  This would
  require either
  1. launching without `--nowait`
  1. having a process that watches the cluster and restarts it if it
     rolls back This can also enable moving `shutdown.sh`
     (`backend/shared/shutdown.sh`) to outside of the cluster
