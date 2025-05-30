#Restore SQL database 

#---- Set variables ------
$SQLsrvName = 'localhost' #<-- if using named instance, set variable like: 'localhost\sqlexpress'
$RestoreDatabase ='axdb_copy'
$BAKpath = "FileSystem::C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup" #<-- make sure this path ONLY contains backupfiles of the database that is going to be restored!
$TRNpath = "FileSystem::\\<uncpath_to_TRN>" #<-- make sure this path ONLY contains Transaction files of the database that is going to be restored!
#-------END VARIABLES. Do not change anything below this line -----

$simpleRecoveryMode = read-host "Restore database with [F]ULL or [S]imple Recovery mode?"
$cmplvlcheck = read-host "If Compatibilty mode of the restored database is lower than SQL instance, upgrade? (Y/N)"
$dateadd = get-date -f "yyyyMMMdd"

if ($RestoreDatabase -eq '<dbname>'){write-host 'Variables $RestoreDatabase is not set. Change the DB restorename and run script again.' -ForegroundColor Red;pause;exit}
Import-Module SQLPS -DisableNameChecking
cls

#check if DB restorename already exists
$checkexistingQ = @"
IF  EXISTS (SELECT 1 FROM sys.databases WHERE database_id = DB_ID(N'$RestoreDatabase'))
select 'true' as [checkexists]
"@
try {
$dbexists = Invoke-Sqlcmd -ServerInstance $SQLsrvName -Database master -Query $checkexistingQ -erroraction stop
}
catch {
write-host "Can't query the SQL instance '$SQLsrvName'" -ForegroundColor Red
write-host $_
pause
exit
}

#if database already exists confirm overwrite.
if ($dbexists.checkexists -eq 'true'){
    write-host "WARNING! Database '$($RestoreDatabase)' already exists on SQL server '$($SQLsrvName)'." -ForegroundColor Yellow
    $overwrite = read-host "Overwrite? (Y/N)"
    if ($overwrite -eq 'n'){write-host "Restorescript stops here"-ForegroundColor yellow;pause;exit}

}

Write-host "This script restores a database named $($RestoreDatabase) on $($SQLsrvName) from $($BAKpath)" -foregroundcolor Magenta

#Get latest BAK file  from the backup path $BAKpath
$BAKFile = Get-ChildItem "$BAKpath\*.bak" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

