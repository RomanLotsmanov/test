Import-Module -Name virtualmachinemanager
Import-Module -Name virtualmachinemanagercore

$VMMServer = Get-SCVMMServer -ComputerName "vmm.contoso.ru"
$OfficeID = "office"
$KMhostGroup = "all hosts\dc"  # обязательно маленькими буквами все


<#
  --- function for work with Hyper-V host
#>

function Hyper-AddHost ($l_hostGroup, $l_VMHost)
{
$runAsAccount = Get-SCRunAsAccount -Name "vmm-runas"
$hostGroup = Get-SCVMHostGroup -Name $l_hostGroup
Add-SCVMHost -ComputerName $l_VMHost -RunAsynchronously -VMHostGroup $hostGroup -VMPaths "c:\vm" -Credential $runAsAccount
}

function Hyper-NewVSwich ($l_VMHost, $l_vSwitch, $l_vlan)
{
$JobGuid = [System.Guid]::NewGuid().ToString()
$vmHost = Get-SCVMHost $l_VMHost
$hostAdapter = Get-SCVMHostNetworkAdapter -VMHost $vmHost -Name "Microsoft Network Adapter Multiplexor Driver"
$virtualSwitch = New-SCVirtualNetwork -VMHost $vmHost -Name $l_vSwitch -Description "" -JobGroup $JobGuid -BoundToVMHost $true -VMHostNetworkAdapters $hostAdapter #-HostBoundVLanId $l_vlan 
Set-SCVMHost -VMHost $vmHost -JobGroup $JobGuid -RunAsynchronously
}

<#
---END function for work with Hyper-V host
#>



<#
 --- function for work with Cloud
#>

function VM-TurnOffCloudTimeSync ($l_Cloud)
{
$AllVMs = Get-SCVirtualMachine | where { $_.Name -Match $l_Cloud }
foreach ($VM in $AllVMs)
{
 Set-SCVirtualMachine -VM $VM -EnableTimeSynchronization $false
}
}

function Cloud-SetCloud ($l_Cloud)
{
$UserRole = Get-SCUserRole -VMMServer $VMMServer -Name "self-service" 
$Cloud = Get-SCCloud -VMMServer $VMMServer | where {$_.Name -eq $l_Cloud}
$AllVMs = Get-SCVirtualMachine
foreach ($VM in $AllVMs)
{
if ($VM.HostGroupPath.ToLower().contains($KMhostGroup))
  {
    Write-Host $VM.Name
    Set-SCVirtualMachine -VM $VM -Cloud $Cloud
  }
}
}

function Cloud-SetCloudAndOwner ($l_Cloud)
{
$UserRole = Get-SCUserRole -VMMServer $VMMServer -Name "self-service" 
$Cloud = Get-SCCloud -VMMServer $VMMServer | where {$_.Name -eq $l_Cloud}
$AllVMs = Get-SCVirtualMachine | where { $_.Name -Match $l_Cloud }

foreach ($VM in $AllVMs)
{
Write-Host $VM.Name
    if (($VM.Name.ToLower().contains("dc")) -or ($VM.Name.ToLower().contains("net")))
    {
      Set-SCVirtualMachine -VM $VM -Owner "Ulmart\self-service-dc" -UserRole $UserRole -Cloud $Cloud
    } 
    if ($VM.Name.ToLower().contains("aster"))
    {
      Set-SCVirtualMachine -VM $VM -Owner "Ulmart\self-service-aster" -UserRole $UserRole -Cloud $Cloud
    } 
    if ($VM.Name.ToLower().contains("pr"))
    {
      Set-SCVirtualMachine -VM $VM -Owner "Ulmart\self-service-print" -UserRole $UserRole -Cloud $Cloud
    } 
    if (($VM.Name.ToLower().contains("squid")) -or ($VM.Name.ToLower().contains("prx")))
    {
      Set-SCVirtualMachine -VM $VM -Owner "Ulmart\self-service-squid" -UserRole $UserRole -Cloud $Cloud
    } 
    if ($VM.Name.ToLower().contains("vids"))
    {
      Set-SCVirtualMachine -VM $VM -Owner "Ulmart\self-service-vids" -UserRole $UserRole -Cloud $Cloud
    } 
    if ($VM.Name.ToLower().contains("vs"))
    {
      Set-SCVirtualMachine -VM $VM -Owner "Ulmart\self-service-sb" -UserRole $UserRole -Cloud $Cloud
    } 
}
}


