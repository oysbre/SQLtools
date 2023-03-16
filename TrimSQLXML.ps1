<#PSscript to trim SQL Plan XML to get compiled parameter values. Used for testing queries. #>
<#Search, copy and paste Parameterlist in the XML variable herestring below #>

$xml = @"
<ColumnReference Column="@P4" ParameterDataType="datetime" ParameterCompiledValue="'2023-03-31 00:00:00.000'" />
<ColumnReference Column="@P3" ParameterDataType="datetime" ParameterCompiledValue="'2023-03-01 00:00:00.000'" />
<ColumnReference Column="@P2" ParameterDataType="nvarchar(42)" ParameterCompiledValue="N'somevalue'" />
<ColumnReference Column="@P1" ParameterDataType="nvarchar(8)" ParameterCompiledValue="N'datareaid'" />
"@

$params = ""
$params = $xml -replace(" ","")
$params = $params -replace ('<ColumnReferenceColumn="',"")
$params = $params -replace ('"ParameterDataType="'," ")
$params = $params -replace ('"ParameterCompiledValue="(.*?)"/>',",")

$params = $params.replace("`n","").replace("`r","")
[array]$paramarray = $params.split(',')
[array]::reverse($paramarray)
[string]$params = $paramarray -join ','
$params = $params -replace ("^,","")
$params = $params +"',"
$params = $params.Insert(0,",N'")
$params

write-host ""

$values = $xml -replace ('<ColumnReference Column="',"")
#$values = $values -replace ('" ParameterDataType="nvarchar(.*?)" ParameterCompiledValue="',"=")
$values = $values -replace ('" ParameterDataType="(.*?)" ParameterCompiledValue="',"=")
$values = $values -replace ('" ParameterCompiledValue="',"=")
$values = $values -replace ('" />',",")
$values = $values -replace ".$"
$values = $values -replace ('\(',"")
$values = $values -replace ('\)',"")
$values=$values.Trim()
$values = ($values -split ','|Sort) -Join ','
#$values = $values -replace (" ","")

$values
