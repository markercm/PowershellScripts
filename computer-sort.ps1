#This script is used to sort AD computer objects out of the Computer container
#It can also be used to sort objects out of other OU's like what we use for Casper and SCCM
#The matching is done by comparing the string of the computer name to a set list that is used for departments

#In most cases the computer name will be DEPT-NAMENAMENAME and it can match for the first four chacters,
#In some other cases it uses shorter or long naming, as long as the results are consistent.


# Remote the previous result file.

Remove-Item C:\ComputerSort\ComputersMoved.html -Force >$null 2>&1

#Used to send the email message
Function sendEmail
{ param($from,$to,$subject,$smtphost,$htmlFileName)
$body = Get-Content $htmlFileName
$smtp = New-Object System.Net.Mail.SmtpClient $smtphost
$msg = New-Object System.Net.Mail.MailMessage $from, $to, $subject, $body
$msg.isBodyhtml = $true
$smtp.send($msg)
}


#Where we compare the computer name to the prefix list and assign a destination if a match is found
Function evalDepartment
{ param($CompName)
$ComputerPrefix=$CompName.Trim().Substring(0,4)
$ComputerPrefixShort=$CompName.Trim().Substring(0,3)

#Set the standard OU where computers should be stored under the department
$stdComputersOU="OU=Computers,"

#Set the base level where the different departments are under
$stdDEPTOU=",Departments,DC=example,DC=com"

$deptOUName=""
$destinationOU=""

#Do the actual sorting based on the first four characters of the computer name string
If ($ComputerPrefix -eq "ACT-") {$deptOUName="OU=Accounting"}
If ($ComputerPrefix -eq "FIN-") {$deptOUName="OU=Finance"}
If ($ComputerPrefix -eq "OIT-") {$deptOUName="OU=Office of Information Technology"}


#New Logic to test if the value was set or not.
If ($deptOUName)
    {
    $destinationOU=$stdComputersOU + $deptOUName + $stdDEPTOU
    }
    else
    {
    $destinationOU=""
    }

return $destinationOU
}

#Get the unsorted computer objects into a list from both OUs
$ComputerOUpaths = @("OU=Computers-Casper-Imaged,DC=example,DC=com","OU=Computers-SCCM-Imaged,DC=example,DC=com","CN=Computers,DC=example,DC=com")
$UnsortedComputers=$ComputerOUpaths | foreach { Get-ADComputer -SearchBase $_ -Filter * }


#Filter the whole list of Unsorted Computres, calling the eval function and moving the object
foreach ($UnsortedComputer in $UnsortedComputers)
{
$ComputerName=$UnsortedComputer.Name
$destOU=(evalDepartment $ComputerName)

#Move the object into the target OU only if it has a match
If ($destOU)
    {
    Move-ADObject $UnsortedComputer -TargetPath $destOU
    Write-Output "Moved $ComputerName into $destOU <br>" >> C:\ComputerSort\ComputersMoved.html
    }
    else
    {
    Write-Output "Computer $ComputerName could not be matched. <br>" >> C:\ComputerSort\ComputersMoved.html
    }

}


#Send the email report of the computers that were moved, delete the results file
$date = ( get-date ).ToString('MM/dd/yyyy')
sendEmail ComputerSort@example.com AdminEmail@example.com "Computers Moved - $Date" smtp.example.com C:\ComputerSort\ComputersMoved.html



#Delete the file again just to be sure
Remove-Item C:\ComputerSort\ComputersMoved.html -Force
