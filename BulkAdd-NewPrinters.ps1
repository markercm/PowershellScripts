

#Set the following variables

$referencePrinterName = ""
$printServerName = ""
$DNSZone = ""
$DNSServerName = ""


﻿Function driverSet
{
 param($enteredMake)
 $DriverNameFct = ""
 If ($enteredMake -eq "Xerox") {$DriverNameFct = "Xerox Global Print Driver PCL6"}
 If ($enteredMake -eq "HP") {$DriverNameFct = "HP Universal Printing PCL 6"}
 If ($enteredMake -eq "Dell") {$DriverNameFct = "Dell Open Print Driver (PCL 5)"}
 If ($enteredMake -eq "Canon") {$DriverNameFct = "Canon Generic PCL6 Driver"}
 If ($enteredMake -eq "Brother") {$DriverNameFct = "Brother Universal Printer (BR-Script3)"}
 If ($enteredMake -eq "Lexmark") {$DriverNameFct = "Lexmark Universal v2"}
 return $DriverNameFct
}

Function addPrinter
{ param($IP,$Name,$Driver,$Server)
$secSettings = Get-Printer -ComputerName $printServerName -Name $referencePrinterName -full | select PermissionSDDL -ExpandProperty PermissionSDDL

#Add a Static A Record to DNS for the IP to use as the port
Add-DnsServerResourceRecordA -Name $Name -IPv4Address $IP -ZoneName $DNSZone -ComputerName $DNSServerName

#Set the port name to be the FQDN
$PortName = $Name + "." + $DNSZone
Add-PrinterPort -Name $PortName -PrinterHostAddress $PortName -ComputerName $Server
Add-Printer -PortName $PortName -Name $Name -DriverName $Driver -Shared -ShareName $Name -ComputerName $Server
Get-Printer -Name $Name | Set-Printer -PermissionSDDL $secSettings

}

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


Clear


$filelocation = Get-FileName
If ($filelocation)
    {
    $storageDirectory=split-path $filelocation
    [Array] $csvPrinters = Import-CSV $filelocation -header ip,name,make
    foreach ($Printer in $csvPrinters)
        {
        $IPAddress = $Printer.ip
        $PrinterName = $Printer.name
        $Make = $Printer.make
        $PrintServer = $printServerName

        $DriverName = driverSet $Make
        addPrinter $IPAddress $PrinterName $DriverName $PrintServer
        Write-Output ""
        Write-Output ""
        Write-Output "#################################################################################################################"
        Write-Output "Created a printer named $PrinterName at $IPAddress using the $DriverName to $PrintServer."
        Write-Output "#################################################################################################################"
        }
    }
else
    {
    Write-Host "No file selected. Exiting";exit
    }




Pause
exit
