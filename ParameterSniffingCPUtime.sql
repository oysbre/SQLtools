/* Find queries with parametersniffing issues in plancache. Queries with high CPU workertime difference indicate this .
Run this DMV query on the database in question */
SELECT TOP (10) ds.execution_count,
       CAST(ds.min_worker_time / 1000. as numeric) AS min_worker_time_ms,
       CAST(ds.max_worker_time / 1000. as numeric) AS max_worker_time_ms,
       CAST(ds.min_elapsed_time / 1000. as numeric) AS min_elapsed_time_ms,
       CAST(ds.max_elapsed_time / 1000. as numeric) AS max_elapsed_time_ms,
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
AND ds.execution_count > 1
AND (ds.min_worker_time / 1000000.) * 100. < (ds.max_worker_time / 1000000.)
--AND st.text like '%INVENTDIM%'
--AND st.text like '%FAST%'
ORDER BY max_worker_time_ms DESC
OPTION(RECOMPILE);
