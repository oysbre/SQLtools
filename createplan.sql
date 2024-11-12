/* create a planguide for queries forcing HINTS */
/* user NULL to remove FAST option in query, FORCE ORDER to use tables in the order the query is in, RECOMPILE only if generating new plan is light and don't run too often */
/* OPTIMIZE FOR is used when there is DATASKEW in tables */
EXEC sp_create_plan_guide @name = N'[AX_InventItemPriceDimSite]',
@stmt = N'SELECT A.ITEMID,A.VERSIONID,A.PRICETYPE,A.INVENTDIMID,A.MARKUP,A.PRICEUNIT,A.PRICE,A.PRICECALCID,A.UNITID,A.PRICEALLOCATEMARKUP,A.PRICEQTY,A.STDCOSTTRANSDATE,A.STDCOSTVOUCHER,A.COSTINGTYPE,A.ACTIVATIONDATE,A.MCSPMFBATCHSIZE,A.CREATEDDATETIME,A.RECVERSION,A.RECID FROM INVENTITEMPRICE A WHERE ((A.DATAAREAID=@P1) AND (((A.ITEMID=@P2) AND (A.PRICETYPE=@P3)) AND (A.ACTIVATIONDATE>@P4))) AND EXISTS (SELECT ''x'' FROM INVENTDIM B WHERE ((B.DATAAREAID=@P5) AND ((B.INVENTDIMID=A.INVENTDIMID) AND (B.INVENTSITEID=@P6)))) ORDER BY A.DATAAREAID,A.ACTIVATIONDATE,A.CREATEDDATETIME DESC',
@type = N'SQL',
@module_or_batch = null,
@params = N'@P1 nvarchar(5),@P2 nvarchar(21),@P3 int,@P4 datetime,@P5 nvarchar(5),@P6 nvarchar(11)',
@hints = NULL
--@hints = N'OPTION (FORCE ORDER)'
--@hints = N'OPTION (RECOMPILE)'
--@hints = N'OPTION (OPTIMIZE FOR(@P1=N''))'
GO
