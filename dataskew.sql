/* check num of rows in INVENTDIM for each dataareaid with i LOCATIONID to determine dataskew in table */
SELECT dataareaid, inventlocationid, COUNT(*) AS numof_rows 
FROM dbo.inventdim
GROUP BY inventlocationid, DATAAREAID
ORDER BY numof_rows desc;
