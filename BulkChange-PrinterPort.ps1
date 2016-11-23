#This script is to help when changing printer's IP address without touching the objects.


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
    [Array] $csvPrinters = Import-CSV $filelocation -header name,newIP
    foreach ($Printer in $csvPrinters)
        {
        $PrinterName = $Printer.name
        $NewIP= $Printer.newIP

        #Add new Printer Port
        $PortName = $NewIP + "-" + $PrinterName
        Add-PrinterPort -Name $PortName -PrinterHostAddress $NewIP

        #Set printer with new Port
        Set-Printer -Name $PrinterName -Port $PortName
        Write-Output "###### Changed $PrinterName to use port $PortName with IP address $NewIP ######"

        }
    }
else
    {
    Write-Host "No file selected. Exiting";exit
    }
