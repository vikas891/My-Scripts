﻿#########################################################################################
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

#Pulling Bad Services
$serv = Get-WmiObject win32_service | where {($_.PathName -like "cmd /c powershell -exec bypass*" -and $_.PathName -like "*downloadstring*") -or ($_.PathName -like "*powershell*" -and $_.PathName -like "*bypass -e*")  -or $_.Pathname -like "*cmd /c mshta*" }
$servcount = $serv | Measure-Object | Select-Object Count

#Pulling Active Processes
$Process = Get-CimInstance Win32_Process | where {($_.Name -like "cmd.exe" -or $_.Name -like "mshta.exe") -and ($_.CommandLine -like "*http://*" -or $_.CommandLine -like "*https://*")} 
$ProcessCount = $Process | Measure-Object | Select-Object Count

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
#Only detects dnd displays the malicious tasks and services
function Detect {
    "==========================="
    "Listing Bad Services"
    "==========================="
    Write-Host $servcount.Count "services detected."
    $serv |  select Name, DisplayName, State, PathName
    if ($null -eq $serv) {"No services match the set criteria."}

    "==========================="
    "Listing Bad Tasks"
    "==========================="
    $schtasks |  Format-list 
    Write-Host $schtasks.Count "task(s) detected."
    if ($null -eq $serv) {"No Tasks  match the set criteria."}

    "==========================="
    "Listing Active Processes"
    "==========================="
    $Process | select Name, CommandLine
}

#Attempts to delete the malicious tasks and services which are found by Detect
function RemoveTor2Mine {

param ([switch]$Force)

if ($schtasks.Count -gt 0 -or $servcount.Count -gt 0 -or $ProcessCount.Count -gt 0) {

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
    }
  }
}

Detect

if ($ForceEnabled) { RemoveTor2Mine -Force }
else { RemoveTor2Mine }

Stop-Transcript