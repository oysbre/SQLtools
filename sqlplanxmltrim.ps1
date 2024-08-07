<# trim XML to get compiled/runtime parameter values from SQL plan #>
<# paste Parameterlist in the XML variable string below #>
$xml = @"

         <ParameterList>
            
                  <ColumnReference Column="@P3" ParameterDataType="nvarchar(8)" ParameterCompiledValue="N'test'" />
                  <ColumnReference Column="@P2" ParameterDataType="nvarchar(8)" ParameterCompiledValue="N'test'" />
                  <ColumnReference Column="@P1" ParameterDataType="nvarchar(8)" ParameterCompiledValue="N'test'" />
            
"@

$compiled  = ""
$runtime  = ""

if ($xml -match "ParameterRuntimeValue"){
write-host ""
write-host "Runtime values" -ForegroundColor Yellow
$runtime = $xml -replace(" ","") -replace "<ParameterList>","" -replace "</ParameterList>","" -replace '<ColumnReferenceColumn="',"" -replace 'ParameterDataType="(.*?)"',"" -replace '"ParameterCompiledValue="N''(.*?)''',"" -replace '"ParameterCompiledValue="\((.*?)\)',""  -replace '"ParameterRuntimeValue="',"=" -replace ('"/>',",") -replace ('\(',"") -replace ('\)',"") -replace ".$"  -replace("`n","") -replace("`r","")
[array]$valuesarray = $runtime.split(',')
[array]::reverse($valuesarray)
[string]$runtime = $valuesarray -join ','
$runtime = $runtime -replace ("^,","")
$runtime = $runtime +"',"
$runtime = $runtime.Insert(0,",N'")
$runtime
}

write-host ""
write-host "Compiled Values" -ForegroundColor Yellow
$compiled = $xml -replace(" ","") -replace "<ParameterList>","" -replace "</ParameterList>",""  -replace '<ColumnReferenceColumn="',"" -replace 'ParameterDataType="(.*?)"',"" -replace '"ParameterRuntimeValue="N''(.*?)''',"" -replace '"ParameterRuntimeValue="\((.*?)\)',""  -replace '"ParameterCompiledValue="',"=" -replace ('"/>',",") -replace ('\(',"") -replace ('\)',"") -replace ".$"  -replace("`n","") -replace("`r","")
[array]$paramarray = $compiled.split(',')
[array]::reverse($paramarray)
[string]$compiled = $paramarray -join ','
$compiled = $compiled -replace ("^,","")
$compiled = $compiled +"',"
$compiled = $compiled.Insert(0,",N'")
$compiled

