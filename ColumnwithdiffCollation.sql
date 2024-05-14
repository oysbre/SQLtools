/* list columns in tables that are using other collation than default Microsoft collation "SQL_Latin1_General_CP1_CI_AS" */
SELECT 
    t.Name AS 'Table Name',
    c.name AS 'Column Name',
	ty.name AS 'Type Name',
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
    AND  ty.name IN ('nvarchar','varchar')
   AND c.collation_name not in ('SQL_Latin1_General_CP1_CI_AS','Latin1_General_BIN')
	
