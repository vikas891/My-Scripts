#Download and extracts a fresh copy of CyLR to C:\Windows\Temp\Sophos_Cylr_[Timestamp]
#We could check for C:\CyLR.exe and execute it directly but it's easier and safer to execute a fresh copy. 
#Outputs a C:\Windows\Temp\Sophos_[Timestamp].[Hostname].zip which can be pulled using SDU Downloader. 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$Timestamp = (Get-Date -Format "yyyyMMddTHHmmss")
$outpath = New-Item -Path "C:\windows\Temp\" -Name "Sophos_Cylr_$Timestamp" -ItemType "directory"
(New-Object System.Net.WebClient).DownloadFile("https://github.com/orlikoski/CyLR/releases/download/2.2.0/CyLR_win-x64.zip", "$outpath\CyLR_win-x64.zip")
if($PSVersionTable.PSVersion.Major -gt 4)
{
    Expand-Archive -LiteralPath "$outpath\CyLR_win-x64.zip" -DestinationPath $outpath
}
else
{
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$outpath\CyLR_win-x64.zip", $outpath)
}
Start-Process -Filepath "$outpath\CyLR.exe" -ArgumentList "--usnjrnl -q -od C:\Windows\Temp -of Sophos_$TimeStamp.$env:computername.zip" -NoNewWindow -Wait
