#Written by Curt Marker 09-19-16
#The purpose of this script is to populate the Unix attributes of AD Users
#The script looks at the highest uidNumber being used in AD to start.
#The script now also sets the gidNumber on Groups in AD finding the highest first to start.



#These are the values that are being set for users and their default.
#     uidNumber - A unique increasing number to be set
#     gidNumber - A default value (10000077)
#     UnixHomeDirectory - /home/username
#     loginShell -  /bin/bash

#This is the value that is being set for Groups and their default
#     gidNumber - A unigue increasing number to be set


#Specify the DN for the OU's that you want to search, can be multiple OU's added into the array.
$UserOUPaths = @("")
$GroupOUPaths = @("")







#Used to send the email message
Function sendEmail
{ param($from,$to,$subject,$smtphost,$htmlFileName)
$body = Get-Content $htmlFileName
$smtp = New-Object System.Net.Mail.SmtpClient $smtphost
$msg = New-Object System.Net.Mail.MailMessage $from, $to, $subject, $body
$msg.isBodyhtml = $true
$smtp.send($msg)
}





########################################################################
#           This is the setup for Logging
########################################################################

#Per Run Log File location
$logLoc = "C:\Set-UnixAttributes\set-unixAttributesLOG.html"

#Delete the previous log
Remove-Item $logLoc -Force >$null 2>&1

#Set a date and time on the log file
$date = ( get-date ).ToString('MM/dd/yyyy')
$dateandTime = Get-Date
Write-Output "------------------------------------------------------------------------- <br>" > $logLoc
Write-Output "-                        Start run: $dateandTime <br>" >> $logLoc
Write-Output "------------------------------------------------------------------------- <br>" >> $logLoc


########################################################################
#           This is the User Attribute Section
########################################################################

#Query AD to find the highest uidNumber being Used
$highuid = Get-ADUser -LDAPFilter "(uidNumber=*)" -Properties uidNumber | Measure-Object -Property uidNumber -Maximum | Select-Object -ExpandProperty Maximum

#Incriment one from the highest uid number
$highuid++

#Set the next UID into the variable
$nextUIDNumber = $highuid

#Check to see if the uid number is in use
while (Get-ADUser -LDAPFilter "(uidNumber=$nextUIDNumber)")
    {
    #If the number is in use, incriment and check again
    $nextUIDNumber++
    }

#Spceify multiple User OUs to search through

$Users=$UserOUPaths | foreach { Get-ADUser -SearchBase $_ -SearchScope Subtree -Filter * -Properties samAccountName,uidNumber,gidNumber,UnixHomeDirectory,loginShell,objectSID | Sort -Property SAMAccountname }


#Foreach Loop to parse Users under the search base OU
foreach ($user in $Users)
    {
    #Get the username in a usable format
    $UserSAM = $user.samAccountName
    $UserSID = $user.objectSID

    #If uidNuber Not Set, then set and incriment
    if ($user.uidNumber -eq $Null)
        {
        Set-ADUser -Identity $UserSID -Replace @{uidnumber = "$nextUIDNumber"}

        #Add some logging to a file
        Write-Output "For User $UserSAM set uidNumber to $nextUIDNumber <br>" >> $logLoc

        #Incriment last uidNumber to next usable one
        $nextUIDNumber++
        #Check to see if the uid number is in use
        while (Get-ADUser -LDAPFilter "(uidNumber=$nextUIDNumber)")
            {
            #If the number is in use, incriment and check again
            $nextUIDNumber++
            }
        }

    #If gidNumber not set, then set to default
    if ($user.gidNumber -eq $Null)
        {
        Set-ADUser -Identity $UserSID -Replace @{gidNumber = "10000077"}

        #Add some logging to a file
        Write-Output "For User $UserSAM set gidNumber to 10000077 <br>" >> $logLoc
        }

    #If Unix Home Directory not set, then set to default
    if ($user.UnixHomeDirectory -eq $Null)
        {
        Set-ADUser -Identity $UserSID -Replace @{UnixHomeDirectory = "/home/$UserSAM"}

        #Add some logging to a file
        Write-Output "For User $UserSAM set UnixHomeDirectory to /home/$UserSAM <br>" >> $logLoc
        }

    #If shell not set, then set to default
    if ($user.loginShell -eq $Null)
        {
        Set-ADUser -Identity $UserSID -Replace @{loginShell = "/bin/bash"}

        #Add some logging to a file
        Write-Output "For User $UserSAM set loginShell to /bin/bash <br>" >> $logLoc
        }

    #End of the Foreach loop
    }


########################################################################
#           This is the Group Attribute Section
########################################################################

#Query AD to find the highest gidNumber being Used
$highgid = Get-ADGroup -LDAPFilter "(gidNumber=*)" -Properties gidNumber | Measure-Object -Property gidNumber -Maximum | Select-Object -ExpandProperty Maximum

#Incriment one from the highest gid number
$highgid++

#Set the next available GID into variable
$nextGIDNumber = $highgid

#Check to see if the gid number is in use
while (Get-ADGroup -LDAPFilter "(gidNumber=$nextGIDNumber)")
    {
    #If the number is in use, incriment and check again
    $nextGIDNumber++
    }


$Groups=$GroupOUPaths | foreach { Get-ADGroup -SearchBase $_ -SearchScope Subtree -Filter * -Properties gidNumber,objectSID | Sort -Property name }


#Foreach Loop to parse Groups under the search base OU
foreach ($Group in $Groups)
    {
    #Get the name of the group to use
    $GroupName = $Group.name
    $GroupSID = $Group.objectSID

    #If gidNuber Not Set, then set and incriment
    if ($group.gidNumber -eq $Null)
        {
        Set-ADGroup -Identity $GroupSID -Replace @{gidnumber = "$nextGIDNumber"}

        #Add some logging to a file
        Write-Output "For Group $GroupName set gidNumber to $nextGIDNumber <br>" >> $logLoc

        #Incriment last gidNumber to next usable one
        $nextGIDNumber++
        #Check to see if the gid number is in use
        while (Get-ADGroup -LDAPFilter "(gidNumber=$nextGIDNumber)")
            {
            #If the number is in use, incriment and check again
            $nextGIDNumber++
            }
        }
    #End of the Foreach loop
    }


########################################################################
#           This is the Logging and Notification Section
########################################################################

#End the log file
$dateandTime = Get-Date
Write-Output "------------------------------------------------------------------------- <br>" >> $logLoc
Write-Output "-                        End run: $dateandTime <br>" >> $logLoc
Write-Output "------------------------------------------------------------------------- <br>" >> $logLoc

#Report the next usable uidNumber in the log
Write-Output "-                        The next usable uid Number is $nextUIDNumber <br>" >> $logLoc
Write-Output "------------------------------------------------------------------------- <br>" >> $logLoc

#Report the next usable gidNumber in the log
Write-Output "-                        The next usable gid Number is $nextGIDNumber <br>" >> $logLoc
Write-Output "------------------------------------------------------------------------- <br>" >> $logLoc

#Send email notifications
sendEmail report-user@domain.com target-user@domain.com "Disk Space Report - $Date" smtp.domain.com $logLoc
