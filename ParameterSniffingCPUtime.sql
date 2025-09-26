/* Find queries with sign of parametersniffing issues in plancache.
Queries with high CPU workertime and/or logicalreads difference between min and max indicate this.
Check for dataskew in related tables in a query for their values used in parameters
Create planguide if needed to force a "good plan" */
SELECT TOP (10)
        ds.execution_count
       ,CAST(ds.min_worker_time / 1000. as numeric) AS min_worker_time_ms
       ,CAST(ds.max_worker_time / 1000. as numeric) AS max_worker_time_ms
       ,CAST(ds.min_elapsed_time / 1000. as numeric) AS min_elapsed_time_ms
       ,CAST(ds.max_elapsed_time / 1000. as numeric) AS max_elapsed_time_ms
       ,ds.min_logical_reads
       ,ds.max_logical_reads
       ,ds.min_rows
       ,ds.max_rows
	   ,st.text
       ,SUBSTRING(st.text, (ds.statement_start_offset / 2) +1,   
                 ((CASE ds.statement_end_offset  
                       WHEN -1 
                       THEN DATALENGTH(st.text)  
                       ELSE ds.statement_end_offset  
                   END - ds.statement_start_offset) / 2) +1) AS SQLquery
       
	   --,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CAST(TRY_CONVERT(XML,SUBSTRING(etqp.query_plan,CHARINDEX('<ParameterList>',etqp.query_plan), CHARINDEX('</ParameterList>',etqp.query_plan) + LEN('</ParameterList>') - CHARINDEX('<ParameterList>',etqp.query_plan) )) AS NVARCHAR(MAX)),'<',''),'>',''),'"',''),'/',' '),'ParameterList',''),'ColumnReference Column=',''),'ParameterDataType=',''),'ParameterCompiledValue=','')  AS CompiledParameters
	   --,dp.query_plan /* uncomment to see the queryplan */

FROM sys.dm_exec_query_stats AS ds
CROSS APPLY sys.dm_exec_sql_text(ds.plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(ds.plan_handle) AS dp
CROSS APPLY sys.dm_exec_text_query_plan(ds.plan_handle, ds.statement_start_offset, ds.statement_end_offset) etqp
WHERE ds.execution_count > 1 /* filter on queries runned more than once */
--AND st.dbid = DB_ID() /* filter on current select database only, else run on SQL instance */
AND (ds.min_worker_time / 1000000.) * 100. < (ds.max_worker_time / 1000000.) /* filter on workertime that may suffer from parametersniffing */
AND st.text like '%SELECT%' COLLATE SQL_Latin1_General_CP1_CS_AS /* filter on SELECT case-sensitive */
--AND st.text like '%INVENTDIM%' /* filter on specific table in plans */
--AND st.text like '%FAST%' /* filter on specific OPTION in plans */
AND CAST(dp.query_plan AS nvarchar(max)) NOT LIKE ('%PlanGuideName%') /* exclude plans with existing planguide */
ORDER BY max_worker_time_ms DESC
OPTION(RECOMPILE);
