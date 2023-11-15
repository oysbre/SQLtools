/*--#################################################################################################
-- Get a list of Columns that are not using the same collation as the database with commands to change them sorted in right order.
-- This script only list print out commands and don't actually run them! The --exec(@isql) in the end of the script that run the scriptcommands, are commented out.
-- Always take a backup of the database first or run the script on a backup. TEST!
-- Because of a reference to 'sys.sql_expression_dependencies', this is valid only for SQL2008 and above.

--simple constraints
--STEP_00x Fulltext search
--STEP_001 check constraints
--STEP_002 default constraints
--STEP_003 calculated column definitions
--STEP_004 foreign key constraints complex constraints and indexes (unique/pk/regular/includes/filtered indexes)
--STEP_005 primary keys
--STEP_006 unique indexes
--STEP_007 regular indexes(also featuring includes or filtered indexes) columns themselves
--STEP_008 Column Collation definitions views that reference any of the object tables
--STEP_009 refresh dependent views, procs and functions

/*--#################################################################################################
--Declare and assign collation variable as the same as Database collation
--#################################################################################################*/

DECLARE @NewCollation VARCHAR(128) = CONVERT(varchar,(SELECT DATABASEPROPERTYEX(db_name(),'Collation'))) /*  --'SQL_Latin1_General_CP1_CI_AS' or change this to the collation that you need */

IF OBJECT_ID(N'tempdb..#Results') IS NOT NULL
BEGIN
 DROP TABLE #Results
END

