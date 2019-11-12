Import-Module -Name virtualmachinemanager
Import-Module -Name virtualmachinemanagercore

$date = get-date -format "dd.MM.yyyy_HH-mm"
$CSVfile = "c:\_tmp\" + $date
$VMMServer = Get-SCVMMServer -ComputerName "dc-vmm.ulmart.ru"
#$KMhostGroup = "all hosts\akod\prod\cluster2"
$KMhostGroup = "all hosts\m24dc"
#$KMhostGroup = "all hosts\офисы"
$AllVMs = Get-SCVirtualMachine # -Name "dc-adc"

$results = @()

foreach ($VM in $AllVMs)
{
if (($VM.HostGroupPath.ToLower().contains($KMhostGroup)) -and ($VM.Name.ToLower().contains("squid")))
  {
    #Write-Host $VM.Name  " "  $VM.VMHost.Name
  }
if (($VM.HostGroupPath.ToLower().contains($KMhostGroup)) -and ($VM.Name.ToLower().contains("aster")))
  {
   # Write-Host $VM.Name  " "  $VM.VMHost.Name
  }
if (($VM.HostGroupPath.ToLower().contains($KMhostGroup)) -and ($VM.Name.ToLower().contains("pr")))
  {
  #  Write-Host $VM.Name  " "  $VM.VMHost.Name
  }
if (($VM.HostGroupPath.ToLower().contains($KMhostGroup)))# -and (($VM.Name.ToLower().contains("dc"))) -or ($VM.Name.ToLower().contains("net")))
#if (($VM.HostGroupPath.ToLower().contains($KMhostGroup)) -and ($VM.CreationTime.Year -eq 2016) -and ($VM.CreationTime.Month -gt 6))
  {
    $details = @{            
                  #VMHost      = $vm.VMHost.ComputerName
                  #GUID          = $vm.ID
                  VM          = $vm.Name
                  vmOS        = $vm.OperatingSystem
                  Owner       = $vm.Owner
                  #Status      = $vm.Status
#                   StartAction = $vm.StartAction
 #                 StopAction  = $vm.StopAction
  #                Generation  = $vm.Generation
   #                OSHyperV    = $vm.VMHost.OperatingSystem
                  #Cpu         = $vm.CPUCount
                  #Ram         = [decimal]::round($vm.Memory / 1KB)
      #            CreateDate  = $vm.CreationTime
                  #Size        = [decimal]::round($vm.TotalSize /1GB)
        #          Description = $vm.Description
          #        Cloud       = $vm.Cloud
                  #A1_WWPN = $vm.VirtualFibreChannelAdapters[0].PrimaryWorldWidePortName
                  #B1_WWPN = $vm.VirtualFibreChannelAdapters[0].SecondaryWorldWidePortName
                  #A2_WWPN = $vm.VirtualFibreChannelAdapters[1].PrimaryWorldWidePortName
                  #B2_WWPN = $vm.VirtualFibreChannelAdapters[1].SecondaryWorldWidePortName
                  NIC_count = $vm.VirtualNetworkAdapters.count
                  NIC1    = $vm.VirtualNetworkAdapters[0].MACAddress
                  NIC1type   = $vm.VirtualNetworkAdapters[0].MACAddressType
                  NIC1vlan = $vm.VirtualNetworkAdapters[0].VLanID
                  NIC2    = $vm.VirtualNetworkAdapters[1].MACAddress
                  NIC2type   = $vm.VirtualNetworkAdapters[1].MACAddressType
                  NIC2vlan = $vm.VirtualNetworkAdapters[1].VLanID
                  NIC3    = $vm.VirtualNetworkAdapters[2].MACAddress
                  NIC3type   = $vm.VirtualNetworkAdapters[2].MACAddressType
                  NIC3vlan = $vm.VirtualNetworkAdapters[3].VLanID
           #       fqdn     = $vm.ComputerNameString
           #       hdd1name = $vm.VirtualHardDisks[0].Location
           #       hdd1size = [decimal]::round($vm.VirtualHardDisks[0].size / 1GB)
           #       hdd1type = $vm.VirtualHardDisks[0].VHDType
           #       hdd2name = $vm.VirtualHardDisks[1].Location
           #       hdd2size = [decimal]::round($vm.VirtualHardDisks[1].size / 1GB)
           #       hdd2type = $vm.VirtualHardDisks[1].VHDType

                }
    $results += New-Object PSObject -Property $details
  }
}
$results = $results | Sort-Object "VM"
$results | export-csv -Path $CSVfile".csv" -NoTypeInformation -Delimiter ";"