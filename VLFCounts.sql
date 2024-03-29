/* Get VLF Counts for all databases on the instance 
Ff above 100, shrink LOG file and set Autogrowth higher in MB not % 
When VLF under 100 – ignore, between 100 – 200 – you can ignore, but better to fix
When above 400 – it’s getting urgent, so fix it.
When above 600 – slowdowns are happening, but it’s not easy to diagnose these. Fix.
When above 5000, fix now!
*/
CREATE TABLE #VLFInfo (Recoveryunitid int ,FileID  int,
					   FileSize bigint, StartOffset bigint,
					   FSeqNo      bigint, [Status]    bigint,
					   Parity      bigint, CreateLSN   numeric(38));
	 
CREATE TABLE #VLFCountResults(DatabaseName sysname, VLFCount int);
	 
EXEC sp_MSforeachdb N'Use [?]; 

				INSERT INTO #VLFInfo 
				EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
				INSERT INTO #VLFCountResults 
				SELECT DB_NAME(), COUNT(*) 
				FROM #VLFInfo; 

				TRUNCATE TABLE #VLFInfo;'
	 
SELECT DatabaseName, VLFCount  
FROM #VLFCountResults
ORDER BY VLFCount DESC;
	 
DROP TABLE #VLFInfo;
DROP TABLE #VLFCountResults;
