SELECT 
a.np,
a.daemon     AS "\"MPI_ Init Daemon\"",
a.daemon_std AS "\"MPI_ Init Daemon std\"",
a.client     AS "\"MPI_ Init Client\"",
a.client_std AS "\"MPI_ Init Client std\"",
a.total      AS "\"MPI_ Init Total\"",
a.total_std  AS "\"MPI_ Init Total std\"",
b.daemon     AS "\"MPI_ Barrier Daemon\"",
b.daemon_std AS "\"MPI_ Barrier Daemon std\"",
b.client     AS "\"MPI_ Barrier Client\"",
b.client_std AS "\"MPI_ Barrier Client std\"",
b.total      AS "\"MPI_ Barrier Total\"",
b.total_std  AS "\"MPI_ Barrier Total std\""
FROM 
(
    SELECT
        nodes*ppn                               AS np,
        AVG(usage_daemon)                       AS daemon,
        STDDEV(usage_daemon)                    AS daemon_std,
        AVG(usage_client)                       AS client,
        STDDEV(usage_client)                    AS client_std,
        AVG(usage_daemon+(usage_client*ppn))    AS total,
        STDDEV(usage_daemon+(usage_client*ppn)) AS total_std
        FROM memdata
        WHERE runnum=208
        AND operation="MPI_Init"
        GROUP BY nodes*ppn,operation
)
AS a
JOIN
(
    SELECT
        nodes*ppn                               AS np,
        AVG(usage_daemon)                       AS daemon,
        STDDEV(usage_daemon)                    AS daemon_std,
        AVG(usage_client)                       AS client,
        STDDEV(usage_client)                    AS client_std,
        AVG(usage_daemon+(usage_client*ppn))    AS total,
        STDDEV(usage_daemon+(usage_client*ppn)) AS total_std
        FROM memdata
        WHERE runnum=208
        AND operation="MPI_Barrier"
        GROUP BY nodes*ppn,operation
)
AS b
ON a.np=b.np
