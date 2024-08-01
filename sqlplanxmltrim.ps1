<# Powershell script to trim XML to get compiled/runtime parameter values from SQL plan #>
<# used for testing queries with sp_executesql #>
<# copy&paste Parameterlist from SQL XML plan in the XML variable string below #>
$xml = @"

                  <ColumnReference Column="@P3" ParameterDataType="nvarchar(8)" ParameterCompiledValue="N'test'" />
                  <ColumnReference Column="@P2" ParameterDataType="nvarchar(8)" ParameterCompiledValue="N'test'" />
                  <ColumnReference Column="@P1" ParameterDataType="nvarchar(8)" ParameterCompiledValue="N'test'" />
"@
write-host ""
$compiled  = ""
$runtime  = ""

if ($xml -match "ParameterRuntimeValue"){

write-host "Runtime values"
$runtime = $xml -replace(" ","") -replace '<ColumnReferenceColumn="',"" -replace '"ParameterCompiledValue="N''(.*?)''',"" -replace '"ParameterCompiledValue="\((.*?)\)',""  -replace '"ParameterRuntimeValue="',"=" -replace ('"/>',",") -replace ('\(',"") -replace ('\)',"") -replace ".$"  -replace("`n","") -replace("`r","")
[array]$valuesarray = $runtime.split(',')
[array]::reverse($valuesarray)
[string]$runtime = $valuesarray -join ', '
$runtime = $runtime -replace ("^,","")
$runtime = $runtime +"',"
$runtime = $runtime.Insert(0,",N'")
$runtime
}
write-host ""
if ($xml -match "ParameterDataType"){
write-host "Compiled Values"
$compiled = $xml -replace(" ","") -replace '<ColumnReferenceColumn="',"" -replace 'ParameterDataType="(.*?)"',"" -replace '"ParameterRuntimeValue="N''(.*?)''',"" -replace '"ParameterRuntimeValue="\((.*?)\)',""  -replace '"ParameterCompiledValue="',"=" -replace ('"/>',",") -replace ('\(',"") -replace ('\)',"") -replace ".$"  -replace("`n","") -replace("`r","")
[array]$paramarray = $compiled.split(',')
[array]::reverse($paramarray)
[string]$compiled = $paramarray -join ', '
$compiled = $compiled -replace ("^,","")
$compiled = $compiled +"',"
$compiled = $compiled.Insert(0,",N'")
$compiled
}
else {
write-host "Compiled Values"
$compiled = $xml -replace(" ","") -replace '<ColumnReferenceColumn="',"" -replace '"ParameterRuntimeValue="N''(.*?)''',"" -replace '"ParameterRuntimeValue="\((.*?)\)',""  -replace '"ParameterCompiledValue="',"=" -replace ('"/>',",") -replace ('\(',"") -replace ('\)',"") -replace ".$"  -replace("`n","") -replace("`r","")
[array]$paramarray = $compiled.split(',')
[array]::reverse($paramarray)
[string]$compiled = $paramarray -join ', '
$compiled = $compiled -replace ("^,","")
$compiled = $compiled +"',"
$compiled = $compiled.Insert(0,",N'")
$compiled
}


