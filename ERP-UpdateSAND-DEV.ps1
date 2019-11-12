# 
# Скрипт обновления тестовой DEV  v 2.0.27
# 
# 
#  2.0.25  добавлено автооповещение дозера об уведомлении юзеров
#  2.0.26
#  2.0.27  изменены папки распаковки, и добавлен файл флага date.flag добавлено логирование обновлений
#  2.0.28  Change Copy-Item on Win-CopyItem with WinOS progress window 30.07.19
#  2.0.29  Change Copy-Item on Win-CopyItem tested 01.08.19
#  2.0.30  Chande FS share to local c:\_tmp for speed, fix client Update $scr
#
# ОБЩИЕ ПЕРЕМЕННЫЕ
#

$tmp = get-random -max 9999 -min 1000
                 
$UpdateFileLog = "...\ultima_distrib\UpdateLog.log"

$date = get-date -format "dd.MM.yyyy_HH-mm"          # Дата время = (номер сборки)
$appservers = @("..-dev","..02-dev");	                 	 # Сервера приложений
$wwwservers = @("..-dev","..02-dev");                         # WWW Сервера

$services = @("UltimaService_t", "ReportService_t", "WMSService_t", "W3SVC","ReportService", "WmsService", "WmsUpdaterService");									# Сервисы которые надо стопнуть
$process_names = @("w3wp.exe", "UltimaService.exe", "ReportService.exe", "WmsService.exe", "WmsUpdaterService.exe");                                                                    # процессы которые убить
$UltimaPacks=@("UltimaServer.zip", "UltimaClient.zip", "WebService.zip", "Scoreboard.zip", "PrintTerminal.zip", "PrintServer.zip", "SapIntegrationService.zip","WebServicePriceSettings.zip");    # Пакеты которые скачать и положить в SVN

$MaxBackup=20                                        # максимальное количество бэкапов


$path_to_update = "c:\_tmp\SAND-DEV\_unpack\"                         # временная папка для распаковки
$path_svn_dev = "c:\_tmp\SAND-DEV\"                   # путь для хранения дистрибов релизов по датам

$flag_updateclient = 1                               # флаг обновления клиента
$flag_updateservers = 1                              # флаг обновления сервисов
$flag_stopservices = 1                               # флаг остановки сервисов
$flag_rollback = 0                                   # флаг отката, если стоит 1 то фактическы вместо обновления выполнится откат на указанную версию
$roolback_date = "27.07.2015_11-21"                  # дата время в формате 27.06.2013_11-56 фактически папка в svn 

#
#	ФУНКЦИИ
#

# -- скачивание
function Download_File($si_UserName, $si_Password, $si_Source_Path, $si_Target_Path)
{

	$oi_Credentials = New-Object System.Net.NetworkCredential($si_UserName, $si_Password)
	$oi_Web_Client = New-Object System.Net.WebClient
	$oi_Web_Client.Credentials = $oi_Credentials
	$oi_Web_Client.DownloadFile($si_Source_Path, $si_Target_Path)
}

function Extract-Zip($zipfile, $destination)
{
	if(test-path($zipfile))
	{	
	    New-Item $destination -type directory
		$shellApplication = new-object -com shell.application
		$zipPackage = $shellApplication.NameSpace($zipfile)
		$destinationFolder = $shellApplication.NameSpace($destination)
		$destinationFolder.CopyHere($zipPackage.Items())
	}
}


# -- распаковка
function Unzip_Files($zipfile, $destination)
{
    if ((Test-Path -path $destination))
    {
       Remove-Item $destination -Recurse
    }
    if(test-path($zipfile))
    {    
	    $shellApplication = new-object -com shell.application 
        $zipPackage = $shellApplication.NameSpace($zipfile) 
	if(!(test-path($destination)))
	{
		New-Item $destination -type directory	
	}
	    $destinationFolder = $shellApplication.NameSpace($destination) 
        $destinationFolder.CopyHere($zipPackage.Items())  # 0x14  overwrite
    }
    else 
   { 
     Write-Host "Исходного ZIP не найдено : "$zipfile;
   }
}

# -- ротация бэкапов
function Rotation()
{
  $Backups = @(dir $HomeBkpDir | Where-Object { $_.PSIsContainer } | sort-object -Property CreationTime);
  $NbrBackups = ($Backups.count - 1);
  Write-Host "Количество архивных копий в момент завершения архивации: " $NbrBackups "шт";
  $i = 0;
  while ($NbrBackups -ge $MaxBackup) # Удаляем старые  backups
  {
    $Backups[$i] | Remove-Item -Force -Recurse -Confirm:$false;
    $NbrBackups -= 1;
    $i++;
  }
}

function WinCopy-Item($l_SourceFolder, $l_DestFolder, $l_flag)
<#$l_flag
(0)
Default. No options specified.

(4)
Do not display a progress dialog box.

(8)
Rename the target file if a file exists at the target location with the same name.

(16)
Click "Yes to All" in any dialog box displayed.

(64)
Preserve undo information, if possible.

