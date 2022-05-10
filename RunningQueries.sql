/* Stored procedure to get execution queries also within cursors */
USE [master]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_RunningQuery]
WITH RECOMPILE
AS
    SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT CONCAT(
        RIGHT('0' + CAST(r.total_elapsed_time/(1000*60*60) AS VARCHAR(2)),2), ':',                     -- Hrs
        RIGHT('0' + CAST((r.total_elapsed_time%(1000*60*60))/(1000*60) AS VARCHAR(2)),2), ':',         -- Mins
        RIGHT('0' + CAST(((r.total_elapsed_time%(1000*60*60))%(1000*60))/1000 AS VARCHAR(2)),2), '.',  -- Secs
        ((r.total_elapsed_time%(1000*60*60))%(1000*60))%1000                                           -- Milli Secs
) AS [hh:mm:ss.ms],
	r.session_id                                     AS SPID,
       r.blocking_session_id                            AS BLCK_BY_SPID,
       se.host_name                                     AS HOSTNAME,
       se.login_name                                    AS LOGIN_NAME,
       DB_NAME(r.database_id)                           AS DATABASE_NAME,
       r.status                                         AS STATUS,
       r.command                                        AS COMMAND,
       r.cpu_time                                       AS CPU_TIME,
       r.reads                                          AS READS,
       r.logical_reads                                  AS LOGICAL_READS,
       r.writes                                         AS WRITES,
	    r.writes                                         AS WRITES,
	     SQL_CURSORSTATS.last_logical_reads				AS Last_Logical_Reads,
	   SQL_CURSORSTATS.last_elapsed_time/1000000		AS Last_Elap_Time_S,
	   SQL_CURSORSTATS.last_worker_time/1000000			AS Last_Wrk_Time_S,
	   SQL_CURSORSTATS.max_worker_time/1000000  		AS Max_Wrk_Time_S,
	   SQL_CURSORSTATS.max_elapsed_time/1000000			AS Max_Elap_Time_S,
       CAST(r.context_info AS VARCHAR(128))             AS CONTEXT_INFO,
       s.text                                           AS SQL_TEXT,
       p.query_plan							            AS QUERY_PLAN,
       SQL_CURSORSQL.text                               AS CURSOR_SQL_TEXT,
       SQL_CURSORPLAN.query_plan						AS CURSOR_QUERY_PLAN,
       BLOCKING_DATA.ctext                              AS BLOCKING_TEXT,
       BLOCKING_DATA.BLOCKING_CONTEXT                   AS BLOCKING_CONTEXT,
       BLOCKING_DATA.BLOCKING_QUERY_PLAN                AS BLOCKING_QUERY_PLAN,
       BLOCKING_DATA.BLOCKING_CURSOR_PLAN               AS BLOCKING_CURSOR_PLAN,
       r.wait_time                                      AS WAIT_TIME,
       r.wait_type                                      AS WAIT_TYPE,
       r.open_transaction_count                         AS OPEN_TRANS_COUNT,
       r.estimated_completion_time                      AS ESTIMATED_COMPLETION_TIME,
       TSU.TEMPDBUSEROBJECTSALLOCATED                   AS TEMPDB_USER_OBJECTS_ALLOCATED,
       TSU.TEMPDBUSEROBJECTSDEALLOCATED                 AS TEMPDB_USER_OBJECTS_DEALLOCATED,
       TSU.TEMPDBINTERNALOBJECTSALLOCATED               AS TEMPDB_INTERNAL_OBJECTS_ALLOCATED,
       TSU.TEMPDBINTERNALOBJECTSDEALLOCATED             AS TEMPDB_INTERNAL_OBJECTS_DEALLOCATED
         
         
FROM   sys.dm_exec_requests AS r
       INNER JOIN sys.dm_exec_sessions AS se
               ON r.session_id = se.session_id
       OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS s
       OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) AS p
       OUTER APPLY sys.dm_exec_cursors(r.session_id) AS SQL_CURSORS
       OUTER APPLY sys.dm_exec_sql_text(SQL_CURSORS.sql_handle) AS SQL_CURSORSQL
       LEFT JOIN sys.dm_exec_query_stats AS SQL_CURSORSTATS
              ON SQL_CURSORSTATS.sql_handle = SQL_CURSORS.sql_handle
       OUTER APPLY sys.dm_exec_query_plan(SQL_CURSORSTATS.plan_handle) AS SQL_CURSORPLAN
       OUTER APPLY (SELECT r.session_id,
                           CAST(r_blk.context_info AS VARCHAR(128))         AS BLOCKING_CONTEXT,
                           s.text,
                           SQL_CURSORSQL.text                               AS CTEXT,
                           CAST(SQL_CURSORPLAN.query_plan AS NVARCHAR(MAX)) AS BLOCKING_CURSOR_PLAN,
                           CAST(p.query_plan AS NVARCHAR(MAX))              AS BLOCKING_QUERY_PLAN
                    FROM   sys.dm_exec_requests AS r_blk
                           INNER JOIN sys.dm_exec_sessions AS se
                                   ON r.session_id = se.session_id
                           OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS s
                           OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) AS p
                           OUTER APPLY sys.dm_exec_cursors(r.session_id) AS SQL_CURSORS
                           OUTER APPLY sys.dm_exec_sql_text(SQL_CURSORS.sql_handle) AS SQL_CURSORSQL
                           LEFT JOIN sys.dm_exec_query_stats AS SQL_CURSORSTATS
                                  ON SQL_CURSORSTATS.sql_handle = SQL_CURSORS.sql_handle
                           OUTER APPLY sys.dm_exec_query_plan(SQL_CURSORSTATS.plan_handle) AS SQL_CURSORPLAN
                    WHERE  r_blk.session_id = r.blocking_session_id) AS BLOCKING_DATA
       LEFT JOIN (SELECT SESSIONID = session_id,
                         REQUESTID = request_id,
                         TEMPDBUSEROBJECTSALLOCATED = SUM (user_objects_alloc_page_count),
                         TEMPDBUSEROBJECTSDEALLOCATED = SUM(user_objects_dealloc_page_count),
                         TEMPDBINTERNALOBJECTSALLOCATED = SUM (internal_objects_alloc_page_count),
                         TEMPDBINTERNALOBJECTSDEALLOCATED = SUM (internal_objects_dealloc_page_count)
                  FROM   sys.dm_db_task_space_usage
                  GROUP  BY session_id,
                            request_id) AS TSU
              ON TSU.SESSIONID = r.session_id
                 AND TSU.REQUESTID = r.request_id


WHERE  r.session_Id > 51 AND r.session_id <> @@SPID

SET NOCOUNT OFF;
