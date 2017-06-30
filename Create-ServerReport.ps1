#I really really need to write some documentation on this.


﻿Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'



Function writeHtmlHeader
{
param($fileName,$ServerCount)
$date = ( get-date ).ToString('MM/dd/yyyy - HH:mm:ss')
Add-Content $fileName "<html>"
Add-Content $fileName "<head>"
Add-Content $fileName "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
Add-Content $fileName '<title>Server Report</title>'
add-content $fileName '<STYLE TYPE="text/css">'
add-content $fileName  "<!--"
add-content $fileName  "td {"
add-content $fileName  "font-family: Tahoma;"
add-content $fileName  "font-size: 11px;"
add-content $fileName  "padding-top: 0px;"
add-content $fileName  "padding-right: 0px;"
add-content $fileName  "padding-bottom: 0px;"
add-content $fileName  "padding-left: 0px;"
add-content $fileName  "}"
add-content $fileName  "body {"
add-content $fileName  "margin-left: 5px;"
add-content $fileName  "margin-top: 5px;"
add-content $fileName  "margin-right: 0px;"
add-content $fileName  "margin-bottom: 10px;"
add-content $fileName  ""
add-content $fileName  "table {"
add-content $fileName  "border: thin solid #000000;"
add-content $fileName  "border-collapse: collapse;"
add-content $fileName  "}"
add-content $fileName  "-->"
add-content $fileName  "</style>"
Add-Content $fileName "</head>"
Add-Content $fileName "<body>"

add-content $fileName  "<table width='100%'>"
add-content $fileName  "<tr bgcolor='#CCCCCC'>"
add-content $fileName  "<td colspan='7' height='25' align='center'>"
add-content $fileName  "<font face='tahoma' color='#003399' size='4'><strong>Server Report - $date        Count: $ServerCount</strong></font>"
add-content $fileName  "</td>"
add-content $fileName  "</tr>"
add-content $fileName  "</table>"

}

# Function to write the HTML Header to the file
Function writeTableHeader
{
param($fileName)
Add-Content $fileName "<table width='100%'><tbody>"


Add-Content $fileName "<tr bgcolor=#CCCCCC>"
Add-Content $fileName "<td width='15%' align='center'><strong>Name</strong></td>"
Add-Content $fileName "<td width='15%' align='center'><strong>OS Version</strong></td>"
Add-Content $fileName "<td width='5%' align='center'><strong>WSUS Group</strong></td>"
Add-Content $fileName "<td width='7%' align='center'><strong>Last Reboot</strong></td>"
Add-Content $fileName "<td width='5%' align='center'><strong>Boot Drive Free</strong></td>"
Add-Content $fileName "<td width='5%' align='center'><strong>SCCM Status</strong></td>"
Add-Content $fileName "<td width='5%' align='center'><strong>Splunk Status</strong></td>"
Add-Content $fileName "<td width='5%' align='center'><strong>SEP Version</strong></td>"
Add-Content $fileName "<td width='11%' align='center'><strong>Model</strong></td>"
Add-Content $fileName "<td width='5%' align='center'><strong>Memory</strong></td>"
Add-Content $fileName "<td width='5%' align='center'><strong>CPU Cores</strong></td>"
Add-Content $fileName "<td width='7%' align='center'><strong>OS Install</strong></td>"
Add-Content $fileName "<td width='5%' align='center'><strong>DNS Type</strong></td>"
Add-Content $fileName "<td width='5%' align='center'><strong>DNS Value</strong></td>"
Add-Content $fileName "</tr>"



}

Function writeHtmlFooter
{
param($fileName)

Add-Content $fileName "</body>"
Add-Content $fileName "</html>"
}

