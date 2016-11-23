#Script used to search for Reservations across all scopes on a DHCP server

#Set DHCP Server address
$dhcpServer = ""


#Set the target MAC that you are trying to find.
#Format like AA-BB-11-22-CC-DD
$targetMAC = ""

$scopes=$(Get-DhcpServerv4Scope –ComputerName $dhcpServer)
Foreach ($scope in $scopes)
    {
    Get-DhcpServerv4Lease -ComputerName $dhcpServer -ScopeID $scope.scopeID -ClientId $targetMAC 2> $null
    }
