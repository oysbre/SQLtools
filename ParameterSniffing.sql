/* Identify queries that has high variations of read/cpu time as a sign of parameter sniffing issue */
WITH Execution_Detail AS (
SELECT SUBSTRING(ST.text, (QS.statement_start_offset / 2) + 1, ((CASE statement_end_offset
                                                        WHEN-1
                                                        THEN DATALENGTH(ST.text)
                                                        ELSE QS.statement_end_offset
                                                    END - QS.statement_start_offset) / 2) + 1) AS [Query Statement], 
        ST.text AS 'Procedure Batch',
        min_worker_time, max_worker_time,
        ISNULL((max_worker_time - min_worker_time) / NULLIF(min_worker_time, 0), 0) AS LogicalCpuRatio, 
        min_logical_reads,max_logical_reads,
        ISNULL((max_logical_reads - min_logical_reads) / NULLIF(min_logical_reads, 0), 0) AS LogicalReadsDevRatio,
        min_elapsed_time,max_elapsed_time, 
        ISNULL((max_elapsed_time - min_elapsed_time) / NULLIF(min_elapsed_time, 0), 0) AS LogicalElapsedTimDevRatio
FROM sys.dm_exec_query_stats AS QS
CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) AS ST)
		
        SELECT * FROM Execution_Detail WHERE LogicalCpuRatio >=100 AND LogicalReadsDevRatio>=100 AND LogicalElapsedTimDevRatio>=100 AND [Query Statement] like 'SELECT%'
		--order by LogicalElapsedTimDevRatio desc
		order by LogicalReadsDevRatio desc