Function writeServerInfo
{
param($filename,[PSObject]$server,$CellColor)
 $name = $server.Name
 $OSVersion = $server.OSVersion
 $WSUSGroup = $server.WSUSGroup
 $LastReboot = $server.LastRebootDate
 $CfrSpace = $server.CDriveFreeSpace
 $SCCMClientStatus = $server.SCCMClientState
 $SplunkStatus = $server.SplunkStatus
 $SEPVersion = $server.SEPVersion
 $SEPInstallState = $server.SEPInstallState
 $Model = $server.Model
 $MemoryInstalled = $server.Memory
 $CPUCores = $server.NumberOfCores
 $OSInstallDate = $server.OSInstallDate
 $DNSRecordType = $server.DNSRecordType
 $DNSRecordValue = $server.DNSRecordValue


 switch -Wildcard ($CellColor)
    {
    "Dark" {$info="#A9CCE3";$green="#7DCEA0";$yellow="#F4D03F";$red="#EC7063"}
    "Light" {$info="white";$green="#ABEBC6";$yellow="#F9E79F";$red="#F5B7B1"}
    }


 #Set the background color to the default light or dark tone
 Add-Content $fileName "<tr bgcolor='$info'>"
 Add-Content $fileName "<td align=center>$name</td>"
 Add-Content $fileName "<td align=center>$OSVersion</td>"
 Add-Content $fileName "<td align=center>$WSUSGroup</td>"

 #Last Reboot status and color coding
 switch -Wildcard ($server.LastRebootState)
    {
    "Less than 30 days ago" {Add-Content $fileName "<td bgcolor='$green' align=center>$LastReboot</td>"}
    "More than 30 days ago" {Add-Content $fileName "<td bgcolor='$red' align=center>$LastReboot</td>"}
    "" {Add-Content $fileName "<td bgcolor='$red' align=center></td>"}
    }

 #Boot drive free space and color coding
 If (($server.CDriveFreeValue -lt 15) -and ($server.CDriveFreeValue -gt 10))
    {
    Add-Content $fileName "<td bgcolor='$yellow' align=center>$CfrSpace</td>"
    }
    elseif ($server.CDriveFreeValue -le 10)
    {
    Add-Content $fileName "<td bgcolor='$red' align=center>$CfrSpace</td>"
    }
    else
    {
    Add-Content $fileName "<td bgcolor='$green' align=center>$CfrSpace</td>"
    }



 #SCCM Client status and color coding
 switch -Wildcard ($server.SCCMClientState)
    {
    "Active" {Add-Content $fileName "<td bgcolor='$green' align=center>$SCCMClientStatus</td>"}
    "Site Server" {Add-Content $fileName "<td bgcolor='$green' align=center>$SCCMClientStatus</td>"}
    "Inactive" {Add-Content $fileName "<td bgcolor='$yellow' align=center>$SCCMClientStatus</td>"}
    "Not Installed" {Add-Content $fileName "<td bgcolor='$red' align=center>$SCCMClientStatus</td>"}
    }

 #Splunk status and color coding
 switch -Wildcard ($server.SplunkStatus)
    {
    "Running" {Add-Content $fileName "<td bgcolor='$green' align=center>$SplunkStatus</td>"}
    "Stopped" {Add-Content $fileName "<td bgcolor='$yellow' align=center>$SplunkStatus</td>"}
    "Not Installed" {Add-Content $fileName "<td bgcolor='$red' align=center>$SplunkStatus</td>"}
    }

#SEP Version and color coding
If ($SEPInstallState -eq "Not Installed")
    {
    Add-Content $fileName "<td bgcolor='$red' align=center>Not Installed</td>"
    }
If ($SEPInstallState -eq "Installed")
    {
    If ($server.SEPVersion -eq "14.0.2332.0100")
        {
        Add-Content $fileName "<td bgcolor='$green' align=center>$SEPVersion</td>"
        }
        else
        {
        Add-Content $fileName "<td bgcolor='$yellow' align=center>$SEPVersion</td>"
        }
    }


 Add-Content $fileName "<td align=center>$Model</td>"
 Add-Content $fileName "<td align=center>$MemoryInstalled</td>"
 Add-Content $fileName "<td align=center>$CPUCores</td>"
 Add-Content $fileName "<td align=center>$OSInstallDate</td>"
 Add-Content $fileName "<td align=center>$DNSRecordType</td>"
 Add-Content $fileName "<td align=center>$DNSRecordValue</td>"
 Add-Content $fileName "</tr>"

}


Function sendEmail
{ param($from,$to,$subject,$smtphost,$htmlFileName)
$body = Get-Content $htmlFileName
$smtp= New-Object System.Net.Mail.SmtpClient $smtphost
$msg = New-Object System.Net.Mail.MailMessage $from, $to, $subject, $body
$msg.isBodyhtml = $true
$smtp.send($msg)

}


###################
#   Start Script
###################

$FileName = "C:\temp\ServerReport.html"
Remove-Item $FileName -Force

#Get servers to report on from OU's in AD
$SearchOUs = @("OU=Servers,CN=example,CN=com")

#Set the SCCM site server Site Code
$SCCMSiteCode = "NEW"

