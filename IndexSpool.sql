/* find plans with Index Spool. To search in a specific database, filter on DBID in pa.value in line 24*/
/* create non-clustered index to avoid the spool. seek predicate = key in index and output column in includes */
;WITH 
    XMLNAMESPACES 
('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS x),
    plans AS 
(
    SELECT TOP (10)
        deqs.query_plan_hash,
        sort = 
            SUM(deqs.total_worker_time / deqs.execution_count)
    FROM sys.dm_exec_cached_plans AS decp
    JOIN sys.dm_exec_query_stats AS deqs
        ON decp.plan_handle = deqs.plan_handle
    CROSS APPLY sys.dm_exec_query_plan(decp.plan_handle) AS deqp
    CROSS APPLY deqp.query_plan.nodes('//x:RelOp') AS r (c)
    WHERE  r.c.exist('//x:RelOp[@PhysicalOp="Index Spool" and @LogicalOp="Eager Spool"]') = 1
    AND    EXISTS
           (      
               SELECT 
                   1/0
               FROM sys.dm_exec_plan_attributes(decp.plan_handle) AS pa 
               WHERE pa.attribute = 'dbid'
               AND   pa.value = >4
           )   
    GROUP BY deqs.query_plan_hash
    ORDER BY sort DESC
)
SELECT
    deqp.query_plan,
    dest.text,
    avg_worker_time = 
        (deqs.total_worker_time / deqs.execution_count),
    deqs.total_worker_time,
    deqs.execution_count
FROM sys.dm_exec_cached_plans AS decp
JOIN sys.dm_exec_query_stats AS deqs
    ON decp.plan_handle = deqs.plan_handle
CROSS APPLY sys.dm_exec_query_plan(decp.plan_handle) AS deqp    
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE EXISTS
(
    SELECT
        1/0
    FROM plans AS p
    WHERE p.query_plan_hash = deqs.query_plan_hash
)
ORDER BY avg_worker_time DESC
OPTION(RECOMPILE, MAXDOP 1);
