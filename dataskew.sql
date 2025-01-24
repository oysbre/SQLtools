/* Check dataskew in a table, example below is for AX database */
/* check num of rows in INVENTDIM for each dataareaid with INVENTLOCATIONID to determine dataskew in table */
SELECT dataareaid, inventlocationid, COUNT(*) AS numof_rows 
FROM dbo.inventdim
GROUP BY inventlocationid, DATAAREAID
ORDER BY numof_rows DESC;