CREATE TABLE #Results
(
[ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
[ExecutionOrder] INT NOT NULL,
[Command] NVARCHAR(max) NULL
)


INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT 0 AS ExecutionOrder, '--Suite of commands to change collation of all columns that are not currently ' + QUOTENAME(@NewCollation) AS Command;

/*--#################################################################################################

--Start a transaction? might cause huge bloating of the transaction log, but too bad.

--#################################################################################################*/

IF OBJECT_ID(N'tempdb..#MyAffectedTables') IS NOT NULL
BEGIN
 DROP TABLE #MyAffectedTables
END

CREATE TABLE #MyAffectedTables
(
[Tid] INT IDENTITY (1,1) NOT NULL PRIMARY KEY, 
[object_id] INT,
SchemaName varchar(255),
TableName nvarchar(4000),
ColumnName nvarchar(4000),
name nvarchar(4000),
column_id INT
)

INSERT INTO #MyAffectedTables
SELECT

	objz.object_id,
	SCHEMA_NAME(objz.schema_id) AS SchemaName,
	objz.name AS TableName,
	colz.name AS ColumnName,
	colz.collation_name,
	colz.column_id

FROM sys.columns colz
 INNER JOIN sys.tables objz
 ON colz.object_id = objz.object_id
WHERE colz.collation_name IS NOT NULL
 AND objz.is_ms_shipped = 0
 AND colz.is_computed = 0
 AND colz.collation_name <> @NewCollation
 
/* -- filter on Tablename if needed */
 --AND objz.name like 'CUSTCOLL%'
 ;

 /* check results in temptables */
 --select * from #MyAffectedTables tabz

/*--#################################################################################################

--STEP_00X check if columns are in a FullText searchcatalog

--################################################################################################# */

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 9 AS ExecutionOrder,

 CONVERT(VARCHAR(8000), 'EXEC sp_fulltext_column @tabname = ''' + tabz.SchemaName + '.' + tabz.TableName + ''' , @colname = ''' + colz.name + ''' , @action = ' + '''DROP'''+ ';') AS Command

FROM 
    sys.tables objz
INNER JOIN 
    sys.fulltext_indexes fi 
ON 
    objz.[object_id] = fi.[object_id] 
INNER JOIN 
    sys.fulltext_index_columns ic
ON 
    ic.[object_id] =objz.[object_id]
INNER JOIN
    sys.columns colz
ON 
    ic.column_id = colz.column_id
    AND ic.[object_id] = colz.[object_id]

LEFT JOIN 
    sys.columns cdt
ON 
    ic.type_column_id = cdt.column_id
    AND fi.object_id = cdt.object_id

INNER JOIN #MyAffectedTables tabz

ON tabz.object_id = colz.object_id

 AND tabz.column_id = colz.column_id

WHERE objz.type = 'U'


/*--add the Columns back for FullText Search */

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 899 AS ExecutionOrder,

 CONVERT(VARCHAR(8000), 'EXEC sp_fulltext_column @tabname = ''' + tabz.SchemaName + '.' + tabz.TableName + ''' , @colname = ''' + colz.name + ''' , @action = ' + '''ADD'''+ ';') AS Command

FROM 
    sys.tables objz
INNER JOIN 
    sys.fulltext_indexes fi 
ON 
    objz.[object_id] = fi.[object_id] 
INNER JOIN 
    sys.fulltext_index_columns ic
ON 
    ic.[object_id] =objz.[object_id]
INNER JOIN
    sys.columns colz
ON 
    ic.column_id = colz.column_id
    AND ic.[object_id] = colz.[object_id]

LEFT JOIN 
    sys.columns cdt
ON 
    ic.type_column_id = cdt.column_id
    AND fi.object_id = cdt.object_id

INNER JOIN #MyAffectedTables tabz

ON tabz.object_id = colz.object_id

 AND tabz.column_id = colz.column_id

WHERE objz.type = 'U'

/*--#################################################################################################

--STEP_001 check constriants

--#################################################################################################*/

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 10 AS ExecutionOrder,

 CONVERT(VARCHAR(8000), 'ALTER TABLE ' + QUOTENAME(tabz.SchemaName) + '.' + QUOTENAME(tabz.TableName) + ' DROP CONSTRAINT ' + QUOTENAME(conz.name) + ';') AS Command

FROM sys.check_constraints conz

 INNER JOIN #MyAffectedTables tabz

 ON conz.parent_object_id = tabz.object_id

 AND conz.parent_column_id = tabz.column_id;

--add the recreation of the constraints.

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 100 AS ExecutionOrder,

 CONVERT(VARCHAR(8000), 'ALTER TABLE ' + QUOTENAME(tabz.SchemaName) + '.' + QUOTENAME(tabz.TableName) + ' ADD CONSTRAINT ' + QUOTENAME(conz.name) + ' CHECK ' + conz.definition + ';') AS Command

FROM sys.check_constraints conz

 INNER JOIN #MyAffectedTables tabz

 ON conz.parent_object_id = tabz.object_id

 AND conz.parent_column_id = tabz.column_id;

/*--#################################################################################################

--STEP_002 default constraints

--#################################################################################################*/

/*--visualize the data

SELECT *

FROM sys.default_constraints conz

 INNER JOIN #MyAffectedTables tabz

 ON conz.parent_object_id = tabz.object_id

 AND conz.parent_column_id = tabz.column_id

*/

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 20 AS ExecutionOrder,

 CONVERT(VARCHAR(8000), 'ALTER TABLE ' + QUOTENAME(tabz.SchemaName) + '.' + QUOTENAME(tabz.TableName) + ' DROP CONSTRAINT ' + QUOTENAME(conz.name) + ';') AS Command

FROM sys.default_constraints conz

 INNER JOIN #MyAffectedTables tabz

 ON conz.parent_object_id = tabz.object_id

 AND conz.parent_column_id = tabz.column_id;

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 200 AS ExecutionOrder,

 CONVERT(VARCHAR(8000), 'ALTER TABLE ' + QUOTENAME(tabz.SchemaName) + '.' + QUOTENAME(tabz.TableName) + ' ADD CONSTRAINT ' + QUOTENAME(conz.name) + ' DEFAULT ' + conz.definition + ' FOR ' + quotename(tabz.ColumnName) + ';') AS Command

FROM sys.default_constraints conz

 INNER JOIN #MyAffectedTables tabz

 ON conz.parent_object_id = tabz.object_id

 AND conz.parent_column_id = tabz.column_id;

/* --#################################################################################################
--STEP_003 calculated columns : refering internal columns to the table
--################################################################################################# */

/* --need distinct in case of a calculated columns appending two or more columns together: we need the definition only once. */

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 DISTINCT

 30 AS ExecutionOrder,

 'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(objz.schema_id)) + '.' + QUOTENAME(objz.name) + ' DROP COLUMN ' + QUOTENAME(colz.name) + ';' AS Command

FROM sys.columns colz

 LEFT OUTER JOIN sys.tables objz

 ON colz.[object_id] = objz.[object_id]

 LEFT OUTER JOIN sys.computed_columns CALC

 ON colz.[object_id] = CALC.[object_id]

 AND colz.[column_id] = CALC.[column_id]

 --only calculations referencing columns

 LEFT OUTER JOIN sys.sql_expression_dependencies depz

 ON colz.object_id = depz.referenced_id

 AND colz.column_id = depz.referencing_minor_id

 INNER JOIN #MyAffectedTables tabz

 ON depz.referenced_id = tabz.object_id

 AND depz.referenced_minor_id = tabz.column_id

WHERE colz.is_computed = 1;

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 DISTINCT

 300 AS ExecutionOrder,

 'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(objz.schema_id)) + '.' + QUOTENAME(objz.name) + ' ADD ' + QUOTENAME(colz.name) + ' AS ' + ISNULL(CALC.definition, '')

 + CASE

 WHEN CALC.is_persisted = 1

 THEN ' PERSISTED'

 ELSE ''

 END + ';' AS Command

FROM sys.columns colz

 LEFT OUTER JOIN sys.tables objz

 ON colz.[object_id] = objz.[object_id]

 LEFT OUTER JOIN sys.computed_columns CALC

 ON colz.[object_id] = CALC.[object_id]

 AND colz.[column_id] = CALC.[column_id]

 --only calculations referencing columns

 LEFT OUTER JOIN sys.sql_expression_dependencies depz

 ON colz.object_id = depz.referenced_id

 AND colz.column_id = depz.referencing_minor_id

 INNER JOIN #MyAffectedTables tabz

 ON depz.referenced_id = tabz.object_id

 AND depz.referenced_minor_id = tabz.column_id

WHERE colz.is_computed = 1;

/* --#################################################################################################
--STEP_004 foreign key constriants :child references
--################################################################################################# */

/* --visualize the data  it is very rare to have a char column as the value for a FK */

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 DISTINCT

 40 AS ExecutionOrder,

 CONVERT(VARCHAR(8000), 'ALTER TABLE ' + QUOTENAME(tabz.SchemaName) + '.' + QUOTENAME(tabz.TableName) + ' DROP CONSTRAINT ' + QUOTENAME(conz.name) + ';') AS Command

FROM sys.foreign_keys conz

 INNER JOIN sys.foreign_key_columns colz

 ON conz.object_id = colz.constraint_object_id

 INNER JOIN #MyAffectedTables tabz

 ON conz.parent_object_id = tabz.object_id

WHERE tabz.object_id = colz.parent_object_id

 AND tabz.column_id = colz.parent_column_id;

--foreign keys, potentially, can span multiple keys;

--'scriptlet to do all FK's for reference.

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 DISTINCT

 --FK must be added AFTER the PK/unique constraints are added back.

 850 AS ExecutionOrder,

 'ALTER TABLE '

 + QUOTENAME(schema_name(conz.schema_id) )

 + '.'

 + QUOTENAME(OBJECT_NAME(conz.parent_object_id))

 + ' ADD CONSTRAINT '

 + QUOTENAME(conz.name)

 + ' FOREIGN KEY ('

 + ChildCollection.ChildColumns

 + ') REFERENCES '

 + QUOTENAME(SCHEMA_NAME(conz.schema_id))

 + '.'

 + QUOTENAME(OBJECT_NAME(conz.referenced_object_id))

 + ' (' + ParentCollection.ParentColumns

 + ') '

 + ' ON UPDATE ' + CASE conz.update_referential_action

 WHEN 0 THEN 'NO ACTION '

 WHEN 1 THEN 'CASCADE '

 WHEN 2 THEN 'SET NULL '

 ELSE 'SET DEFAULT '

 END

 + ' ON DELETE ' + CASE conz.delete_referential_action

 WHEN 0 THEN 'NO ACTION '

 WHEN 1 THEN 'CASCADE '

 WHEN 2 THEN 'SET NULL '

 ELSE 'SET DEFAULT '

 END

 + CASE conz.is_not_for_replication

 WHEN 1 THEN ' NOT FOR REPLICATION '

 ELSE ''

 END

 + ';' AS Command

FROM sys.foreign_keys conz

 INNER JOIN sys.foreign_key_columns colz

 ON conz.object_id = colz.constraint_object_id

 INNER JOIN #MyAffectedTables tabz

 ON conz.parent_object_id = tabz.object_id

 AND tabz.column_id = colz.parent_column_id

 INNER JOIN (--gets my child tables column names

SELECT

 conz.name,

 ChildColumns = STUFF((SELECT

 ',' + REFZ.name

 FROM sys.foreign_key_columns fkcolz

 INNER JOIN sys.columns REFZ

 ON fkcolz.parent_object_id = REFZ.object_id

 AND fkcolz.parent_column_id = REFZ.column_id

 WHERE fkcolz.parent_object_id = conz.parent_object_id

 AND fkcolz.constraint_object_id = conz.object_id

 ORDER BY

 fkcolz.constraint_column_id

 FOR XML PATH('')), 1, 1, '')

FROM sys.foreign_keys conz

 INNER JOIN sys.foreign_key_columns colz

 ON conz.object_id = colz.constraint_object_id

GROUP BY

conz.name,

conz.parent_object_id,--- without GROUP BY multiple rows are returned

 conz.object_id

 ) ChildCollection

 ON conz.name = ChildCollection.name

 INNER JOIN (--gets the parent tables column names for the FK reference

 SELECT

 conz.name,

 ParentColumns = STUFF((SELECT

 ',' + REFZ.name

 FROM sys.foreign_key_columns fkcolz

 INNER JOIN sys.columns REFZ

 ON fkcolz.referenced_object_id = REFZ.object_id

 AND fkcolz.referenced_column_id = REFZ.column_id

 WHERE fkcolz.referenced_object_id = conz.referenced_object_id

 AND fkcolz.constraint_object_id = conz.object_id

 ORDER BY fkcolz.constraint_column_id

 FOR XML PATH('')), 1, 1, '')

 FROM sys.foreign_keys conz

 INNER JOIN sys.foreign_key_columns colz

 ON conz.object_id = colz.constraint_object_id

 -- AND colz.parent_column_id

 GROUP BY

 conz.name,

 conz.referenced_object_id,--- without GROUP BY multiple rows are returned

 conz.object_id

 ) ParentCollection

 ON conz.name = ParentCollection.name;

/* --#################################################################################################

--STEP_005, 006 and 007 primary keys,unique indexes,regular indexes

--################################################################################################# */

/*pre-quel sequel to gather the data:*/

IF (SELECT

 OBJECT_ID('Tempdb.dbo.#Indexes')) IS NOT NULL

 DROP TABLE #Indexes;

SELECT

 CASE

 WHEN is_primary_key = 1

 THEN 'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME) + '.' + QUOTENAME(OBJECT_NAME) + ' DROP CONSTRAINT ' + QUOTENAME(index_name) + ';'

 WHEN is_unique_constraint = 1

 THEN 'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME) + '.' + QUOTENAME(OBJECT_NAME) + ' DROP CONSTRAINT ' + QUOTENAME(index_name) + ';'

 ELSE 'DROP INDEX ' + +QUOTENAME(index_name) + ' ON ' + QUOTENAME(SCHEMA_NAME) + '.' + QUOTENAME(OBJECT_NAME) + ';'

 END COLLATE database_default AS c1,

 CASE

 WHEN is_primary_key = 1

 THEN 'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME) + '.' + QUOTENAME(OBJECT_NAME) + ' ADD CONSTRAINT ' + QUOTENAME(index_name) + ' PRIMARY KEY '

 + CASE

 WHEN type_desc = 'CLUSTERED'

 THEN type_desc

 ELSE ''

 END + ' (' + index_columns_key + ')' + ';'

 WHEN is_unique_constraint = 1

 THEN 'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME) + '.' + QUOTENAME(OBJECT_NAME) + ' ADD CONSTRAINT ' + QUOTENAME(index_name) + ' UNIQUE (' + index_columns_key + ')' + ';'

  ELSE 'CREATE '

 + CASE

 WHEN is_unique = 1

 THEN 'UNIQUE '

 ELSE ''

 END

 + CASE

 WHEN index_id = 1

 THEN 'CLUSTERED '

 ELSE ''

 END

 + 'INDEX ' + +QUOTENAME(index_name) + ' ON ' + +QUOTENAME(SCHEMA_NAME) + '.' + QUOTENAME(OBJECT_NAME) + ' (' + index_columns_key + ')'

 + CASE

 WHEN index_columns_include = '---'

 THEN ''

 ELSE ' INCLUDE (' + index_columns_include + ')'

 END

 + CASE

 WHEN has_filter = 0

 THEN ''

 ELSE ' WHERE ' + filter_definition + ' '

 END

  + CASE

 WHEN data_compression = 1 or data_compression = 2 THEN ' WITH (DATA_COMPRESSION = ' + data_compression_desc + ')'

 ELSE ''

 END + ';'

 END COLLATE database_default AS c2,

 *

INTO

 #INDEXES

FROM (SELECT

 SCH.schema_id,

 SCH.[name] COLLATE database_default AS SCHEMA_NAME,

 OBJS.[object_id],

 OBJS.[name] COLLATE database_default AS OBJECT_NAME,

 IDX.index_id,

 ISNULL(IDX.[name], '---') COLLATE database_default AS index_name,

 partitions.Rows,

 partitions.SizeMB,

 INDEXPROPERTY(OBJS.[object_id], IDX.[name], 'IndexDepth') AS IndexDepth,

 IDX.type,

 IDX.type_desc COLLATE database_default AS type_desc,

 IDX.fill_factor,

 IDX.is_unique,

 IDX.is_primary_key,

 IDX.is_unique_constraint,

 IDX.has_filter,

 p.data_compression,
 
 p.data_compression_desc,

 IDX.filter_definition,

 ISNULL(Index_Columns.index_columns_key, '---') COLLATE database_default AS index_columns_key,

 ISNULL(Index_Columns.index_columns_include, '---') COLLATE database_default AS index_columns_include

 FROM sys.objects OBJS

 INNER JOIN sys.schemas SCH

 ON OBJS.schema_id = SCH.schema_id

 INNER JOIN sys.indexes IDX

 ON OBJS.[object_id] = IDX.[object_id]
  
  INNER JOIN sys.partitions p
 ON IDX.object_id = p.object_id
    AND IDX.index_id = p.index_id
 INNER JOIN (SELECT
 [object_id],
 index_id,
 SUM(row_count) AS Rows,
 CONVERT(NUMERIC(19, 3), CONVERT(NUMERIC(19, 3), SUM(in_row_reserved_page_count+lob_reserved_page_count+row_overflow_reserved_page_count))/CONVERT(NUMERIC(19, 3), 128)) AS SizeMB
 FROM sys.dm_db_partition_stats STATS
 GROUP BY
 [object_id],
 index_id) AS partitions
 ON IDX.[object_id] = partitions.[object_id]
 AND IDX.index_id = partitions.index_id
 CROSS APPLY (SELECT
 LEFT(index_columns_key, LEN(index_columns_key) - 1) COLLATE database_default AS index_columns_key,
 LEFT(index_columns_include, LEN(index_columns_include) - 1) COLLATE database_default AS index_columns_include
 FROM (SELECT
 (SELECT
 quotename(colz.[name]) + ',' + ' ' COLLATE database_default
 FROM sys.index_columns IXCOLS
 INNER JOIN sys.columns colz
 ON IXCOLS.column_id = colz.column_id
 AND IXCOLS.[object_id] = colz.[object_id]
 WHERE IXCOLS.is_included_column = 0
 AND IDX.[object_id] = IXCOLS.[object_id]
 AND IDX.index_id = IXCOLS.index_id
 ORDER BY
 key_ordinal
 FOR XML PATH('')) AS index_columns_key,
 (SELECT
 quotename(colz.[name]) + ',' + ' ' COLLATE database_default
 FROM sys.index_columns IXCOLS
 INNER JOIN sys.columns colz
 ON IXCOLS.column_id = colz.column_id
 AND IXCOLS.[object_id] = colz.[object_id]
 WHERE IXCOLS.is_included_column = 1
 AND IDX.[object_id] = IXCOLS.[object_id]
 AND IDX.index_id = IXCOLS.index_id
 ORDER BY
 index_column_id
 FOR XML PATH('')) AS index_columns_include) AS Index_Columns) AS Index_Columns)AllIndexes

/* --#################################################################################################
--STEP_005 primary keys
--################################################################################################# */

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 DISTINCT

 50 AS ExecutionOrder,

 IDXZ.c1 AS Command

FROM #Indexes IDXZ

 LEFT OUTER JOIN #MyAffectedTables TBLZ

 ON IDXZ.object_name = TBLZ.TableName

WHERE is_primary_key = 1

 AND ( CHARINDEX(quotename(TBLZ.ColumnName) , quotename(IDXZ.index_columns_key) ) > 0

 OR CHARINDEX(quotename(TBLZ.ColumnName) , quotename(IDXZ.index_columns_key) ) > 0 )

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 DISTINCT

 500 AS ExecutionOrder,

 IDXZ.c2 AS Command

FROM #Indexes IDXZ

 LEFT OUTER JOIN #MyAffectedTables TBLZ

 ON IDXZ.object_name = TBLZ.TableName

WHERE is_primary_key = 1

 AND ( CHARINDEX(quotename(TBLZ.ColumnName) , quotename(IDXZ.index_columns_key) ) > 0

 OR CHARINDEX(quotename(TBLZ.ColumnName) , quotename(IDXZ.index_columns_key) ) > 0 )

/* --#################################################################################################

--STEP_006 unique indexes

--################################################################################################# */

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 DISTINCT

 60 AS ExecutionOrder,

 IDXZ.c1 AS Command

FROM #Indexes IDXZ

 LEFT OUTER JOIN #MyAffectedTables TBLZ

 ON IDXZ.object_name = TBLZ.TableName

WHERE IDXZ.is_primary_key = 0

 AND IDXZ.is_unique_constraint = 1

 AND ( CHARINDEX(quotename(TBLZ.ColumnName) , quotename(IDXZ.index_columns_key) ) > 0

 OR CHARINDEX(quotename(TBLZ.ColumnName) , quotename(IDXZ.index_columns_key) ) > 0 )

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 DISTINCT

 600 AS ExecutionOrder,

 IDXZ.c2 AS Command

FROM #Indexes IDXZ

 LEFT OUTER JOIN #MyAffectedTables TBLZ

 ON IDXZ.object_name = TBLZ.TableName

WHERE IDXZ.is_primary_key = 0

 AND IDXZ.is_unique_constraint = 1

 AND ( CHARINDEX(quotename(TBLZ.ColumnName) , quotename(IDXZ.index_columns_key) ) > 0

 OR CHARINDEX(quotename(TBLZ.ColumnName) , quotename(IDXZ.index_columns_key) ) > 0 )

/* --#################################################################################################

--STEP_007 regular indexes(also featuring includes or filtered indexes

--################################################################################################# */

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 DISTINCT

 70 AS ExecutionOrder,

 IDXZ.c1 AS Command

FROM #Indexes IDXZ

 LEFT OUTER JOIN #MyAffectedTables TBLZ

 ON IDXZ.object_name = TBLZ.TableName

WHERE IDXZ.is_primary_key = 0

 AND IDXZ.is_unique_constraint = 0

 AND ( CHARINDEX(quotename(TBLZ.ColumnName) , quotename(IDXZ.index_columns_key) ) > 0

 OR CHARINDEX(quotename(TBLZ.ColumnName) , quotename(IDXZ.index_columns_key) ) > 0 )

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 DISTINCT

 700 AS ExecutionOrder,

 IDXZ.c2 AS Command

FROM #Indexes IDXZ

 LEFT OUTER JOIN #MyAffectedTables TBLZ

 ON IDXZ.object_name = TBLZ.TableName

WHERE IDXZ.is_primary_key = 0

 AND IDXZ.is_unique_constraint = 0

 AND ( CHARINDEX(quotename(TBLZ.ColumnName) , quotename(IDXZ.index_columns_key) ) > 0

 OR CHARINDEX(quotename(TBLZ.ColumnName) , quotename(IDXZ.index_columns_key) ) > 0 )

/* --#################################################################################################

--STEP_008 Column Collation definitions

--################################################################################################# */

INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT DISTINCT 80 AS ExecutionOrder,
 'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(objz.schema_id)) + '.' + QUOTENAME(objz.name) + ' ALTER COLUMN '

 + CASE

 WHEN colz.[is_computed] = 0
  THEN QUOTENAME(colz.[name]) + ' ' + ( TYPE_NAME(colz.[user_type_id]) )

 + CASE

 WHEN TYPE_NAME(colz.[user_type_id]) IN ( 'char', 'varchar' )

 THEN

 CASE
  WHEN colz.[max_length] = -1
  THEN '(max)' + SPACE(6 - LEN(CONVERT(VARCHAR, colz.[max_length]))) + SPACE(7) + SPACE(16 - LEN(TYPE_NAME(colz.[user_type_id])))

 /*----collate to comment out when not desired */

 + CASE
  WHEN colz.collation_name IS NULL THEN ''
  ELSE ' COLLATE ' + @NewCollation -- this was the old collation: colz.collation_name
   END
 
 + CASE
  WHEN colz.[is_nullable] = 0  THEN ' NOT NULL'
   ELSE ' NULL'
    END

 ELSE '(' + CONVERT(VARCHAR, colz.[max_length] ) + ') ' + SPACE(6 - LEN(CONVERT(VARCHAR, colz.[max_length]))) + SPACE(7) + SPACE(16 - LEN(TYPE_NAME(colz.[user_type_id])))

 /* ----collate to comment out when not desired */

 + CASE
  WHEN colz.collation_name IS NULL THEN ''
   ELSE ' COLLATE ' + @NewCollation
    END

 + CASE
  WHEN colz.[is_nullable] = 0 THEN ' NOT NULL'
   ELSE ' NULL'
    END

 END

 WHEN TYPE_NAME(colz.[user_type_id]) IN ( 'nchar', 'nvarchar' )

 THEN

 CASE

 WHEN colz.[max_length] = -1

 THEN '(max)' + SPACE(6 - LEN(CONVERT(VARCHAR, (colz.[max_length] / 2)))) + SPACE(7) + SPACE(16 - LEN(TYPE_NAME(colz.[user_type_id])))

 ----collate to comment out when not desired

 + CASE

 WHEN colz.collation_name IS NULL THEN ''
  ELSE ' COLLATE ' + @NewCollation -- this was the old collation: colz.collation_name
   END

 + CASE

 WHEN colz.[is_nullable] = 0 THEN ' NOT NULL'
  ELSE ' NULL'
   END

 ELSE '(' + CONVERT(VARCHAR, (colz.[max_length] / 2)) + ') ' + SPACE(6 - LEN(CONVERT(VARCHAR, (colz.[max_length])))) + SPACE(7) + SPACE(16 - LEN(TYPE_NAME(colz.[user_type_id])))

 + CASE

 WHEN colz.collation_name IS NULL THEN ''
  ELSE ' COLLATE ' + @NewCollation -- this was the old collation: colz.collation_name
   END

 + CASE
  WHEN colz.[is_nullable] = 0 THEN ' NOT NULL'
   ELSE ' NULL'

 END

 END

 END

 END --iscomputed = 0

 + ';' AS Command

FROM sys.columns colz

 LEFT OUTER JOIN sys.tables objz

 ON colz.object_id = objz.object_id

INNER JOIN #MyAffectedTables tabz

ON tabz.object_id = colz.object_id

 AND tabz.column_id = colz.column_id

WHERE objz.type = 'U'

 AND TYPE_NAME(colz.[user_type_id]) IN ( 'char', 'varchar', 'nchar', 'nvarchar' )

/* --#################################################################################################
--STEP_009 refresh dependent views, procs and functions
-- refresh them in dependancy order in a single pass.
--################################################################################################# */


IF OBJECT_ID(N'tempdb..#MyObjectHierarchy') IS NOT NULL
BEGIN
 DROP TABLE #MyObjectHierarchy 
 END

IF EXISTS(SELECT * FROM #Results WHERE ExecutionOrder > 0)

 BEGIN

 CREATE TABLE #MyObjectHierarchy
 (

HID int identity(1,1) not null primary key,
NAME varchar(255),
objecttype varchar(255)

 )

--our list of objects in dependancy order
 
declare @RowNums int, @RowIds INT, @tabzschema varchar(5),@tabztable nvarchar(255),@tabzobject nvarchar(255)

SELECT @RowIds=MAX(tabz.Tid) FROM #MyAffectedTables tabz     --start with the highest ID
SELECT @RowNums = Count(*) From #MyAffectedTables tabz    --get total number of records
WHILE @RowNums > 0                          --loop until no more records
BEGIN   
    SELECT @tabzschema = tabz.SchemaName FROM #MyAffectedTables tabz where tabz.Tid = @RowIds 
	SELECT @tabztable = tabz.TableName FROM #MyAffectedTables tabz where tabz.Tid = @RowIds    
	set @tabzobject = N''+@tabzschema + '.' + @tabztable+''
	IF EXISTS(SELECT top 1 * FROM sys.sql_expression_dependencies WHERE referenced_id = OBJECT_ID(N''+ QUOTENAME(@tabzschema) + '.' + QUOTENAME(@tabztable)+'')) -- outputcheck of dependicies
	BEGIN
		INSERT INTO #MyObjectHierarchy (name,objecttype)
		EXEC sp_depends @objname = @tabzobject
	END
	select top 1 @RowIds=tabz.Tid from #MyAffectedTables tabz where tabz.Tid < @RowIds order by tabz.Tid desc--get the next one
    set @RowNums = @RowNums - 1                          --decrease count
END
INSERT INTO #Results

 (ExecutionOrder,Command)

SELECT

 900 + HID AS ExecutionOrder,

 CASE

 WHEN OBJECTTYPE = 'VIEW'

 THEN 'EXEC sp_refreshview ' + QUOTENAME(name) +';'

 WHEN OBJECTTYPE IN ('FUNCTION' ,'PROCEDURE')

 THEN 'EXEC sp_recompile ' + QUOTENAME(name) +  ';'

 END

FROM #MyObjectHierarchy

WHERE OBJECTTYPE IN('FUNCTION','VIEW','PROCEDURE')

ORDER BY HID

 END --Exists 
 /*
--#################################################################################################

--Final Presentation

--#################################################################################################

SELECT

 ID,ExecutionOrder,Command + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)

FROM #Results

ORDER BY

 ExecutionOrder,

 ID
 */
/*--#################################################################################################
-- uncomment the --exec(@isql) in cursor c1  below to actually run the commands or just copy the commands from Message 
-- don't run this cursor unless you are 100% sure of the scripts.
-- take a backup of the database and TEST TEST TEST!
--################################################################################################# */

DECLARE @isql nvarchar(max)
DECLARE c1 CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY for
SELECT Command
 FROM #Results
 ORDER BY
 ExecutionOrder,
 ID

 open c1
 fetch next from c1 into @isql
 While @@fetch_status <> -1
BEGIN
 print @isql
--exec(@isql)
 fetch next from c1 into @isql
END
 close c1
 deallocate c1

 
