<#
.SYNOPSIS
    Extracts and exports information from XML files representing scheduled tasks.

.DESCRIPTION
    This script processes XML files located in the specified directory, extracts
    details about scheduled tasks, and exports the information into a CSV file.
    It retrieves details such as task registration date, author, description, 
    task name, user context, logon type, status (enabled/disabled), action arguments,
    COM handler class ID, and COM handler data.

.PARAMETER Path
    Specifies the directory path containing the XML files for scheduled tasks. 
    The parameter is mandatory and the script will validate that the specified 
    folder exists.

.PARAMETER Output
    Specifies the directory where the CSV file will be saved. If not provided,
    the CSV file will be saved in the current directory. This parameter is optional.

.EXAMPLE
    .\ParseScheduledTasks.ps1 -Path "C:\ScheduledTasks" -Output "C:\CustomOutputDir"
    This example processes all XML files in the specified directory and exports 
    the extracted task details to a timestamped CSV file in the specified output directory.

.EXAMPLE
    .\ParseScheduledTasks.ps1 -Path "C:\ScheduledTasks"
    This example processes all XML files in the specified directory and exports 
    the extracted task details to a timestamped CSV file in the current directory.

.NOTES
    Author: Vikas Singh (@vikas891) 

.LINK
    KAPE Module: PowerShell_ParseScheduledTasks in Windows\LiveResponse
    More details about the KAPE module can be found at: https://github.com/EricZimmerman/KapeFiles/blob/master/Modules/Windows/PowerShell_ParseScheduledTasks.mkape
    Blog: https://vikas-singh.notion.site/Parse-Scheduled-Tasks-XMLs-36ec152e7d2a4d269bba6c9565c3b5cd
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({
        if (-Not ($_ | Test-Path)) {
            throw "The specified folder does not exist."
        }
        return $true
    })]
    [System.IO.FileInfo]$Path,

    [Parameter(Mandatory = $false)]
    [ValidateScript({
        if (-Not (Test-Path -Path $_ -PathType Container)) {
            throw "The specified output directory does not exist."
        }
        return $true
    })]
    [string]$Output
)

# Retrieve only XML files from the specified path
$ListOfTasks = (Get-ChildItem -File -Path $Path -Recurse).FullName

if ($ListOfTasks.Count -eq 0) {
    # No XML files found
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "No XML files or scheduled tasks were detected in the specified directory." -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
} else {
    # Generate CSV file path
    $CsvFilePath = if ($Output) { 
        Join-Path -Path (Resolve-Path $Output) -ChildPath "$(((Get-Date).ToUniversalTime()).ToString('yyyyMMddTHHmmssZ'))_ParsedScheduledTasks_XML.csv" 
    } else { 
        Join-Path -Path (Resolve-Path .) -ChildPath "$(((Get-Date).ToUniversalTime()).ToString('yyyyMMddTHHmmssZ'))_ParsedScheduledTasks_XML.csv"
    }

    $ListOfTasks | ForEach-Object {
        $ModifiedTime = (Get-ChildItem -Path $_).LastWriteTimeUtc.ToString('yyyy-MM-ddTHH:mm:ss') + ':00z'
        $xmlFile = [xml](Get-Content "$_")
        $Date = $xmlFile.ChildNodes.RegistrationInfo.Date
        $Author = $xmlFile.ChildNodes.RegistrationInfo.Author
        $Description = $xmlFile.ChildNodes.RegistrationInfo.Description
        $URI = $xmlFile.ChildNodes.RegistrationInfo.URI
        $Principals = $xmlFile.ChildNodes.Principals.Principal.UserId
        $LogonType = $xmlFile.ChildNodes.Principals.Principal.LogonType
        $Enabled = $xmlFile.ChildNodes.Settings.Enabled
        $Action = $xmlFile.ChildNodes.Actions.Exec.Command
        $Arguments = $xmlFile.ChildNodes.Actions.Exec.Arguments
        $ComHandler_ClassID = $xmlFile.ChildNodes.Actions.ComHandler.ClassId
        $ComHandler_Data = [string]$xmlFile.ChildNodes.Actions.ComHandler.Data.'#cdata-section'
        $xmlFile.ChildNodes[1] |
        ForEach-Object {
            [PSCustomObject]@{
                TaskFile_LastModifiedTime = $ModifiedTime
                Registration_Date = $Date
                Author = $Author
                Description = $Description
                Task_Name = $URI
                Principals_UserContext = $Principals
                LogonType = $LogonType
                Enabled = $Enabled
                Action_Arguments = $Action + ' ' + $Arguments
                ComHandler_ClassID = $ComHandler_ClassID
                ComHandler_Data = $ComHandler_Data
            }
        }
    } 2> $NULL | Export-Csv -Path $CsvFilePath -NoTypeInformation

    # Output message indicating the CSV file location
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "The parsed scheduled tasks have been successfully exported to the following CSV file:" -ForegroundColor Cyan
    Write-Host $CsvFilePath -ForegroundColor Yellow
    Write-Host "You can review the detailed task information, including registration dates, authors, and actions, in this file." -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
}
