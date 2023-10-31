/* list columns using other collation than the database */
SELECT 
    t.Name 'Table Name',
    c.name 'Column Name',
    ty.name 'Type Name',
    c.collation_name,
    c.is_nullable
FROM 
    sys.columns c 
INNER JOIN 
    sys.tables t ON c.object_id = t.object_id
INNER JOIN 
    sys.types ty ON c.system_type_id = ty.system_type_id    
WHERE 
    t.is_ms_shipped = 0 AND ty.name <> 'sysname'
    AND  EXISTS (select 1 from sys.databases d  where d.collation_name <> c.collation_name)
	
