#v1.0 









$TacticalLicense= 'RR-5956-1715-1877-1688'
#Enter your License within the quotes. For e.g. $TacticalLicense = 'XX-1234-5678-9012-3456'

function List
{

$Art=@('

██████╗░░█████╗░░██╗░░░░░░░██╗███████╗██████╗░██████╗░░█████╗░██████╗░░██████╗███████╗
██╔══██╗██╔══██╗░██║░░██╗░░██║██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝
██████╔╝██║░░██║░╚██╗████╗██╔╝█████╗░░██████╔╝██████╔╝███████║██████╔╝╚█████╗░█████╗░░
██╔═══╝░██║░░██║░░████╔═████║░██╔══╝░░██╔══██╗██╔═══╝░██╔══██║██╔══██╗░╚═══██╗██╔══╝░░
██║░░░░░╚█████╔╝░░╚██╔╝░╚██╔╝░███████╗██║░░██║██║░░░░░██║░░██║██║░░██║██████╔╝███████╗
╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░░╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚══════╝

v1.0 @vikas891')

$Art
""
Write-Host "!! Use the List Command !!" -ForegroundColor Yellow
""
"============================="
"Following Modules are Loaded:"
"============================="
"0. 1Setup_Check"
"1. 1Tactical_Decrypt"
"2. 1CDQR_Reports"
"3. 1SuperTimeline"
"4. 1AmCache"
"5. 1ShimCache"
"6. 1Prefetch"
"7. 1MFT_UsnJnrl" 
"8. 1Chainsaw" 
"9. Exit"
#Write-Host "9. 1All-In-One" -ForegroundColor black -BackgroundColor White
""
Write-Host "Remember! Current Working Directory should be C Drive of Triage Image" -foregroundcolor red
" "
$option = Read-Host "Enter Option"
switch($option)
    {
        0 {1Setup_Check}
        1 {1Tactical_Decrypt}
        2 {1CDQR_Reports}
        3 {1SuperTimeline}
        4 {1AmCache}
        5 {1ShimCache}
        6 {1Prefetch}
        7 {1MFT_UsnJnrl}
        8 {1Chainsaw}
        9 {"";break}
    }
}

function SetMyToolsValue
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select your Tools Directory"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory
    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath         
    }
    else
    {
        ""
        Write-Host "[!] Cancelled by User. Exiting." -foregroundcolor red
        ""
        break
    }
    $AddCheck = Start-Process powershell.exe -verb runAs -ArgumentList '-Command', "cd $SafeStoreTools; `"[System.Environment]::SetEnvironmentVariable('MyTools','$folder',[System.EnvironmentVariableTarget]::Machine)`";" -PassThru -Wait
    if($AddCheck.ExitCode -eq 0)
    {
        $env:MyTools = [System.Environment]::GetEnvironmentVariable('MyTools','Machine')
        ""
        Write-Host -NoNewline "[+] Addition Successful. Value of MyTools=" -foregroundcolor green
        Write-Host -NoNewline $env:MyTools -ForegroundColor Yellow
        ""
    }
}

function 1Setup_Check
{
    if($env:MyTools)
    {
     ""
     Write-Host "[+] Value of MyTools = $env:MyTools OK." -foregroundcolor green
     ""
     $Change =  Read-Host "Do you wish to change the DIR?[y/n]"
     if($Change -eq 'y')
     {
     SetMyToolsValue
     }
    }
    else {
    ""
    Write-Host "[+] Value of Environment Variable MyTools is empty." -foregroundcolor red
    ""
    Write-Host "Do you want to specify your Tools DIR and add the environment variable called " -NoNewline
    Write-Host "MyTools" -ForegroundColor Yellow -NoNewline
    Write-Host "?[y/n]" -NoNewline
    $Set = Read-Host
    if($Set -eq 'y')
    {
        SetMyToolsValue
    }
    else
    {
        ""
        Write-Host "Please run the check again once MyTools environment variable points to your tools directory." -foregroundcolor red
        ""
        break
     }
    }
    $ListOfFiles = @('AmCacheParser.exe', 'AppCompatCacheParser.exe','Tactical\TACTICAL-2.7.4.exe','cdqr.exe','chainsaw\chainsaw.exe','MFTECmd.exe','cdqr.exe','plaso\log2timeline.exe','chainsaw\chainsaw.exe')
    $Tools = $env:MyTools
    ""
    foreach ($file in $ListOfFiles)
    {
    if(Test-Path -Path $env:MyTools\$file  -PathType leaf)
        {
         Write-Host "[+] $env:MyTools\$file OK." -foregroundcolor green
        }
        else{Write-Host "[!] $env:MyTools\$file Not Found." -foregroundcolor red}
    }    
    try {

        Start-Process bash -ArgumentList "-c dir &exit" -NoNewWindow
        Write-Host "[+] WSL looks to be OK." -foregroundcolor green
        ""
    }
    catch {Write-Host "[!] Unable to start bash. Ensure WSL is installed correctly." -foregroundcolor red;""}
    Write-Host "Checking presence of non-empty PS Profile Script" -ForegroundColor Yellow
    sleep -s 2
    ""
    if (Test-Path $profile.CurrentUserAllHosts)
    {
    Write-Host -NoNewline "A non-empty Profile script was found: "
    Write-Host -NoNewline $profile.CurrentUserAllHosts -foregroundcolor Green
    ""
    ""
    }
    else {Write-Host "[!] PowerShell Profile Script Not Found. Please run Install.ps1 again." -foregroundcolor red}
    Write-Host "[!] Ensure all Errors are rectified. Once all Green, use the 'List' Command directly." -ForegroundColor Yellow
    ""
    sleep -s 2
}

function 1Tactical_Decrypt
{
    param ($EPPCFile)
    $Path = (gci $EPPCFile)   
    $FileName = $Path.FullName
    $DIR = $Path.DirectoryName
    if(!$EPPCFile)
    {
       ""
        "This option requires an argument with the EPPC file. For e.g.:"
        Write-Host -NoNewline "PS C:\Cases\01 Dummy Corporation\TACTICAL Logs>" -foregroundcolor red
        Write-Host -NoNewline "1Tactical_Decrypt .\20211017180357-TRASHPANDA.eppc" -foregroundcolor yellow
        ""
        ""
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        #$OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter = "EPPC Files (*.eppc)|*.eppc"
        $Result = $OpenFileDialog.ShowDialog() 
        if($Result -ne "OK")
        {Write-Host "Cancelled by User.. Exiting.." -ForegroundColor Red ;"";break}
        $Path = (gci $OpenFileDialog.FileName)
    }
    if (Test-Path "$env:MyTools\TACTICAL.EXE" -PathType leaf)
    {
        $Process = Start-Process -FilePath "$env:MyTools\TACTICAL.exe" -ArgumentList "--decrypt --license $TacticalLicense --case-path `"$($path.Fullname)`" --output-dir `"$($path.DirectoryName)`" --no-wait" -PassThru -Wait
        if($Process.ExitCode -eq 0)
        {
            ""
            Write-Host "Decrypting Completed!"
            ""
        }
    }
    else {"TACTICAL.exe not found in $env:MyTools"}
}