function Cloud-SetCloudAdditionalOwner ($l_Cloud, $l_user)
{
$UserRole = Get-SCUserRole -VMMServer $VMMServer -Name "self-service" 
$Cloud = Get-SCCloud -VMMServer $VMMServer | where {$_.Name -eq $l_Cloud}
$AllVMs = Get-SCVirtualMachine | where { $_.Name -Match $l_Cloud }
foreach ($VM in $AllVMs)
{
Write-Host $VM.Name
Grant-SCResource -Resource $vm -UserName $l_user -UserRoleID $UserRole.Id -RunAsynchronously
}
}


function Cloud-SetNetwork ($l_Cloud)
{
$VLANs = (2 , 100, 101)
$AllVMs = Get-SCVirtualMachine | where { $_.Name -Match $l_Cloud }
foreach ($VM in $AllVMs)
{
$VirtualNetworkAdapter = Get-SCVirtualNetworkAdapter -VMMServer $VMMServer -VM $VM
$CountedNics = $VirtualNetworkAdapter.Count
for ($i=0; $i -lt $CountedNics; $i++)
{
  $VMNetwork = Get-SCVMNetwork -VMMServer $VMMServer -Name $l_Cloud"-LAN"
  Set-SCVirtualNetworkAdapter -VirtualNetworkAdapter $VirtualNetworkAdapter[$i] -VMNetwork $VMNetwork -VLanEnabled $false -VirtualNetwork $l_Cloud"-LAN" -MACAddressType Dynamic -IPv4AddressType Dynamic -IPv6AddressType Dynamic -NoPortClassification -VLanID $VLANs[$i]
}
}
}

<#
 --- END function for work with Cloud
#>



<#
 --- function for work with HostGroup
#>



<#
 --- function for work with HostGroup
#>



<#
--- function for work with VM
#>

