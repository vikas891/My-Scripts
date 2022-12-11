param(
    [Parameter(Mandatory=$true)]        
    [ValidateScript({
        if( -Not ($_ | Test-Path) ){
            throw "The specified Folder does not exist."
        }
        return $true
    })]
    [System.IO.FileInfo]$Path
    )
$ListOfTasks = (Get-ChildItem -File -Path $Path -Recurse).fullname
$ListOfTasks | foreach {
$ModifiedTime = (gci -Path $_).LastWriteTimeUtc.toString('yyyy-MM-ddTHH:mm:ss')+':00z'
$xmlFile = [xml](get-content "$_")
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
} 2> $NULL | Export-Csv -Path .\$(((get-date).ToUniversalTime()).ToString("yyyyMMddTHHmmssZ"))_ParsedScheduledTasks_XML.csv -NoTypeInformation
