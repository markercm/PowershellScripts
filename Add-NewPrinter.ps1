#This is for adding new printers



#Set the following variables

$referencePrinterName = ""
$printServerName = ""
$DNSZone = ""
$DNSServerName = ""


Function checkPrinter
{ param($ObjName,$Server)
$PrinterExists = 0
$PrintersInstalled = Get-Printer -ComputerName $Server
foreach ($Printer in $PrintersInstalled)
    {
    If ($Printer.Name -eq $ObjName) {$PrinterExists = 1}
    }
return $PrinterExists
}

Function driverSet
{ param($enteredMake)
$DriverNameFct = ""
If ($Make -eq "Xerox") {$DriverNameFct = "Xerox Global Print Driver PCL6"}
If ($Make -eq "HP") {$DriverNameFct = "HP Universal Printing PCL 6"}
If ($Make -eq "Dell") {$DriverNameFct = "Dell Open Print Driver (PCL 5)"}
If ($Make -eq "Canon") {$DriverNameFct = "Canon Generic PCL6 Driver"}
If ($Make -eq "Brother") {$DriverNameFct = "Brother Universal Printer (BR-Script3)"}
If ($Make -eq "Lexmark") {$DriverNameFct = "Lexmark Universal v2"}
If ($DriverNameFct -eq "")
    {
    Write-Output "#################################################################################################################"
    Write-Output "Make not recognized, setting to Generic as a placeholder, please check the object after the script has run."
    Write-Output "#################################################################################################################"
    $DriverName = "Generic / Text Only"
    }
return $DriverNameFct
}


Function addPrinter
{ param($IP,$Name,$Driver,$Server)
$secSettings = Get-Printer -ComputerName "$printServerName" -Name $referencePrinterName -full | select PermissionSDDL -ExpandProperty PermissionSDDL

#Add a Static A Record to DNS for the IP to use as the port
Add-DnsServerResourceRecordA -Name $Name -IPv4Address $IP -ZoneName $DNSZone -ComputerName $DNSServerName

#Set the port name to be the FQDN
$PortName = $Name + "." + $DNSZone
Add-PrinterPort -Name $PortName -PrinterHostAddress $PortName -ComputerName $Server
Add-Printer -PortName $PortName -Name $Name -DriverName $Driver -Shared -ShareName $Name -ComputerName $Server
Get-Printer -Name $Name | Set-Printer -PermissionSDDL $secSettings

}


Clear
$PrinterName = Read-Host "What is the Printer's Name"
$IPAddress = Read-Host "What is the Printer's IP Address"
$Make = Read-Host "What is the Make of the Printer"




$AlreadyExists = checkPrinter $PrinterName $printServerName
If ($AlreadyExists -eq "1")
    {
    Write-Output ""
    Write-Output ""
    Write-Output "#################################################################################################################"
    Write-Output "A printer named $PrinterName already exists."
    Write-Output "#################################################################################################################"
    exit
    }
    else
    {
    $DriverName = driverSet $Make
    addPrinter $IPAddress $PrinterName $DriverName $printServerName
    $PrinterWasAdded = checkPrinter $PrinterName $printServerName

    Write-Output ""
    Write-Output ""
    Write-Output "#################################################################################################################"
    If ($PrinterWasAdded)
        {
        Write-Output "Created a printer named $PrinterName at $IPAddress using the $DriverName to $printServerName."
        }
        else
        {
        Write-Output "There was a problem creating $PrinterName, please check the name and settings."
        }
    Write-Output "#################################################################################################################"
    }
Pause
exit