(128)
Perform the operation only if a wildcard file name (*.*) is specified.

(256)
Display a progress dialog box but do not show the file names.

(512)
Do not confirm the creation of a new directory if the operation requires one to be created.

(1024)
Do not display a user interface if an error occurs.

(4096)
Disable recursion.

(8192)
Do not copy connected files as a group. Only copy the specified files. #>

{
  $SourceFolder = (new-object -com shell.application).NameSpace($l_SourceFolder)
  $DestinationFolder = (new-object -com shell.application).NameSpace($l_DestFolder)
  $DestinationFolder.CopyHere($SourceFolder.Items(),$l_flag)
}

# -- обновление клиента
function UpdateClient($server, $path)
{
  Write-Host "Сначала действуем в лоб, пробуем заменить файлы клиента "
  $old_path = $path + "_"
  if ((Test-Path -path $old_path))
  {
    Remove-Item $old_path -Recurse
  }
  Rename-Item $path $old_path
  if (-not(Test-Path -path $old_path))
  {
    Write-Host "...в лоб не вышло ищем блокирующие дискрипторы"
	Write-Host "Запрос на разблокировку ulmart_test\LocalModules на сервере " $server
    $opnfls= openfiles /query /S $server /fo CSV | where-object {$_ -like "*ulmart_test\LocalModules*"}
    if ($opnfls)
    {
      Write-Host "Заблокированы файлы, разблокируем :"
      foreach ($opnfl in $opnfls)
      {
        Write-Host $opnfl
        openfiles /disconnect /S $server /OP $opnfl /id * 
      }
    }  
    else
    {
      Write-Host "Заблокированных файлов нет"
    }
    Rename-Item $path $old_path
	if (-not(Test-Path -path $old_path)) {
	  Write-Host "все равно не вышло после разблокировки" }
  }	
  
  Write-Host "Обновляем клиента "$server"..."
  mkdir $path
  if ((Test-Path -path $old_path))
  {
    Remove-Item $old_path -Recurse
  }
  $src = $path_to_update + "UltimaClient.zip\LocalModules\"
  #copy-item $src -destination $path -force -recurse 
  if (-not(Test-Path -path $path))
  {
     mkdir $path
  }
  WinCopy-Item $src $path 16
}

# -- остановка сервисов
function StopService($appserver_l, $service_l)
{
 $Svc = Get-WmiObject -computer $appserver_l win32_service -filter "name='$service_l'" 
 if($Svc)
	{
		# Write-Host $Svc.State
		Write-Host "Выключаем $service_l на $appserver_l ..." -NoNewline
        $result = $Svc.ChangeStartMode("Disabled")
    	Write-Host -ForegroundColor Green "OK"
		Write-Host "Останавливаем $service_l на $appserver_l ..." -NoNewline
		$result = $Svc.StopService()
        Write-Host -ForegroundColor Green "OK"
	}
}

# -- рубим процессы
function KillProcess($appserver_l, $process_name_l)
{
    Write-Host "	... $process_name на $appserver_l " -NoNewline
	$proc = Get-WmiObject win32_process -filter "name='$process_name_l'" -computer $appserver_l
	if($proc) { 
              foreach ($process in $proc) {
                 $returnval = $process.terminate()
                 $processid = $process.handle
                 if($returnval.returnvalue -eq 0) {
                    Write-Host -ForegroundColor Red "убит"
                 }
                  else {
                    write-host -ForegroundColor Blue "не смогли убить"
                 }
               }
             }
	else 
	        {
			  Write-Host -ForegroundColor Green "не найден"
			}
}

# -- стартуем сервисы
function StartService($appserver_l, $service_l)
{
    $Svc = Get-WmiObject -computer $appserver_l win32_service -filter "name='$service_l'" 
    if($Svc)
    	{
			Write-Host "Включаем $service_l на $appserver_l ... " -NoNewline
            $result = $Svc.ChangeStartMode("Automatic")
			Write-Host -ForegroundColor Green "OK"
			Write-Host "Стартуем $service_l на $appserver_l ... " -NoNewline
			$result = $Svc.StartService()
            Write-Host -ForegroundColor Green "OK"
		}
}


#
# Основное тело скрипта
#

Clear-Host
Write-Host -ForegroundColor Black -BackgroundColor Red "ОБНОВЛЕНИЕ ДЕВ СЕРВЕРА Ultima-CLOUD-DEV"
Write-Host "Для запуска обновления введите число в квадратных скобках [$tmp]"
$answer = read-host "Type message:"
if (-not($tmp -eq $answer))
{
	Write-Host "Введённый код не соответствует. Обновление серверов прерванно."
	break
}
$a = 'SAND-DEV -> ' + $date | Out-File $UpdateFileLog -Append
$dateF = $path_to_update + "\time.flag"
 $a = $date | Out-File $dateF
 #$sCMD = '"z:\AdminUtils\Messenger full\MessengerConsoleClient.exe" send itinfo "Внимание! Обновление тестовой базы Ulmart_test через 5 мин, недоступность на 10-15 мин, после обновления нужно перезапустить тестовую базу. Спасибо за понимание." -a'
