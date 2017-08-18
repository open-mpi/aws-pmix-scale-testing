#!/usr/bin/python3
import sys
import pymysql 
import imp

# Load strings from bash and use them to connect to the database
mysql_auth = imp.load_source("bash_module", "/shared/mysqlauth.sh")
conn =  pymysql.connect(host=mysql_auth.url,
                        port=int(mysql_auth.port),
                        user=mysql_auth.username,
                        passwd=mysql_auth.password,
                        db=mysql_auth.database,
                        autocommit=True)

cursor = conn.cursor();

#Get command line arguments
runnum = int(sys.argv[1])
rep = int(sys.argv[2])
nodes = int(sys.argv[3])
ppn = int(sys.argv[4])
command = sys.argv[5]

#Insert into memdata
def submit(operation, hostname, daemon_usage, client_usage):
    cursor.execute("""INSERT INTO memdata VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                  (runnum, rep, operation, hostname, nodes, ppn, daemon_usage, client_usage, command))


def main():
    #Initialize variables
    daemon_usage = ''
    client_usage = ''
    operation = ''
    hostname = ''
    #sys.stdin is mpi_memprobe piped in
    for line in sys.stdin:
        if line.startswith("Sampling"):
            #split on whitespace, get last word
            operation = line.rsplit(None, 1)[-1]

        # Because there is occasionally junk at the beginning of the line, check for substring
        # Why treat the cause when you can treat the symptom
        elif "Data for node" in line:
            hostname = line.rsplit(None, 1)[-1]
        #If line is daemon memory usage
        elif line.startswith("\tDaemon"):
            daemon_usage = line.rsplit(None, 1)[-1]
        #If line is client memory usage
        elif line.startswith("\tClient"):
            client_usage = line.rsplit(None, 1)[-1]
        #If line is a newline and the previous line was not
        elif line == "\n" and daemon_usage != '' and client_usage != '':
            submit(operation, hostname, daemon_usage, client_usage)
            daemon_usage = ''
            client_usage = ''

main()
