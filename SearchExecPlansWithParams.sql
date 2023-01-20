/* Get top 10 executionplans in SQL plancache with their parameters */

SELECT TOP 10
DB_NAME(CONVERT(int, qpa.value)) AS [Database Name]
,SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1) AS sqlquery,
qs.execution_count,
qs.total_logical_reads, qs.last_logical_reads,
qs.last_physical_reads, qs.total_physical_reads,
qs.total_logical_writes, qs.last_logical_writes,
qs.total_worker_time,
qs.last_worker_time
,CAST(qs.total_elapsed_time / 1000000.0 AS DECIMAL(28, 2)) AS [Total Duration (s)]
,CAST (qs.last_elapsed_time / 1000000.0 AS DECIMAL(28, 2)) AS [Last_elapsed_(s)]
,CAST(qs.total_worker_time * 100.0 / qs.total_elapsed_time AS DECIMAL(28, 2)) AS [% CPU]
,qs.last_execution_time, qp.query_plan
--,CONVERT(XML,SUBSTRING(etqp.query_plan,CHARINDEX('<ParameterList>',etqp.query_plan), CHARINDEX('</ParameterList>',etqp.query_plan) + LEN('</ParameterList>') - CHARINDEX('<ParameterList>',etqp.query_plan) )) AS Parameters
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) etqp
CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) qpa

where qt.text like '%SELECT%'  COLLATE SQL_Latin1_General_CP1_CS_AS
--and qt.text like '%FAST%'
--and qt.text like '%%'
--and last_logical_reads > 100000
--and qs.last_elapsed_time/1000000 > 400
and execution_count >  1
and attribute = 'dbid' 
--ORDER BY qs.total_logical_reads DESC -- logical reads
-- ORDER BY qs.total_logical_writes DESC -- logical writes
--ORDER BY execution_count DESC -- execution count
--ORDER BY last_execution_time DESC
--ORDER BY qs.total_worker_time DESC -- CPU time
ORDER BY last_logical_reads DESC /* last logical read */
option (recompile)
