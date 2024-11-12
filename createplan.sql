/* create a planguide for queries forcing HINTS */
/* user NULL to remove FAST option in query, FORCE ORDER to use tables in the order the query is in, RECOMPILE only if generating new plan is light and don't run too often */
/* OPTIMIZE FOR is used when there is DATASKEW in tables */
EXEC sp_create_plan_guide
@name = N'INVENTDIM_Perfxxxx_fix',
@stmt = N'SELECT A.SALESID,A.SALESNAME,A.RESERVATION,A.CUSTACCOUNT,A.INVOICEACCOUNT,A.DELIVERYDATE,A.DELIVERYADDRESS,A.URL,A.PURCHORDERFORMNUM,A.SALESTAKER,A.SALESGROUP,A.FREIGHTSLIPTYPE,A.DOCUMENTSTATUS,A.INTERCOMPANYORIGINALSALESID,A.CURRENCYCODE,A.PAYMENT,A.CASHDISC,A.TAXGROUP,A.LINEDISC,A.CUSTGROUP,A.DISCPERCENT,A.INTERCOMPANYORIGINALCUSTACCO22,A.DIMENSION,A.DIMENSION2_,A.DIMENSION3_,A.PRICEGROUPID,A.MULTILINEDISC,A.ENDDISC,A.CUSTOMERREF,A.LISTCODE,A.DLVTERM,A.DLVMODE,A.PURCHID,A.SALESSTATUS,A.MARKUPGROUP,A.SALESTYPE,A.SALESPOOLID,A.POSTINGPROFILE,A.TRANSACTIONCODE,A.INTERCOMPANYAUTOCREATEORDERS,A.INTERCOMPANYDIRECTDELIVERY,A.INTERCOMPANYDIRECTDELIVERYORIG,A.DELIVERYZIPCODE,A.DELIVERYCOUNTY,A.DELIVERYCOUNTRYREGIONID,A.SETTLEVOUCHER,A.DELIVERYSTATE,A.INTERCOMPANYALLOWINDIRECTCRE48,A.INTERCOMPANYALLOWINDIRECTCRE49,A.DELIVERYNAME,A.ONETIMECUSTOMER,A.COVSTATUS,A.COMMISSIONGROUP,A.PAYMENTSCHED,A.INTERCOMPANYORIGIN,A.EMAIL,A.FREIGHTZONE,A.RETURNITEMNUM,A.CASHDISCPERCENT,A.CONTACTPERSONID,A.DEADLINE,A.PROJID,A.INVENTLOCATIONID,A.ADDRESSREFTABLEID,A.VATNUM,A.PORT,A.INCLTAX,A.EINVOICELINESPEC,A.NUMBERSEQUENCEGROUP,A.FIXEDEXCHRATE,A.LANGUAGEID,A.AUTOSUMMARYMODULETYPE,A.GIROTYPE,A.SALESORIGINID,A.ESTIMATE,A.TRANSPORT,A.PAYMMODE,A.PAYMSPEC,A.FIXEDDUEDATE,A.DELIVERYCITY,A.DELIVERYSTREET,A.EXPORTREASON,A.STATPROCID,A.BANKCENTRALBANKPURPOSETEXT,A.INTERCOMPANYCOMPANYID,A.INTERCOMPANYPURCHID,A.INTERCOMPANYORDER,A.DLVREASON,A.QUOTATIONID,A.RECEIPTDATEREQUESTED,A.RECEIPTDATECONFIRMED,A.SHIPPINGDATEREQUESTED,A.SHIPPINGDATECONFIRMED,A.BANKCENTRALBANKPURPOSECODE,A.EINVOICEACCOUNTCODE,A.ITEMTAGGING,A.CASETAGGING,A.PALLETTAGGING,A.ADDRESSREFRECID,A.CUSTINVOICEID,A.INVENTSITEID,A.CREDITCARDCUSTREFID,A.SHIPCARRIERACCOUNT,A.SHIPCARRIERID,A.SHIPCARRIERFUELSURCHARGE,A.SHIPCARRIERBLINDSHIPMENT,A.CREDITCARDPROCESSORTRANSACT140,A.SHIPCARRIERDELIVERYCONTACT,A.CREDITCARDAPPROVALAMOUNT,A.CREDITCARDAUTHORIZATION,A.RETURNDEADLINE,A.RETURNREPLACEMENTID,A.RETURNSTATUS,A.RETURNREASONCODEID,A.CREDITCARDAUTHORIZATIONERROR,A.SHIPCARRIERACCOUNTCODE,A.RETURNREPLACEMENTCREATED,A.SHIPCARRIERDLVTYPE,A.ATPINCLPLANNEDORDERS,A.ATPTIMEFENCE,A.DELIVERYDATECONTROLTYPE,A.SHIPCARRIEREXPEDITEDSHIPMENT,A.SHIPCARRIERRESIDENTIAL,A.CASHDISCBASEDATE,A.CASHDISCBASEDAYS,A.CFDICREDITREFINVOICE_MX,A.DIRECTDEBITMANDATE,A.ENTRYCERTIFICATEREQUIRED_W,A.ISSUEOWNENTRYCERTIFICATE_W,A.SALESRESPONSIBLE,A.SALESUNITID,A.SMMSALESAMOUNTTOTAL,A.SMMCAMPAIGNID,A.EO_DELIVERYPERYEAR,A.EO_SALESDLVID,A.EO_REST,A.EO_ORDERREMARKEXTERNAL,A.EO_ORDERREMARKINTERNAL,A.EO_PRIORITYDLVTIME,A.EO_NUMOFLINES,A.EO_VOLUME,A.EO_NEWITEMREQ,A.EO_PRIORITYCODE,A.EO_ORDERREADY,A.EO_PRIORITYORDER,A.EO_PRIORITYWATCHORDER,A.EO_TRANSPORTERNOTE,A.EO_RECEIVERNOTE,A.EO_PHONE,A.EO_WINEDIDOCPRINTED,A.EO_WINEDIDOCPRINTED2_,A.EO_WINEDIDOCPRINTED3_,A.EO_WHOLESALEORDER,A.EO_CUSTNOINCHAIN,A.EO_INVOICETYPE,A.EO_NORCARGO,A.EO_EDISETUPEXIST,A.EO_EANLOCATIONCONFIRM,A.EO_EANLOCATIONPACKINGSLIP,A.EO_EANLOCATIONINVOICE,A.EO_EDIDOCTYPECONFIRM,A.EO_EDIDOCTYPEPACKINGSLIP,A.EO_EDIDOCTYPEINVOICE,A.EO_EDINUMBERID,A.EO_TRANSITNUMID,A.EO_ORDERPLACER,A.EO_ORDERDATE,A.EO_CUSTOMSTRANSITID,A.EO_CUSTOMSTRANSITAPPROVED,A.EO_COUNTORDER,A.EO_TVINNSTATUS,A.EO_SALESBALANCE,A.EO_AUTOORDER,A.EO_DELIVERYCOUNTRYTVINN,A.EO_NETCOMMERCEWEBID,A.EO_AUTOCONFIRM,A.EO_CONFIRMED,A.EO_EDICODE,A.EO_RECLAMATIONID,A.EO_RECLAMATION,A.EO_ORDERINVOICEREADYID,A.EO_CUSTOMERTVINNPROCEDURECODE,A.EO_SALESCALENDARID,A.EO_TRANSPORTROUTEID,A.EO_TRIP,A.EO_POSITION,A.EO_DELIVERYFREQUENCETYPE,A.EO_WMSNUMBEROFICPICKINGLISTS,A.EO_NETCOMMERCEMESSAGEEXISTS,A.EO_AUTOMATICAPPROVAL,A.EO_ORDERPROCESSTYPE,A.EO_STATUSCREDIT,A.EO_REMARK,A.EO_WEBUSER,A.EO_WMSPRINTPACKINGSLIP,A.EO_WMSCONTENTLABEL,A.EO_WMSRETURNTRANSFERRED,A.EO_WMSPACKAGINGMATERIALID,A.EO_WMSPRIORITY,A.EO_WMSREFUSEALTITEM,A.EO_WMSREFUSEREDUCTION,A.EO_EXTENDINDUSTRYSOEXTEND,A.EO_WMSNOCOLLECTPICK,A.EO_ORDERNAME,A.EO_ORDERDELIVERYNAME,A.EO_ORDERINVOICENAME,A.EO_ORDERDELIVERYGLN,A.EO_ORDEREMAIL,A.EO_ORDERPHONE,A.MODIFIEDBY,A.CREATEDDATETIME,A.CREATEDBY,A.RECVERSION,A.RECID,B.SALESID,B.LINENUM,B.ITEMID,B.SALESSTATUS,B.LEDGERACCOUNT,B.NAME,B.EXTERNALITEMID,B.TAXGROUP,B.QTYORDERED,B.SALESDELIVERNOW,B.REMAINSALESPHYSICAL,B.REMAINSALESFINANCIAL,B.COSTPRICE,B.SALESPRICE,B.CURRENCYCODE,B.LINEPERCENT,B.LINEDISC,B.LINEAMOUNT,B.CONFIRMEDDLV,B.RESERVATION,B.SALESGROUP,B.SALESUNIT,B.DIMENSION,B.DIMENSION2_,B.DIMENSION3_,B.PRICEUNIT,B.PROJTRANSID,B.INVENTTRANSID,B.CUSTGROUP,B.CUSTACCOUNT,B.SALESQTY,B.SALESMARKUP,B.INVENTDELIVERNOW,B.MULTILNDISC,B.MULTILNPERCENT,B.SALESTYPE,B.BLOCKED,B.COMPLETE,B.REMAININVENTPHYSICAL,B.TRANSACTIONCODE,B.TAXITEMGROUP,B.TAXAUTOGENERATED,B.UNDERDELIVERYPCT,B.OVERDELIVERYPCT,B.BARCODE,B.BARCODETYPE,B.INVENTREFTRANSID,B.INVENTREFTYPE,B.INVENTREFID,B.INTERCOMPANYORIGIN,B.ITEMBOMID,B.LINEHEADER,B.SCRAP,B.DLVMODE,B.INVENTTRANSIDRETURN,B.PROJCATEGORYID,B.PROJID,B.INVENTDIMID,B.TRANSPORT,B.STATPROCID,B.PORT,B.PROJLINEPROPERTYID,B.RECEIPTDATEREQUESTED,B.CUSTOMERLINENUM,B.PACKINGUNITQTY,B.PACKINGUNIT,B.INTERCOMPANYINVENTTRANSID,B.REMAININVENTFINANCIAL,B.DELIVERYADDRESS,B.DELIVERYNAME,B.DELIVERYSTREET,B.DELIVERYZIPCODE,B.DELIVERYCITY,B.DELIVERYCOUNTY,B.DELIVERYSTATE,B.DELIVERYCOUNTRYREGIONID,B.DELIVERYTYPE,B.CUSTOMERREF,B.PURCHORDERFORMNUM,B.RECEIPTDATECONFIRMED,B.BLANKETREFTRANSID,B.STATTRIANGULARDEAL,B.SHIPPINGDATEREQUESTED,B.SHIPPINGDATECONFIRMED,B.ADDRESSREFRECID,B.ADDRESSREFTABLEID,B.ITEMTAGGING,B.CASETAGGING,B.PALLETTAGGING,B.EINVOICEACCOUNTCODE,B.SHIPCARRIERID,B.SHIPCARRIERACCOUNT,B.SHIPCARRIERDLVTYPE,B.SHIPCARRIERACCOUNTCODE,B.DELIVERYDATECONTROLTYPE,B.ATPINCLPLANNEDORDERS,B.ATPTIMEFENCE,B.ACTIVITYNUMBER,B.RETURNALLOWRESERVATION,B.ITEMREPLACED,B.RETURNDEADLINE,B.EXPECTEDRETQTY,B.RETURNSTATUS,B.RETURNARRIVALDATE,B.RETURNCLOSEDDATE,B.RETURNDISPOSITIONCODEID,B.EO_PRIMARYVENDID,B.EO_PRODUCER,B.EO_ORDERLINEORIGINID,B.EO_PROVIDABLEITEM,B.EO_BREAKADDITIONAMOUNT,B.EO_ORIGQTY,B.EO_SALESDLVID,B.EO_RECSALESPRICE,B.EO_REST,B.EO_REASONCODEID,B.EO_DISCREINFORCEPCT,B.EO_DISCREINFORCEAMOUNT,B.EO_DISCREINFORCEDISCAMOUNT,B.EO_DISCREINFORCEVENDACCOUNT,B.EO_PRICEAGREEMENTID,B.EO_ORDERREADYPICKING,B.EO_PHONE,B.EO_TRANSPORTERNOTE,B.EO_RECEIVERNOTE,B.EO_WHOLEPACKAGEAMOUNT,B.EO_WHOLESALEORDER,B.EO_DISCREINFORCEREFUND,B.EO_BONUSCODE,B.EO_QTYINPACKAGE,B.EO_CUSTEDINUMBERID,B.EO_ORIGSALESRECEIPTDATECO30027,B.EO_CUSTLINEDISCCODE,B.EO_REGISTEREDQTYINPACKAGE,B.EO_MULTILNPERCENT,B.EO_INTERPRET,B.EO_HISTORICFPACKINDPACK,B.EO_PICKINGERROR,B.EO_MISCITEM,B.EO_REASONCODEPICKING,B.EO_ATTACHRECID,B.EO_ORIGITEMID,B.EO_CREATEDFROMWMS,B.EO_NOTINPICKINGERRORSTATISTICS,B.EO_CHILDRECID,B.EO_NOTES,B.EO_MISCITEMSALESPRICE,B.EO_MISCITEMCOSTPRICE,B.EO_BREAKADDITIONMULTIPLE,B.EO_NOENDDISC,B.EO_CROSSDOCKSTOCK,B.EO_EXTERNALORDERID,B.EO_ASSORTMENTID,B.EO_DISCREFUND,B.EO_DISCREFUNDAMOUNT,B.EO_DISCREFUNDPCT,B.EO_CALCREFUNDAMOUNT,B.EO_ITEMCATEGORY,B.EO_ALTSALESQTY,B.EO_ALTSALESUNIT,B.EO_AGREEMENTMARK,B.EO_PRICEADDON,B.EO_WMSAFTERPICKPERMITTED,B.EO_EXTENDINDUSTRYSOORIG,B.EO_DEPOSITLINERECID,B.MODIFIEDDATETIME,B.MODIFIEDBY,B.CREATEDDATETIME,B.CREATEDBY,B.RECVERSION,B.RECID,C.INVENTDIMID,C.INVENTBATCHID,C.WMSLOCATIONID,C.INVENTSERIALID,C.INVENTLOCATIONID,C.CONFIGID,C.INVENTSIZEID,C.INVENTCOLORID,C.INVENTSITEID,C.RECVERSION,C.RECID FROM SALESTABLE A,SALESLINE B,INVENTDIM C WHERE ((A.DATAAREAID=N''d05'') AND ((((A.SALESID>@P1) AND (A.SALESORIGINID=@P2)) AND (A.EO_CONFIRMED=@P3)) AND (A.EO_AUTOCONFIRM=@P4))) AND ((B.DATAAREAID=N''d05'') AND ((B.BLOCKED=@P5) AND (A.SALESID=B.SALESID))) AND ((C.DATAAREAID=N''d05'') AND (B.INVENTDIMID=C.INVENTDIMID)) ORDER BY B.DATAAREAID,B.SALESID,B.LINENUM OPTION(FAST 1)',
@type = N'SQL',
@module_or_batch = NULL,
@params = N'@P1 nvarchar(21),@P2 nvarchar(11),@P3 int,@P4 int,@P5 int',
@hints = NULL
--@hints = N'OPTION (FORCE ORDER)'
--@hints = N'OPTION (RECOMPILE)'
--@hints = N'OPTION (OPTIMIZE FOR(@P1=N''))'
GO