function 1CDQR_Reports
{
    $loc = Get-Location 
    "Please make sure your current working directory is C: folder of extracted Triage Image."
    "For e.g." 
    Write-Host "PS C:\LogFiles\CEO-LAPTOP\C>" -ForegroundColor Red -NoNewline
    Write-Host "1CDQR_Reports"-ForegroundColor Yellow -NoNewline
    ""
    $Confirm = Read-Host "Do you want to continue?[y/n]"
    if ($Confirm -eq 'y') 
            { 
               if (Test-Path "$env:MyTools\cdqr.exe" -PathType leaf) {
                cd $env:MyTools
                $CDQRProcess = Start-Process -FilePath "$env:MyTools\cdqr.exe" -ArgumentList "--max_cpu $loc $loc\02_CDQR_Results" -PassThru -NoNewWindow -Wait
                }
                else {"cdqr.exe not found in $env:MyTools";break}
            }
    else {"Please switch to the correct DIR and try again."}
}

function 1SuperTimeline
{
    <#
    Usage 
    Make sure your current working direcory is the C drive folder of Triage Image i.e. \TACTICAL Logs\Machine_Name\C
    #>
    try{
        if(!(Test-Path -Path ./02_SuperTimeline))
        { New-Item 02_SuperTimeline -ItemType Directory }
        "Creating the Plaso Dump.."
        Start-Process bash -ArgumentList "-c `"log2timeline.py -z UTC --status_view window --parsers 'win7' --storage-file ./02_SuperTimeline/plaso.dump ./`"" -Wait -NoNewWindow
        "Cleaning up.."
        Remove-Item .\*.log.gz
        "Creating the TimeLine CSV.."
        Start-Process bash -ArgumentList "-c `"psort.py --output_time_zone `"UTC`" -o L2tcsv ./02_SuperTimeline/plaso.dump -w ./02_SuperTimeline/plaso.csv`"" -Wait -NoNewWindow
        }
    catch {"Please ensure WSL and plaso-tools are properly installed. Run > bash followed by log2timeline.py --version to confirm."}
}

function 1Amcache
{
    if (Test-Path "$env:MyTools\AmcacheParser.exe" -PathType leaf) {
    Start-Process -FilePath "$env:MyTools\AmcacheParser.exe" -ArgumentList "-f .\Windows\appcompat\Programs\Amcache.hve --csv ./02_AmcacheReports --dt `"yyyy-MM-ddTHH:mm:ss`"" -Wait -NoNewWindow
    }
    else {"AmcacheParser.exe not found in $env:MyTools"}
}

function 1ShimCache
{
    if (Test-Path "$env:MyTools\AppCompatCacheParser.exe" -PathType leaf) {
        Start-Process -FilePath "$env:MyTools\AppCompatCacheParser.exe" -ArgumentList "-f .\Windows\system32\config\SYSTEM --csv ./03_ShimCacheReport --dt `"yyyy-MM-ddTHH:mm:ss`"" -Wait -NoNewWindow
    }
    else {"AppCompatCacheParser.exe not found in $env:MyTools"}
}

