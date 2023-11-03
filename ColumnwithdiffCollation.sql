/* list columns using other collation than the database */
SELECT 
    t.Name AS [Tablename],
    c.name AS [ColumnName],
    ty.name AS [TypeNam]e,
    c.collation_name AS [Collation]
FROM 
    sys.columns c 
INNER JOIN 
    sys.tables t ON c.object_id = t.object_id
INNER JOIN 
    sys.types ty ON c.system_type_id = ty.system_type_id    
WHERE 
    t.is_ms_shipped = 0 AND ty.name <> 'sysname'   AND  c.collation_name <> 'SQL_Latin1_General_CP1_CI_AS')
	
