/* Identify queries that has high variations of read/cpu time as a sign of parameter sniffing issue */
/* check dataskew in tables that are involved in the query. create a planguide as an emergency fix */ 
WITH Execution_Detail AS (
SELECT DB_NAME(CONVERT(int, qpa.value)) AS [Database Name],
SUBSTRING(ST.text, (QS.statement_start_offset / 2) + 1, ((CASE statement_end_offset
                                                        WHEN-1
                                                        THEN DATALENGTH(ST.text)
                                                        ELSE QS.statement_end_offset
                                                    END - QS.statement_start_offset) / 2) + 1) AS [Query Statement], 
        ST.text AS 'Procedure Batch',
        qs.execution_count,
        qp.query_plan,
	    TRY_CONVERT(XML,SUBSTRING(etqp.query_plan,CHARINDEX('<ParameterList>',etqp.query_plan), CHARINDEX('</ParameterList>',etqp.query_plan) + LEN('</ParameterList>') - CHARINDEX('<ParameterList>',etqp.query_plan) )) AS Parameters,
		qs.min_worker_time /1000. as min_wrk_time_ms,
		qs.max_worker_time /1000. as max_wrk_time_ms,
        ISNULL((max_worker_time - min_worker_time) / NULLIF(min_worker_time, 0), 0) AS LogicalCpuRatio, 
        qs.min_logical_reads,qs.max_logical_reads,
        ISNULL((max_logical_reads - min_logical_reads) / NULLIF(min_logical_reads, 0), 0) AS LogicalReadsDevRatio,
        cast(qs.min_elapsed_time/10000000. as decimal(6, 4))as min_elap_s,
		cast(qs.max_elapsed_time/10000000. as decimal(6, 4))as max_elap_s, 
        ISNULL((max_elapsed_time - min_elapsed_time) / NULLIF(min_elapsed_time, 0), 0) AS LogicalElapsedTimDevRatio
FROM sys.dm_exec_query_stats AS QS
CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) AS ST
CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) qpa
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) etqp
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE attribute = 'dbid' 
)
		
        SELECT * FROM Execution_Detail WHERE LogicalCpuRatio >=100 AND LogicalReadsDevRatio>=100 AND LogicalElapsedTimDevRatio>=100 AND [Query Statement] like 'SELECT%'
		order by LogicalElapsedTimDevRatio desc
		--order by LogicalReadsDevRatio desc
