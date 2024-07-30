/* Find queries with parameter sniffing issues, look for ones with much different CPU usage. */
SELECT TOP (25)  DB_NAME(dp.dbid) AS [Database Name],
ds.execution_count,
       ds.min_worker_time / 1000000. AS min_worker_time_ms,
       ds.max_worker_time / 1000000. AS max_worker_time_ms,
       ds.min_elapsed_time / 1000000. AS min_elapsed_time_ms,
       ds.max_elapsed_time / 1000000. AS max_elapsed_time_ms,
       ds.min_logical_reads,
       ds.max_logical_reads,
       ds.min_rows,
       ds.max_rows,
       SUBSTRING(st.text, (ds.statement_start_offset / 2) +1,   
                 ((CASE ds.statement_end_offset  
                       WHEN -1 
                       THEN DATALENGTH(st.text)  
                       ELSE ds.statement_end_offset  
                   END - ds.statement_start_offset) / 2) +1) AS text,
       dp.query_plan
FROM sys.dm_exec_query_stats AS ds
CROSS APPLY sys.dm_exec_sql_text(ds.plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(ds.plan_handle) AS dp
WHERE st.dbid = DB_ID()
AND st.text like '%SELECT%'

AND ds.execution_count > 1
AND (ds.min_worker_time / 1000000.) * 100. < (ds.max_worker_time / 1000000.)
ORDER BY max_worker_time_ms DESC
OPTION(RECOMPILE);