# Invoke-Expression "& $sCMD"
# Start-Sleep -Seconds 180

if (-not($flag_rollback))
{
   $path_svn_dev = $path_svn_dev + $date + "\"          # текущий релиз
}

# создаем директорию под текущий дистриб
if ((-not(Test-Path -path $path_svn_dev)) -and (-not($flag_rollback)))
  {
     mkdir $path_svn_dev
  }

# Скачиваем все нужные пакеты с Ультимы
if (-not($flag_rollback)) # если это не откат то конечно качаем файлы
{
  Write-Host -ForegroundColor Black -BackgroundColor Green "  выполняется обновление"
  Write-Host "Скачиваем все необходимые пакеты с Ультимы и кладем в SVN "$path_svn_dev
  foreach ($Pack in $UltimaPacks)
  {
    Write-Host "Скачиваем пакет "$Pack"... " -NoNewline
    $path = $path_svn_dev + $Pack
    $Pack = "http://download.xxxxxxx.ru/distr/" + $Pack
    Download_File "usr" "pass" $Pack $path
    Write-Host -ForegroundColor Green "OK"
  }
}  
else  # иначе просто взять дисриб старый и использовать для обновления, иначе говоря откатить
{
  $path_svn_dev = $path_svn_dev + $roolback_date + "\"
  Write-Host -ForegroundColor Black -BackgroundColor Green "  выполняется откат из директории : " $path_svn_dev
}

# Распаковываем нужные пакеты
foreach ($Pack in $UltimaPacks)
{
  $path = $path_to_update + $Pack
  Write-Host "Распаковываем "$Pack"... " -NoNewline
  $zip = $path_svn_dev+$Pack
  Unzip_Files $zip $path
  Write-Host -ForegroundColor Green "OK"
}

# останавливаем сервисы и убиваем процессы
if ($flag_stopservices)
{
  foreach ($appserver in $appservers)
  {
    foreach ($service in $services)
    {
      StopService $appserver $service
    }
  }
  Start-Sleep -Seconds 10
  Write-Host "Убиваем оставшиеся процессы :"
  foreach ($appserver in $appservers)
  {
    foreach ($process_name in $process_names)
    {
	   KillProcess $appserver $process_name
    }
  }
  Start-Sleep -Seconds 10
}  

# обновляем сервисы
if($flag_updateservers)
{
  foreach ($appserver in $appservers)
  {
	Write-Host "Обновление Ultima сервиса на $appserver ... " -NoNewline
	$src = $path_to_update + "UltimaServer.zip\"  #*
	$dest = "\\"+$appserver+"\c$\test_ulmart\"
  #copy-item $src -destination $dest -force -recurse
  WinCopy-Item $src $dest 16
	Write-Host -ForegroundColor Green "Успешно"
  }
  
  $src = $path_to_update + "WebService.zip\"
  Remove-Item -Path $src"zlib.dll" -Force
  foreach ($wwwserver in $wwwservers)
  {
	Write-Host "Обновление WWW сервисов на $wwwserver ... " -NoNewline
	$dest = "\\"+$wwwserver+"\c$\Inetpub\wwwroot\UltimaWebServiceTest\bin\"
     #copy-item $src -destination $dest -force -recurse -exclude "zlib.dll" 
    WinCopy-Item $src $dest 16
	Write-Host -ForegroundColor Green "Успешно"
  }

  $src = $path_to_update + "WebServicePriceSettings.zip\"
  foreach ($wwwserver in $wwwservers)
  {
	Write-Host "Обновление WebServicePriceSettings сервисов на $wwwserver ... " -NoNewline
	$dest = "\\"+$wwwserver+"\c$\Inetpub\wwwroot\WebServicePriceSettings\bin\"
      #copy-item $src -destination $dest -force -recurse -exclude "zlib.dll"
    WinCopy-Item $src $dest 16
	Write-Host -ForegroundColor Green "Успешно"
  }
  
  foreach ($wwwserver in $wwwservers)
  {
  Write-Host "Обновление SAPIntegration сервиса на $wwwserver ... " -NoNewline
  $src = $path_to_update + "SapIntegrationService.zip\"
  $dest = "\\"+$wwwserver+"\c$\Inetpub\wwwroot\SapIntegrationServiceTest\bin\"
  #copy-item $src -destination $dest -force
  WinCopy-Item $src $dest 16
  Write-Host -ForegroundColor Green "Успешно"
  }
}  


# стартуем сервисы
if ($flag_stopservices)
{
  Write-Host "Запускаем сервисы :"
  foreach ($appserver in $appservers)
  {
    foreach ($service in $services)
    {
	  StartService $appserver $service
	}
  }
}

	
# Обновляем клиента
if($flag_updateclient)
{
  UpdateClient "fscl1fs" "...\soft\..."
}
else
{
  Write-Host -ForegroundColor "green" "Обновление клиента не производилось"
}	

Write-Host "Все готово."