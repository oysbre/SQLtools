# SQLtools
scripts to tune and optimize SQL queries
- ExportSQLUser is used for exporting users on a SQL instance and then create users on a new SQL instance
- GetBlockSize.ps1 checks the cluster size of disk volums.
- MissingIndex.sql create a report of missing indexes.
- ParameterSniffing.sql shows queries that has high read variance in plans that indicates parameter sniffing issue
- RunningQueries.sql displays current running queries along with cursors and their plan
- SearchExecPlansWithParams.sql search for plans ordered by last logical reads with their compiled parameter values.
- VLFCounts.sql detects high VLF counts which can be a problem with time used on restore.