function VM-NewFromTempl($l_VMHost, $l_VMname, $l_template, $l_OS, $l_hwProfile, $l_path, $l_Note)
{
  $VM = Get-SCVirtualMachine -Name $l_VMname
  if (!$VM)
  {
    $JobGuid = [System.Guid]::NewGuid().ToString()
    $VirtualHardDisk = Get-SCVirtualHardDisk -VMMServer $VMMServer | where {$_.Location -eq "\\vmw-inf-vmm.ulmart.ru\MSSCVMMLibrary\VHDs\"+$l_template} #| where {$_.HostName -eq "dc-vmm.ulmart.ru"}
     New-SCVirtualDiskDrive -VMMServer $VMMServer -SCSI -Bus 0 -LUN 0 -JobGroup $JobGuid -CreateDiffDisk $false -VirtualHardDisk $VirtualHardDisk -FileName $l_VMname".vhdx" -VolumeType BootAndSystem 
     $HardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where {$_.Name -eq $l_hwProfile}
     $vmHost = Get-SCVMHost $l_VMHost
     $operatingSystem = Get-SCOperatingSystem | where { $_.Name -eq $l_OS }
     if ($l_VMname.ToLower().contains("dc"))
     {
       New-SCVirtualMachine -Name $l_VMName -Description $l_Note -VMHost $VMHost -VMMServer $VMMServer -path $l_path -HardwareProfile $HardwareProfile -JobGroup $JobGuid -OperatingSystem $operatingSystem -ReturnImmediately -StartAction "TurnOnVMIfRunningWhenVSStopped" -StopAction "ShutdownGuestOS"
     }
     else
     {
       New-SCVirtualMachine -Name $l_VMName -Description $l_Note -VMHost $VMHost -VMMServer $VMMServer -path $l_path -HardwareProfile $HardwareProfile -JobGroup $JobGuid -OperatingSystem $operatingSystem -ReturnImmediately -StartAction "TurnOnVMIfRunningWhenVSStopped" -StopAction "SaveVM"
     }
  }
  else
  {
     Write-Host " NOT allow dublicate name. VM already exist, on host " $VM.VMHost.ComputerName  -ForegroundColor Red
  }
}

# to do -StartAction TurnOnVMIfRunningWhenVMStopped -StopAction SaveVM
function VM-Clone($l_VMSourceName, $l_VMdestHost, $l_VMDestName)
{
  $VM = Get-SCVirtualMachine -Name $l_VMSourceName
  if ($VM)
  {
    $JobGuid = [System.Guid]::NewGuid().ToString()
    $VM = Get-SCVirtualMachine -VMMServer $VMMServer -Name $l_VMSourceName
    $VMHost = Get-SCVMHost $l_VMdestHost
    New-SCVirtualMachine -VM $VM -Name $l_VMDestName -VMHost $VMHost -OperatingSystem $OperatingSystem -Path "c:\vm" -StartAction TurnOnVMIfRunningWhenVMStopped -DelayStartSeconds 0 -StopAction SaveVM
  }
  else
  {
     Write-Host " VM not found " -ForegroundColor Red
  }
}

function VM-SetCloudAndOwner ($l_VM, $l_Cloud, $l_selfservive)
{
$VM = Get-SCVirtualMachine -Name $l_VM
  if ($VM)
  {
    $UserRole = Get-SCUserRole -VMMServer $VMMServer -Name "self-service" 
    $Cloud = Get-SCCloud -VMMServer $VMMServer | where {$_.Name -eq $l_Cloud}
    Set-SCVirtualMachine -VM $VM -EnableTimeSynchronization $false -Owner $l_selfservive -UserRole $UserRole -Cloud $Cloud > $null
  }
  else
  {
     Write-Host " VM not found " -ForegroundColor Red
  }
}

function VM-ConvertDiskToFixed ($l_VM)
{
  $VM = Get-SCVirtualMachine -Name $l_VM
  if ($VM)
  {
    if ($VM.Status -eq "PowerOff")
    {
      $VirtualDiskDrive = Get-SCVirtualDiskDrive -VMMServer $VMMServer -VM $VM
      $CountedDisk = $VirtualDiskDrive.Count
      for ($i=0; $i -lt $CountedDisk; $i++)
      {
        Convert-SCVirtualDiskDrive -VirtualDiskDrive $VirtualDiskDrive[$i] -Fixed -RunAsynchronously > $null
      }
    }
    else
    {
      Write-Host " VM not in powerOff status" -ForegroundColor Red
    }
  }
  else
  {
     Write-Host " VM not found " -ForegroundColor Red
  }
}

# not stable work in Ubuntu ???
function VM-SetBootFirst ($l_vm)
{
  $VM = Get-SCVirtualMachine -Name $l_vm
  if ($VM)
  {
    Set-SCVirtualMachine -VM $VM -FirstBootDevice "SCSI,0,0"}
  else
  {
     Write-Host " VM not found " -ForegroundColor Red
  }
}


function VM-SetLan ($l_vm, $l_lan, $l_id, $l_vlan)
{
  $vm = Get-SCVirtualMachine -Name $l_vm
  if ($VM)
  {
    if (($_vlan))
    {
    $VirtualNetworkAdapter = Get-SCVirtualNetworkAdapter -VMMServer $VMMServer -VM $vm
    $VMNetwork = Get-SCVMNetwork -VMMServer $VMMServer -Name $l_lan
    Set-SCVirtualNetworkAdapter -VirtualNetworkAdapter $VirtualNetworkAdapter[$l_id] -VMNetwork $VMNetwork -VirtualNetwork $l_lan -IPv4AddressType Static -IPv6AddressType Static -NoPortClassification > $null
    }
    else
    {
    $VirtualNetworkAdapter = Get-SCVirtualNetworkAdapter -VMMServer $VMMServer -VM $vm
    $VMNetwork = Get-SCVMNetwork -VMMServer $VMMServer -Name $l_lan
    Set-SCVirtualNetworkAdapter -VirtualNetworkAdapter $VirtualNetworkAdapter[$l_id] -VMNetwork $VMNetwork -VLanEnabled $true -VLanID $l_vlan -VirtualNetwork $l_lan -IPv4AddressType Static -IPv6AddressType Static -NoPortClassification > $null
    }
  }
  else
  {
     Write-Host " VM not found " -ForegroundColor Red
  }
}

function VM-AddSCSIdisk ($l_vm, $l_number, $l_size, $l_path)
{
  $l_size = $l_size * 1024
  $filename = $l_vm+"_disk_"+$l_number
  $vm = Get-SCVirtualMachine -Name $l_vm
  if ($VM)
  {
    New-SCVirtualDiskDrive -VMMServer $VMMServer -VM $vm -SCSI -Bus 0 -LUN $l_number -VirtualHardDiskSizeMB $l_size -Dynamic -Filename $filename -VolumeType None -Path $l_path
  }
  else
  {
     Write-Host " VM not found " -ForegroundColor Red
  }
}

function VM-SetRam ($l_vm, $l_ram, $l_min, $l_max)
{
  $vm = Get-SCVirtualMachine -Name $l_vm
  if ($VM)
  {
    if ($VM.Status -eq "PowerOff")
    { 
      if (($l_min -eq 0) -and ($l_max -eq 0))
      {
        Set-SCVirtualMachine -VM $VM -MemoryMB ($l_ram*1024) -DynamicMemoryEnabled $false -RunAsynchronously  > $null
      }
      else
      {
        Set-SCVirtualMachine -VM $VM -MemoryMB ($l_ram*1024) -DynamicMemoryEnabled $true -DynamicMemoryMinimumMB ($l_min*1024) -DynamicMemoryMaximumMB ($l_max*1024) -DynamicMemoryBufferPercentage 20 -MemoryWeight 5000 -RunAsynchronously  > $null
      }
    }
    else
    {
      Write-Host " VM not in powerOff status" -ForegroundColor Red
    }
  }
  else
  {
     Write-Host " VM not found " -ForegroundColor Red
  }
}

function VM-SetCpu ($l_vm, $l_cpu)
{
  $vm = Get-SCVirtualMachine -Name $l_vm
  if ($VM)
  {
    if ($VM.Status -eq "PowerOff")
    { 
      Set-SCVirtualMachine -VM $VM -CPUCount $l_cpu > $null
    }
    else
    {
      Write-Host " VM not in powerOff status" -ForegroundColor Red
    }
  }
  else
  {
     Write-Host " VM not found " -ForegroundColor Red
  }
}

# -- TO DO -- if IDE must be in Power off
# -- TO DO -- verify range numb
# ++ To DO -- verify correct size
function VM-ExpandDisk ($l_vm, $l_numb, $l_size)
{
  $vm = Get-SCVirtualMachine -Name $l_vm
  if ($VM)
  {
    $VirtualDiskDrive = Get-SCVirtualDiskDrive -VMMServer $VMMServer -VM $vm 
    Write-Host ($VirtualDiskDrive[$l_numb].VirtualHardDisk.MaximumSize / 1GB)
    if ($l_size -gt ($VirtualDiskDrive[$l_numb].VirtualHardDisk.MaximumSize / 1GB))
    {
      Expand-SCVirtualDiskDrive -VirtualDiskDrive $VirtualDiskDrive[$l_numb] -VirtualHardDiskSizeGB $l_size > $null
    }
    else
    {
      Write-Host " no need expand " -ForegroundColor Red
    }
  }
  else
  {
     Write-Host " VM not found " -ForegroundColor Red
  }
}

function VM-AddFC ($l_vm, $l_num)
{
  $vm = Get-SCVirtualMachine -Name $l_vm
  if ($VM)
  {
    if ($VM.Status -eq "PowerOff")
    { 
      for ($i=0; $i -lt $l_num; $i++)
      {
        New-SCVirtualFibreChannelAdapter -vm $vm
      }
    }
    else
    {
      Write-Host " VM not in powerOff status" -ForegroundColor Red
    }
  }
  else
  {
    Write-Host " VM not found " -ForegroundColor Red
  }
}

# TO DO validate range
function VM-SetvSan ($l_vm, $l_num, $l_vsan)
{
  $vm = Get-SCVirtualMachine -Name $l_vm
  if ($VM)
  {
    $adapter = Get-SCVirtualFibreChannelAdapter -VM $vm
    $virtualSAN = Get-SCVMHostFibreChannelVirtualSAN -Name $l_vsan | where {$_.VMHost -eq $vm.VMHost}
    Set-SCVirtualFibreChannelAdapter -VirtualFibreChannelAdapter $adapter[$l_num] -VirtualFibreChannelSAN $virtualSAN
  }
  else
  {
    Write-Host " VM not found " -ForegroundColor Red
  }
}

function VM-AddNIC ($l_vm, $l_num)
{
  $vm = Get-SCVirtualMachine -Name $l_vm
  if ($VM)
  {
    if ($VM.Status -eq "PowerOff")
    { 
      for ($i=0; $i -lt $l_num; $i++)
      {
        New-SCVirtualNetworkAdapter -VM $vm -MACAddressType Dynamic -Synthetic
      }
    }
    else
    {
      Write-Host " VM not in powerOff status" -ForegroundColor Red
    }
  }
  else
  {
    Write-Host " VM not found " -ForegroundColor Red
  }
}

function VM-CreateCustomVM ($l_HVhost, $l_vmName, $l_Cluster, $l_tmplate, $l_OS, $l_VMprofile, $l_stor, $l_CPU, $l_ram, $l_ramMin, $l_ramMax, $l_HDDSize, $l_LanName, $l_VLAN, $l_cloud, $l_owner, $l_Note, $l_Type)
{
  Write-Host " "
  Write-Host "--- Start Create Custom VM ---" -ForegroundColor Green
  $Utimer = 10
  if ([string]::IsNullOrEmpty($l_Cluster))
  {


  }
    
  VM-NewfromTempl $l_HVhost $l_vmName $l_tmplate $l_OS $l_VMprofile $l_stor $l_Note
  Write-Host "- Create VM : " -ForegroundColor Green -NoNewline; Write-Host $l_vmName -NoNewline;Write-Host " on Host " -ForegroundColor Green -NoNewline;Write-Host $l_HVhost 
  Start-Sleep -Seconds $Utimer
  $vm = Get-SCVirtualMachine -Name $l_vmName
  While ($vm.status -eq "UnderCreation")
  {
    Write-Host "." -nonewline
    Start-Sleep -Seconds $Utimer
    $vm = Get-SCVirtualMachine -Name $l_vmName
  }
  Write-Host "  Create Successful"
  # Expand disk
  Write-Host "- Expand disk size Gb " -ForegroundColor Green -NoNewline;Write-Host $l_HDDSize
  VM-ExpandDisk $l_vmName 0 $l_HDDSize
  Start-Sleep -Seconds $Utimer
  $vm = Get-SCVirtualMachine -Name $l_vmName
  While ($vm.status -eq "UnderUpdate")
  {
    Write-Host "." -nonewline
    Start-Sleep -Seconds $Utimer
    $vm = Get-SCVirtualMachine -Name $l_vmName
  }
  Write-Host "  Expand Successful"
  # Convert HDDs to Fixed
  Write-Host "- Convert to fixed disk's " -ForegroundColor Green
  VM-ConvertDiskToFixed $l_vmName
  Start-Sleep -Seconds $Utimer
  $vm = Get-SCVirtualMachine -Name $l_vmName
  While ($vm.status -eq "UnderUpdate")
  {
    Write-Host "." -nonewline
    Start-Sleep -Seconds $Utimer
    $vm = Get-SCVirtualMachine -Name $l_vmName
  }
  Write-Host "  Convert Successful"
  # Set RAM
  Write-Host "- Set RAM Gb " -ForegroundColor Green -NoNewline; Write-Host $l_ram -NoNewline;
  if (($l_ramMin -ne 0) -or ($l_ramMax -ne 0))
  {
    Write-Host " dynamic RAM :   minRAM Gb " -ForegroundColor Green -NoNewline;Write-Host $l_ramMin -NoNewline;Write-Host " maxRAM Gb " -ForegroundColor Green -NoNewline;Write-Host $l_ramMax
  }
  else
  {
    Write-Host " static RAM "
  }
  VM-SetRam $l_vmName $l_ram $l_ramMin $l_ramMax
  Start-Sleep -Seconds $Utimer
  $vm = Get-SCVirtualMachine -Name $l_vmName
  While ($vm.status -eq "UnderUpdate")
  {
    Write-Host "." -nonewline
    Start-Sleep -Seconds $Utimer
    $vm = Get-SCVirtualMachine -Name $l_vmName
  }
  Write-Host "  Set RAM Successful"
  # Set CPU
  Write-Host "- Set CPU " -ForegroundColor Green -NoNewline; Write-Host $l_CPU
  VM-SetCpu $l_vmName $l_CPU
  Start-Sleep -Seconds $Utimer
  $vm = Get-SCVirtualMachine -Name $l_vmName
  While ($vm.status -eq "UnderUpdate")
  {
    Write-Host "." -nonewline
    Start-Sleep -Seconds $Utimer
    $vm = Get-SCVirtualMachine -Name $l_vmName
  }
  Write-Host "  Set CPU Successful"
  # Set LAN
  Write-Host "- Maping LAN " -ForegroundColor Green -NoNewline; Write-Host $l_LanName -NoNewline; Write-Host " vlan " -ForegroundColor Green -NoNewline; Write-Host $l_VLAN
  VM-SetLan $l_vmName $l_LanName 0 $l_VLAN
  Start-Sleep -Seconds $Utimer
  $vm = Get-SCVirtualMachine -Name $l_vmName
  While ($vm.status -eq "UnderUpdate")
  {
    Write-Host "." -nonewline
    Start-Sleep -Seconds $Utimer
    $vm = Get-SCVirtualMachine -Name $l_vmName
  }
  Write-Host "  Maping Lan Successful"
  # Set Owner Cloud
  Write-Host "- Set Owner " -ForegroundColor Green -NoNewline; Write-Host $l_owner -NoNewline;Write-Host " Cloud " -ForegroundColor Green -NoNewline;Write-Host $l_cloud
  VM-SetCloudAndOwner $l_vmName $l_cloud $l_owner
  Start-Sleep -Seconds $Utimer
  $vm = Get-SCVirtualMachine -Name $l_vmName
  While ($vm.status -eq "UnderUpdate")
  {
    Write-Host "." -nonewline
    Start-Sleep -Seconds $Utimer
    $vm = Get-SCVirtualMachine -Name $l_vmName
  }
  Write-Host "  Set Owner, Cloud Successful"
  Write-Host " "
  Write-Host "--- All Ready ---" -ForegroundColor Green
}

<#
--- END function for work with VM
#>

#Get-VirtualNetworkAdapter -All | group -Property PhysicalAddress | ? {$_.Count -gt 1} | % {$_.Group} | Select-Object Name, VirtualNetwork, PhysicalAddress 

#Hyper-HyperHost $KMhostGroup $OfficeID"-hv1"

#VM-CreateCustomVM "dc-hv29" "test-prx-vm11" "Cluster1" "g2-templ-srv-prx-2.vhdx" "CentOS Linux 7 (64bit)" "cluster-g2-CentOS7" "c:\ClusterStorage\Volume2\" 1 2 0 0 20 "dc-NEW-LAN" 103 "dc-Akod" "Ulmart\self-service-nix" "XXX" "PROD"

#Cloud-SetCloudAdditionalOwner "p43" "ulmart\test"
#Cloud-SetCloudAndOwner "a22"
#Cloud-SetCloud "a22"
#VM-NewFromTempl "z2-hv2" "z2-bc" "g2-templ-win16-std-eng-1.0.vhdx" "Windows Server 2012 R2 Standard" "g2-Office-Srv-win" "c:\vm" "branch cache"

<#$AllVMs = Get-SCVirtualMachine # -Name "dc-adc"

$KMhostGroup = "all hosts\lxdc"#akod

foreach ($VM in $AllVMs)
{
if (($VM.HostGroupPath.ToLower().contains($KMhostGroup)))
  {
  VM-SetLan $vm.Name "DC-NEW-LAN" 0 101
  }
  }  #>

#VM-AddSCSIdisk p43-bkp2 5 20 "c:\ClusterStorage\Volume5\p43-bkp2\"

#Get-SCVMHost "acdc-hv18" | Remove-SCVMHost -force

#VM-SetBootFirst "g2-ubuntu16.04-tst"

#VM-AddSCSIdisk "hpv-mydb01" 2 60 "c:\ClusterStorage\Volume2\"
#VM-ExpandDisk "hvp-1cdev" 0 800


#NewVSwich $OfficeID"-srv-hyper1" $OfficeID"-LAN" "0"
#NewVSwich $OfficeID"-srv-hyper2" $OfficeID"-LAN" "0"


#Cloud-TurnOffTimeSync $OfficeID
#Cloud-SetNetwork $OfficeID


<#

# create Cloud

Set-SCCloudCapacity -JobGroup "f295789a-eff6-4a3e-9002-c40112a56246" -UseCustomQuotaCountMaximum $true -UseMemoryMBMaximum $true -UseCPUCountMaximum $true -UseStorageGBMaximum $true -UseVMCountMaximum $true

$resources = @()
$resources += Get-SCLogicalNetwork -Name "p157-LAN" -ID "687ff43f-fc59-4981-bcd6-000927ce0d60"


Set-SCCloud -JobGroup "f295789a-eff6-4a3e-9002-c40112a56246" -RunAsynchronously -AddCloudResource $resources

$hostGroups = @()
$hostGroups += Get-SCVMHostGroup -ID "c849f04e-c18b-4083-a83e-c2c5858f7589"
New-SCCloud -JobGroup "f295789a-eff6-4a3e-9002-c40112a56246" -VMHostGroup $hostGroups -Name "p157" -Description "" -RunAsynchronously

#cloud access
$cloud = Get-SCCloud -ID "b562f13f-7c97-43ee-a558-a5cf8ddea809"
Set-SCUserRoleQuota -Cloud $cloud -JobGroup "0c7545e4-5b89-4f3b-a14a-0573aae7120b"
Set-SCUserRoleQuota -Cloud $cloud -JobGroup "0c7545e4-5b89-4f3b-a14a-0573aae7120b" -QuotaPerUser

$userRole = Get-SCUserRole -Name "self-service" -ID "81519624-9e4e-4394-b8cc-30cb246b2cda"
$scopeToAdd = @()
$scopeToAdd += Get-SCCloud -ID "52200176-c5df-4db0-9923-32d80accacd1"
Set-SCUserRole -UserRole $userRole -Description "ulmart self service" -JobGroup "0c7545e4-5b89-4f3b-a14a-0573aae7120b" -Name "self-service" -AddScope $scopeToAdd -ShowPROTips $false



#create vlan

$logicalNetwork = Get-SCLogicalNetwork -ID "687ff43f-fc59-4981-bcd6-000927ce0d60"
Set-SCLogicalNetwork -Name "p157-LAN" -Description "" -LogicalNetwork $logicalNetwork -RunAsynchronously -EnableNetworkVirtualization $false -UseGRE $false -LogicalNetworkDefinitionIsolation $false

$allHostGroups = @()
$allHostGroups += Get-SCVMHostGroup -ID "c849f04e-c18b-4083-a83e-c2c5858f7589"
$allSubnetVlan = @()
$allSubnetVlan += New-SCSubnetVLan -Subnet "172.18.1.0/24" -VLanID 101
$allSubnetVlan += New-SCSubnetVLan -Subnet "172.0.0.0/24" -VLanID 100
$allSubnetVlan += New-SCSubnetVLan -Subnet "10.240.112.0/24" -VLanID 2

New-SCLogicalNetworkDefinition -Name "p157-LAN" -LogicalNetwork $logicalNetwork -VMHostGroup $allHostGroups -SubnetVLan $allSubnetVlan -RunAsynchronously

#>