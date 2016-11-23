#This script is meant to help you update static A records in DNS to new IPs


#Set the DNS Zone Name
$DNSZone = "domain.com"


#Function to prompt the user for the filename
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


$filelocation = Get-FileName
If ($filelocation)
    {
    $storageDirectory=split-path $filelocation
    [Array] $csvDNSRecords = Import-CSV $filelocation -header name,newIP
    foreach ($DNSRecord in $csvDNSRecords)
        {
        $DNSName = $DNSRecord.name
        $NewIP= $DNSRecord.newIP

        #Delete existing A record
        Remove-DnsServerResourceRecord -ZoneName $DNSZone -Name $DNSName -RRType "A" -Force

        #Add new A record with new IP
        Add-DnsServerResourceRecordA -Name $DNSName -IPv4Address $NewIP -ZoneName $DNSZone -AllowUpdateAny -AgeRecord

        }
    }
else
    {
    Write-Host "No file selected. Exiting";exit
    }
