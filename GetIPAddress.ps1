Function Get-OSCRDPIPaddress
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$false,Position=0)]
		[String]$ComputerName=$Env:COMPUTERNAME,
		[Parameter(Mandatory=$false,Position=1)]
		[System.Management.Automation.PsCredential]$Credential,
		[Parameter(Mandatory=$false,Position=2)]
		[Datetime]$Before,
		[Parameter(Mandatory=$false,Position=3)]
		[Datetime]$After
	)
	Try
	{
		$result = @()
		If($Credential)
		{
			$LogOnEvents = Get-WinEvent -ComputerName $ComputerName -Credential $Credential -filterHashtable @{LogName='Security'; Id=4624; Level=0}  |  Where-Object{ $_.Properties[8].Value -eq 10}
		}
		Else
		{
			$LogOnEvents = Get-WinEvent -filterHashtable @{LogName='Security'; Id=4624; Level=0}  |  Where-Object{ $_.Properties[8].Value -eq 10}
		}
		If($LogOnEvents)
		{
			Foreach($Event in $LogOnEvents )
			{
				$UserName = $Event.Properties[5].value 
				$Ip = $Event.Properties[18].value
				$logObj =  New-Object PSobject -Property @{ComputerName = $ComputerName;Time = $Event.TimeCreated; UserName = $UserName ;ClientIPAddress = $Ip  }  
				$result = $result + $logObj 
			}
			if($Before -and $After)
			{
				$result | Where-Object { ($_.Time -le $Before) -and ($_.Time -ge $After) }
			}
			Else 
			{
				If($Before)
				{
					$result | Where-Object {$_.Time -le $Before}
				}
				Elseif($After)
				{
					$result | Where-Object {$_.Time -ge $After}
				}
				Else
				{
					$result
				}
			}
			
		}
	}
	Catch 
	{
		Write-Error $_
	}

}

Get-OSCRDPIPaddress 

Get-OSCRDPIPaddress | Export-Csv RDP_Connection_Log.csv -NoTypeInformation -Encoding UTF8