#Set the SCCM site server hostname
$SCCMSiteHost = "SCCM-Site-Server"



$ServerList = $SearchOUs | ForEach { Get-ADComputer -SearchBase $_ -Filter {OperatingSystem -like '*Windows*'} -Properties CanonicalName } | sort name
$serverCount = $ServerList | measure


#Create the array of objects
$ServerReport = @()

#Get Local Hostname
$LocalHost = hostname

#Set the initial cell color
$CellColor = "Light"

writeHTMLHeader $FileName $serverCount.Count
WriteTableHeader $FileName

#Loop through the servers and get information
Foreach ($ServerName in $ServerList)
{
    #Create the object and add members
    $server = New-Object psobject
    $server | Add-Member -MemberType NoteProperty -Name Name -Value ''
    $server | Add-Member -MemberType NoteProperty -Name DNSRecordType -Value ''
    $server | Add-Member -MemberType NoteProperty -Name DNSRecordValue -Value ''
    $server | Add-Member -MemberType NoteProperty -Name SCCMClientState -Value ''
    $server | Add-Member -MemberType NoteProperty -Name LastRebootState -Value ''
    $server | Add-Member -MemberType NoteProperty -Name LastRebootDate -Value ''
    $server | Add-Member -MemberType NoteProperty -Name OUName -Value ''
    $server | Add-Member -MemberType NoteProperty -Name OSVersion -Value ''
    $server | Add-Member -MemberType NoteProperty -Name WSUSGroup -Value ''
    $server | Add-Member -MemberType NoteProperty -Name CDriveFreeSpace -Value ''
    $server | Add-Member -MemberType NoteProperty -Name CDriveFreeValue -Value ''
    $server | Add-Member -MemberType NoteProperty -Name SplunkStatus -Value ''
    $server | Add-Member -MemberType NoteProperty -Name SEPInstallState -Value ''
    $server | Add-Member -MemberType NoteProperty -Name SEPVersion -Value ''
    $server | Add-Member -MemberType NoteProperty -Name Model -Value ''
    $server | Add-Member -MemberType NoteProperty -Name OSInstallDate -Value ''
    $server | Add-Member -MemberType NoteProperty -Name Memory -Value ''
    $server | Add-Member -MemberType NoteProperty -Name NumberOfCores -Value ''

    #Read in the server name from the console
    $server.name = $ServerName.Name


    #Get the original path
    $OrigPath = Get-Location

    #Get the SCCM Client Information
    $ActiveState = ""
    Set-Location $SCCMSiteCode
    $ActiveState = Get-CMDevice -Name $server.name
    switch -Wildcard ($ActiveState.ClientActiveStatus)
    {
        "1" {$server.SCCMClientState = "Active"}
        "0" {$server.SCCMClientState = "Inactive"}
        "" {$server.SCCMClientState = "Not Installed"}
    }
    If ($Server.name -eq $SCCMSiteHost)
        {
        $server.SCCMClientState = "Site Server"
        }

    #Change back to the original executing path
    Set-Location $OrigPath.Path

    #Get the DNS record information
    $DNSRecord = (Get-DNSServerResourceRecord -Node $server.name -RRType A -ComputerName DNS-Server -ZoneName example.com)
    $server.dnsrecordtype = $DNSRecord.RecordType
    $server.DNSRecordvalue = $DNSRecord.RecordData.IPv4Address.IPAddressToString


    #Get the OS Install date from WMI
    $WMI_OpeartingSystem = (Get-WMIObject -ComputerName $server.name -Class win32_OperatingSystem)
    $server.OSInstallDate = $WMI_OpeartingSystem.ConvertToDateTime($WMI_OpeartingSystem.InstallDate)

    #Get the Last Reboot Time
    $server.LastRebootDate = $WMI_OpeartingSystem.ConvertToDateTime($WMI_OpeartingSystem.LastBootUpTime)
    If ($WMI_OpeartingSystem.ConvertToDateTime($WMI_OpeartingSystem.LastBootUpTime) -lt (Get-Date).AddDays(+31))
    {
        $server.LastRebootState = "Less than 30 days ago"
    }
    else
    {
        $server.LastRebootState = "More than 30 days ago"
    }

    #Get OS Version from WMI
    $server.OSVersion = $WMI_OpeartingSystem.Caption

    #Get the C drive free space from WMI
    $CDriveFree = (Get-WMIObject -ComputerName $server.name -Class win32_volume | Where-Object {$_.DriveLetter -eq "C:"} | ForEach-Object {[math]::truncate($_.freespace / 1GB)})
    $server.CDriveFreeValue = $CDriveFree
    $CDriveFree = "$CDriveFree" + "GB"
    $server.CDriveFreeSpace = $CDriveFree

    #Get OU CN from AD
    $server.OUName = $ServerName.CanonicalName

    #Get WSUS Group from Registry Value
    #Ignore the servers with WSUS installed
    If ($server.name -eq $SCCMSiteHost)
    {
        $server.WSUSGroup = "WSUS Server"
    }
    else
    {
        #The Invoke Command will fail on the running host, so run it locally isntead
        If ($server.name -eq $LocalHost)
        {
            $WSUS = Get-ItemProperty HKLM:\software\Policies\Microsoft\Windows\WindowsUpdate -Name "TargetGroup"
        }
        else
        {
            $WSUS = Invoke-command -Computer $server.name {Get-ItemProperty HKLM:\software\Policies\Microsoft\Windows\WindowsUpdate -Name "TargetGroup"}
        }
        $server.WSUSGroup = $WSUS.TargetGroup
    }


    #Get Splunk service status
    $SplunkService = ""
    #The Invoke Command will fail on the running host, so run it locally isntead if localhost
    If ($server.name -eq $LocalHost)
    {
        $SplunkService = Get-Service | Where-Object {$_.Name -eq "SplunkForwarder"}
    }
    else
    {
        $SplunkService = Invoke-Command -ComputerName $server.name {Get-Service | Where-Object {$_.Name -eq "SplunkForwarder"}}
    }

    #Now dow the evaluation for it
    If ($SplunkService -eq $null)
    {
        $server.SplunkStatus = "Not Installed"
    }
    else
    {
        $server.SplunkStatus = $SplunkService.Status
    }



    #Check if SEP is installed
    $SEPVersion = $null

    #The Invoke Command will fail on the running host, so run it locally isntead
    If ($server.name -eq $LocalHost)
    {
        $SEPVersion = Get-WmiObject -Class win32_product | Where-Object {$_.Name -eq "Symantec Endpoint Protection"}
    }
    else
    {
        $SEPVersion = Invoke-Command -Computer $server.name {Get-WmiObject -Class win32_product | Where-Object {$_.Name -eq "Symantec Endpoint Protection"}}
    }

    #Now do the evaluation for it
    If ($SEPVersion -eq $null)
    {
        $server.SEPInstallState = "Not Installed"
    }
    else
    {
        $server.SEPInstallState = "Installed"
    }

    #Get the version of SEP installed
    $server.SEPVersion = $SEPVersion.Version




    #Get the computer model information from WMI
    #The Invoke Command will fail on the running host, so run it locally isntead
    If ($server.name -eq $LocalHost)
    {
        $WMI_ComputerSystem = Get-WMIObject -Class win32_ComputerSystem
    }
    else
    {
        $WMI_ComputerSystem = Invoke-Command -Computer $server.name {Get-WMIObject -Class win32_ComputerSystem}
    }

    #Now process to results
    $server.model = $WMI_ComputerSystem.Model
    If ($server.model -eq "VMware Virtual Platform")
    {
    $server.Model = "VMWare VM"
    }

    #Get the total physical memory
    $memory = [Math]::Round(($WMI_ComputerSystem.TotalPhysicalMemory/ 1GB))
    $server.memory = "$memory" + "GB"

    #Get the number of processor cores
    $server.NumberOfCores = $WMI_ComputerSystem.NumberOfLogicalProcessors


    #Add the object to the array of objects
    $ServerReport += $Server

    #Write the HTML row
    writeServerInfo $FileName $server $CellColor


    #Switch the color scheme for the next run of the loop
    switch -Wildcar ($CellColor)
    {
        "Light" {$CellColor = "Dark"}
        "Dark" {$CellColor = "Light"}
    }

}

#Write the end of the table and the footer
Add-Content $FileName "</table>"
add-content $fileName  "<table width='100%'>"
add-content $fileName  "<tr bgcolor='#CCCCCC'>"
add-content $fileName  "<td colspan='7' height='25' align='center'>"
add-content $fileName  "</td>"
add-content $fileName  "</tr>"
add-content $fileName  "</table>"
WriteHTMLFooter $FileName

$date = ( get-date ).ToString('MM/dd/yyyy')
sendEmail Reports@example.com user@example.com "Windows Server Report - $Date" smtp.example.com $fileName
