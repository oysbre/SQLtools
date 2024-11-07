/* testquery with parameter to check plan. put two single apostrof if parametervalue is "literal" in the SQL query */
DECLARE @sql NVARCHAR(MAX) = N''
SET @sql = @sql + N'SELECT A.SALESID FROM SALESTABLE A WHERE (A.DATAAREAID=N''d21'') AND (A.SALESSTATUS=@P1) ORDER BY A.SALESID OPTION(FAST 1)'
--SET @sql = @sql + N'OPTION(RECOMPILE)'
set statistics time,io on
EXEC SP_EXECUTESQL @sql
,N'@P1 int,@P2 datetime,@P3 int,@P4 int',
@P1=1,@P2='2020-11-12 23:59:59.000',@P3=1,@P4=0

 
