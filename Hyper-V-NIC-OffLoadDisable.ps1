$teamName = "Uplink"
$LANs = @("vEthernet (XXXXXX)","Uplink")

$nics = Get-NetAdapter
$i = 1
foreach ($nic in $nics)
{
   if (($nic.InterfaceDescription.ToLower().contains("emulex")) -or ($nic.InterfaceDescription.ToLower().contains("intel")))
   {
     Write-Host $nic.Name " " NIC$i " " $nic.InterfaceDescription
     Rename-NetAdapter -Name $nic.Name -NewName NIC$i
   }
   $i++
}

Remove-NetLbfoTeamMember NIC1 $teamName -Confirm:$false
Remove-NetLbfoTeamMember NIC2 $teamName -Confirm:$false
Start-Sleep -Seconds 15

Disable-NetAdapterChecksumOffload  -Name NIC1, NIC2
Disable-NetAdapterEncapsulatedPacketTaskOffload -Name NIC1, NIC2
Disable-NetAdapterIPsecOffload -Name NIC1, NIC2
Disable-NetAdapterLso -Name NIC1, NIC2
Disable-NetAdapterRsc -Name NIC1, NIC2
Disable-NetAdapterRss -Name NIC1, NIC2

Add-NetLbfoTeamMember NIC1 $teamName -Confirm:$false
Add-NetLbfoTeamMember NIC2 $teamName -Confirm:$false
Start-Sleep -Seconds 15
Remove-NetLbfoTeamMember NIC3 $teamName -Confirm:$false
Remove-NetLbfoTeamMember NIC4 $teamName -Confirm:$false
Start-Sleep -Seconds 15

Disable-NetAdapterChecksumOffload  -Name NIC3, NIC4
Disable-NetAdapterEncapsulatedPacketTaskOffload -Name NIC3, NIC4
Disable-NetAdapterIPsecOffload -Name NIC3, NIC4
Disable-NetAdapterLso -Name NIC3, NIC4
Disable-NetAdapterRsc -Name NIC3, NIC4
Disable-NetAdapterRss -Name NIC3, NIC4

Add-NetLbfoTeamMember NIC3 $teamName -Confirm:$false
Add-NetLbfoTeamMember NIC4 $teamName -Confirm:$false
Start-Sleep -Seconds 15

foreach ($LAN in $LANs) 
{
  Disable-NetAdapterChecksumOffload  -Name $LAN
  Disable-NetAdapterEncapsulatedPacketTaskOffload -Name $LAN
  Disable-NetAdapterIPsecOffload -Name $LAN
  Disable-NetAdapterLso -Name $LAN
  Disable-NetAdapterRsc -Name $LAN
  Disable-NetAdapterRss -Name $LAN
}

#Get-NetAdapterAdvancedProperty -Name * -AllProperties