function 1Prefetch
{
    if (Test-Path "$env:MyTools\PECmd.exe" -PathType leaf) {
        Start-Process -FilePath "$env:MyTools\PECmd.exe" -ArgumentList "-d .\Windows\system32\Prefetch --csv ./04_PrefetchReport --dt `"yyyy-MM-ddTHH:mm:ss`"" -Wait -NoNewWindow
    }
    else {"PECmd.exe not found in $env:MyTools"}
}

function 1MFT_UsnJnrl
{ 
    $MFTOutputfile = ".\01_MFT_UsnJrnl\MFTECmd_`$MFT_Output.csv"
    $JOutputfile = ".\01_MFT_UsnJrnl\MFTECmd_`$J_Output.csv"
    $MFTFile = ".\`$MFT"
    $JFile = ".\`$Extend\`$UsnJrnl`$J"

    function ParseMFT()
    {
        "Parsing `$MFT into a CSV..."
        $Return = Start-Process -FilePath "$env:MyTools\MFTECmd.exe" -ArgumentList "-f .\`$MFT --csv ./01_MFT_UsnJrnl/ --csvf MFTECmd_`$MFT_Output.csv --dt `"yyyy-MM-ddTHH:mm:ss`"" -NoNewWindow -Wait -PassThru
        # "Code:" + $Return.ExitCode
    }

    function ParseUsnJrnl()
    {   
        "Parsing `$UsnJrnl into a CSV..."
        Start-Process -FilePath "$env:MyTools\MFTECmd.exe" -ArgumentList "-f .\`$Extend\`$UsnJrnl`$J  --csv ./01_MFT_UsnJrnl/ --csvf MFTECmd_`$J_Output.csv --dt `"yyyy-MM-ddTHH:mm:ss`"" -NoNewWindow -Wait
    } 
    if(Test-Path -Path $MFTfile -PathType Leaf)
    {
        if (Test-Path -Path $MFTOutputfile -PathType Leaf)
        {
            $Confirm = Read-Host "MFTECmd_`$MFT_Output.csv already exists. Do you wish to re-parse the `$MFT file?[y/n]"
    
            if ($Confirm -eq 'y') 
            { 
               "Re-parse initiated.."
               ParseMft
            }
        }
        else
        {
            "No existing Output found. Parsing `$MFT into a CSV..."
             ParseMFT
        }
    }
    else
    {
        "`$MFT Not found in the current working DIR. Exiting.."
    }

#Check for $UsnJrnl File and Parse
  
    if(Test-Path -Path $JFile -PathType Leaf)
    {
        
    if (Test-Path -Path $JOutPutFile -PathType Leaf)
        {
            $Confirm = Read-Host "MFTECmd_`$J_Output.csv already exists. Do you wish to re-parse the `$J file?[y/n]"
            if ($Confirm -eq 'y') 
            {
               "Re-parse initiated.."
               ParseUsnJrnl
            }
        }

    else
    {
        ParseUsnJrnl
    }

    }

    else
    {
        "`$J Not found. Exiting.."
    }
    
}

function 1Chainsaw
{
    Param ($Search, [switch]$Hunt, [switch]$Lateral)
    
    if (Test-Path "$env:MyTools\chainsaw\chainsaw.exe" -PathType leaf) {

        if ($Hunt)
        {
            Start-Process -FilePath "$env:MyTools\chainsaw\chainsaw.exe" -ArgumentList "hunt .\Windows\system32\winevt\Logs --rules $env:MyTools\chainsaw\sigma_rules\ --mapping $env:MyTools\chainsaw\mapping_files\sigma-mapping.yml --csv .\08_Chainsaw\ " -NoNewWindow -Wait
            break
        }
    
        if($Lateral){
    
            Start-Process -FilePath "$env:MyTools\chainsaw\chainsaw.exe" -ArgumentList "hunt .\Windows\system32\winevt\Logs --lateral-all --csv .\08_Chainsaw\" -NoNewWindow -Wait
            break
        }

        if (-not ([string]::IsNullOrEmpty($Search)))
        {
            Start-Process -FilePath "powershell" -ArgumentList "chainsaw.exe search .\Windows\system32\winevt\Logs -s $Search ; pause"
            break
        }
        else
        {
        ""
        "Use one of these parameters: -hunt -lateral or -search"
        ""
        }
    }
    else {"chainsaw.exe not found in $env:MyTools\chainsaw"}
}

function All-In-One {

#For future Use

}