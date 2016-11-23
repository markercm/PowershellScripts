#########WARNING!!!!###############
Write-Host '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
Write-Host '!!!!!!!!!!!!!!!!!!!!!!!!!!BE VERY CAUTIOUS USING THIS TOOL!!!!!!!!!!!!!!!!!!!!!!!!!!'
Write-Host '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
Write-Host '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
Write-Host '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!BULK ADD DHCP RESERVATIONS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
Write-Host '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'


#Set the DHCP Server Address for your organization
$DHCPServerAddress = "dhcp.domain.com"





#########IMPORT FILE###############
Function Get-FileName()
{
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = "C:\Users\$env:username\Desktop"
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowHelp = $true
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
}

Write-Host "Please select the import file. Must have headers Name,MAC,Scope,IP"

$fileLocation = Get-FileName
if ($fileLocation){}
else {Write-Host "No file selected. Exiting";exit}
$storageDirectory=split-path $fileLocation
[array] $exportList = import-csv $fileLocation
#-header MAC,Name
#$p = Import-Csv ALL_Printers_test_powershell.csv
#$p.MAC[0]
#$p.Name[0]


#########START LOOP################
foreach ($reservation in $exportList)
{
$Name = $reservation.Name
$MAC = $reservation.MAC
$Scope = $reservation.Scope
$IP = $reservation.IP
Add-DhcpServerv4Reservation -ScopeId $Scope -IPAddress $IP -ClientId $MAC -Description $Name -Name $Name -CimSession $DHCPServerAddress
}
