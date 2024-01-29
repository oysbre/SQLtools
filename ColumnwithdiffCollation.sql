/* list columns in tables that are using other collation than default Microsoft collation "SQL_Latin1_General_CP1_CI_AS" */
SELECT 
    t.Name 'Table Name',
    c.name 'Column Name',
    ty.name 'Type Name',
    c.collation_name,
    c.is_nullable,
  CASE WHEN c.collation_name <> 'SQL_Latin1_General_CP1_CI_AS' THEN 'Column must convert to collation "SQL_Latin1_General_CP1_CI_AS"'  
  END AS Action
FROM 
    sys.columns c 
INNER JOIN 
    sys.tables t ON c.object_id = t.object_id
INNER JOIN 
    sys.types ty ON c.system_type_id = ty.system_type_id    
WHERE 
    t.is_ms_shipped = 0	
    AND ty.name <> 'sysname'
   AND (c.collation_name <> 'SQL_Latin1_General_CP1_CI_AS' )
	AND (c.collation_name <> 'Latin1_General_BIN')
	
