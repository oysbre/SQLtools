<# trim XML to get compiled/runtime parameter values from SQL plan #>
<# paste Parameterlist in the XML variablestring below #>

$xml = @"
 <ColumnReference Column="@now" ParameterDataType="datetime" ParameterCompiledValue="'2025-08-17 04:33:27.000'" ParameterRuntimeValue="'2025-09-08 08:31:46.000'" />
              <ColumnReference Column="@period" ParameterDataType="varchar(max)" ParameterCompiledValue="'CurrentWeek'" ParameterRuntimeValue="'CurrentOrder'" />
              <ColumnReference Column="@prodPlace_Ids" ParameterDataType="varchar(max)" ParameterCompiledValue="'90'" ParameterRuntimeValue="'153'" />
"@


#--BEGIN --#
$compiled  = ""
$runtime  = ""
cls
if ($xml -match "ParameterRuntimeValue"){
write-host ""
write-host "Runtime values" -ForegroundColor Yellow
$runtime = $xml -replace "<ParameterList>","" -replace "</ParameterList>","" -replace '[ ]+<ColumnReference Column="',"" -replace '[ ]+ParameterDataType="(.*?)"',"" -replace '"[ ]+ParameterCompiledValue="[N]?''(.*?)''',"" -replace '"[ ]+ParameterCompiledValue="\((.*?)\)',""  -replace '"[ ]+ParameterRuntimeValue="',"=" -replace ('"[ ]+/>',",") -replace ('[ ]+\(',"") -replace ('[ ]+\)',"") -replace ".$"  -replace("`n","") -replace("`r","")
[array]$runtimearray = $runtime.split(',')
[array]::reverse($runtimearray)
[string]$runtime = $runtimearray -join ','
$runtime = $runtime -replace ("^,","")
$runtime = $runtime -replace ("^\s+,","")
$runtime = $runtime -replace ("^,","")
$runtime = $runtime +"',"
$runtime = $runtime.Insert(0,",N'")

#$runtime = $runtime -replace ("00:00:00.000","")
$runtime
write-host ""
}

write-host ""
write-host "Compiled Values" -ForegroundColor Yellow
$compiled = $xml -replace "<ParameterList>","" -replace "</ParameterList>",""  -replace '[ ]+<ColumnReference Column="',"" -replace '[ ]+ParameterDataType="(.*?)"',"" -replace '"[ ]+ParameterRuntimeValue="[N]?''(.*?)''',"" -replace '"[ ]+ParameterRuntimeValue="\((.*?)\)',""  -replace '"[ ]+ParameterCompiledValue="',"=" -replace ('"[ ]+/>',",") -replace ('[ ]+\(',"") -replace ('[ ]+\)',"") -replace ".$"  -replace("`n","") -replace("`r","")  
[array]$compiledarray = $compiled.split(',')
[array]::reverse($compiledarray)
[string]$compiled = $compiledarray -join ','
$compiled = $compiled -replace ("^,","")
$compiled = $compiled -replace ("^\s+,","")
$compiled = $compiled -replace ("^,","")
$compiled = $compiled +"',"
$compiled = $compiled.Insert(0,",N'")
#$compiled = $compiled -replace ("00:00:00.000","")
$compiled
write-host ""