#check if we got a BAK file to process
if ($BAKFile){
write-host "Got BAK file $($BAKFile.name). Processing..." -foregroundcolor yellow

#Get SQL instance data-/log-/backuppaths
$localinstpathQ= @"
SELECT SERVERPROPERTY('INSTANCEDEFAULTDATAPATH') as [datapath], SERVERPROPERTY('INSTANCEDEFAULTLOGPATH') as [logpath],SERVERPROPERTY('INSTANCEDEFAULTBACKUPPATH') as [bakpath];
"@
$localdatapaths = Invoke-Sqlcmd -ServerInstance $SQLsrvName -Database master -Query $localinstpathQ
#SQL versions below 2019 don't have property for default backuppath. Use registry.
if ($localdatapaths.bakpath -notcontains '\'){
    $mssqlpath = Resolve-Path 'HKLM:\Software\Microsoft\Microsoft SQL Server\*' | where-object {$_ -like '*MSSQL*SQLSERVER*'}|Select-Object -ExpandProperty ProviderPath
    if ($mssqlpath){
        $localdatapaths.bakpath = get-itemproperty -path "Registry::$mssqlpath\MSSQLServer" -name BackupDirectory| select -ExpandProperty BackupDirectory
        $localdatapaths.bakpath = join-path $localdatapaths.bakpath "\"
    }
    else {$localdatapaths.bakpath = "c:\temp\"}
}#end if bakpath check


if ($localdatapaths){
    #Trim spaces from paths
    ($localdatapaths.bakpath).trim()
    ($localdatapaths.logpath).trim()
    ($localdatapaths.datapath).trim()

    if (!(test-path "$($localdatapaths.bakpath)\tempfiles")){
        new-item "$($localdatapaths.bakpath)\tempfiles" -type directory -force
    }
    #copy BAK file to local server
    write-host "Please wait while copying BAK file '$($BAKFile.name)' from '$($BAKpath)' to '$($localdatapaths.bakpath)\tempfiles'..." -foregroundcolor yellow
    copy-item $BAKFile "$($localdatapaths.bakpath)\tempfiles"
    
    #get the copied BAK file
    $localBakFile = Get-ChildItem "$($localdatapaths.bakpath)\tempfiles\*.bak"
    $localBakFile.lastwritetime = $BAKFile.lastwritetime
    #Extract logical name and physical path from bakfile
    $relocate = @()
    $dbfiles = Invoke-Sqlcmd -ServerInstance $SQLsrvName -Database tempdb -Query "RESTORE FILELISTONLY FROM DISK='$localBakFile';"
    
    #Loop through filelist, replace old paths with new restore paths
    foreach($dbfile in $dbfiles){
        $DbFileName = $dbfile.PhysicalName | Split-Path -Leaf
        if($dbfile.Type -eq 'L'){
            $newfile = Join-Path -Path ($localdatapaths.logpath) -ChildPath $DbFileName
            if (test-path $newfile){
                write-host "File already exists. Adding date to the physical filename"
                $newfile = [System.IO.Path]::GetDirectoryName($newfile) + "\" + [System.IO.Path]::GetFileNameWithoutExtension($newFile) + "_" + $dateadd + ([System.IO.Path]::GetExtension($newFile))
            }
        } else {
            $newfile = Join-Path -Path ($localdatapaths.datapath) -ChildPath $DbFileName
            if (test-path $newfile){
                write-host "File already exists. Adding date to the physical filename"
                $newfile = [System.IO.Path]::GetDirectoryName($newfile) + "\" + [System.IO.Path]::GetFileNameWithoutExtension($newFile) + "_" + $dateadd + ([System.IO.Path]::GetExtension($newFile))
            }
            
        }
        $relocate += New-Object Microsoft.SqlServer.Management.Smo.RelocateFile ($dbfile.LogicalName,$newfile)
    }#end foreach $dbfile

    #check if we got any TRN files
    $TRNFiles = Get-ChildItem "FileSystem::$TRNpath\*.trn" | Where-Object {$_.LastWriteTime -gt $BAKFile.lastwritetime} | select
    
    #Restore database with NoRecovery, we got TRN files to restore!
    if ($TRNFiles){
        #Replace database
        if ($dbexists.checkexists -eq 'true'){
            write-host "Please wait while restoring database '$($RestoreDatabase)' WITH REPLACE using BAK file $($localBAKFile.name)..." -foregroundcolor yellow
            Restore-SqlDatabase -ServerInstance $SQLsrvName -Database $RestoreDatabase -BackupFile $localbakFile -RelocateFile $relocate -RestoreAction Database -NoRecovery -ReplaceDatabase
            write-host "Restored database '$($RestoreDatabase)' using BAK file '$($localBAKFile.name)'." -foregroundcolor green
            remove-item $localbakFile
        }
        else {
            write-host "Please wait while restoring database '$($RestoreDatabase)' using BAK file '$($localBAKFile.name)'..." -foregroundcolor yellow
            Restore-SqlDatabase -ServerInstance $localSQLsrvName -Database $RestoreDatabase -BackupFile $localBAKFile -RelocateFile $relocate -RestoreAction Database -NoRecovery 
            write-host "Restored database '$($RestoreDatabase)' using BAK file '$($localBAKFile.name)'." -foregroundcolor green
            remove-item $localBAKFile
        }
        #process TRN files in sorted order (oldest>newest) after BAK restore
        $sortedTRNFiles = Get-ChildItem "FileSystem::$TRNpath\*.trn" | Where-Object {$_.LastWriteTime -gt $BAKFile.lastwritetime}| Sort-Object LastWriteTime | select
        write-host "Got $($sortedTRNFiles.count) TRN files to restore. Processing..." -foregroundcolor Yellow
            $i=1
            foreach ($TRNFile in $sortedTRNFiles){
                $destfilename = $TRNFile.name
                copy-item $TRNFile "$($localdatapaths.bakpath)\tempfiles\$destfilename"
                $trnbackupfile = gci "$($localdatapaths.bakpath)\tempfiles\$destfilename"
                $trnbackupfile.LastWriteTime = $TRNFile.LastWriteTime
                if($i -ne $sortedTRNFiles.count){
                    write-host "Please wait while restoring TRN file $($trnbackupfile.name)..." -foregroundcolor yellow
                    Restore-SqlDatabase -ServerInstance $SQLsrvName -Database $RestoreDatabase -BackupFile $trnbackupfile -NoRecovery -RestoreAction Log 
                    write-host "Restored TRN file $($trnbackupfile.name)." -foregroundcolor Green
                    remove-item $trnbackupfile
                 }
                else {
                    write-host "Please wait while restoring TRN file '$($trnbackupfile.name)'..." -foregroundcolor yellow
                    Restore-SqlDatabase -ServerInstance  $SQLsrvName -Database $RestoreDatabase -BackupFile $trnbackupfile -RestoreAction Log
                    write-host "Restored TRN file '$($trnbackupfile.name)'." -foregroundcolor Green
                    remove-item $trnbackupfile
                }
                $i++
            }#end foreach $remoteTRNfile
    }#end if remote TRN files check
    else {
    #Restore database with Recovery. No TRN restore is needed.
    if ($dbexists.checkexists -eq 'true'){
        write-host "Please wait while restoring database '$($RestoreDatabase)' with REPLACE using BAK file '$($localBAKFile.name)'..." -foregroundcolor yellow
        Restore-SqlDatabase -ServerInstance $SQLsrvName -Database $RestoreDatabase -BackupFile $localBAKFile -RelocateFile $relocate -RestoreAction Database -ReplaceDatabase
        write-host "Restored database '$($RestoreDatabase)' using BAK file '$($localBAKFile.name)'." -foregroundcolor green
        remove-item $localBAKFile
        }
        else {
        write-host "Please wait while restoring database using BAK file $($localBAKFile.name)..." -foregroundcolor yellow
        Restore-SqlDatabase -ServerInstance $SQLsrvName -Database $RestoreDatabase -BackupFile $localBAKFile -RelocateFile $relocate -RestoreAction Database 
        write-host "Restored database '$($RestoreDatabase)' using BAK file $($localbakFile.name)'." -foregroundcolor green
        remove-item $localBAKFile
        }
    }
    write-host "Restoreprocess of database '$($RestoreDatabase)' complete." -foregroundcolor Green

    #Check CMP-LVL
    $cmplvlinst = Invoke-Sqlcmd -ServerInstance $SQLsrvName -Database master -Query "SELECT compatibility_level FROM sys.databases WHERE name = 'master';" | select -ExpandProperty compatibility_level
    $cmplvldb = Invoke-Sqlcmd -ServerInstance $SQLsrvName -Database master -Query "SELECT compatibility_level FROM sys.databases WHERE name = '$RestoreDatabase';" | select -ExpandProperty compatibility_level
    if ($cmplvldb -lt $cmplvlinst){
            if ($cmplvlcheck -eq 'y'){
                $setcmplvl = Invoke-Sqlcmd -ServerInstance $SQLsrvName -Database master -Query "ALTER DATABASE $RestoreDatabase SET COMPATIBILITY_LEVEL = $cmplvlinst;"
            }
       
    }#end if cmplvl check
    
    #Set simple mode
    if ($simpleRecoveryMode -eq 's'){
     $setsimple = Invoke-Sqlcmd -ServerInstance $SQLsrvName -Database master -Query "ALTER DATABASE $RestoreDatabase SET RECOVERY SIMPLE;"
     }
    pause
    exit

 }#end if $localdatapaths
 else {
 write-host "Couldn't get the SQL instance default data-/logpaths. Check the servernamevariable and/or connection." -foregroundcolor red;pause;exit
 }
}#end if Remote BAK file check
else {
write-host "No database BAK file found in $($BAKpath). Check the bak/trn path variables on top of the script" -ForegroundColor red;pause;exit
}#end else bak/trn path check
#SCRIPT END
