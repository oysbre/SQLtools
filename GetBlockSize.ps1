$tmp += Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE FileSystem='NTFS'"
$tmp | Select-Object Label, Blocksize, Name
