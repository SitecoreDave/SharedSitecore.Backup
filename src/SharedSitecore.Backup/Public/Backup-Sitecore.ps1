Set-StrictMode -Version Latest
#####################################################
#  Backup-Sitecore
#####################################################
<#
.SYNOPSIS
    PowerShell module to backup Sitecore site
.DESCRIPTION
    PowerShell module to backup Sitecore site
.PARAMETER Source
    Specifies the source path - checks current folder if null
.PARAMETER Destination
    Specifies the destination path - uses source.backups.yyyyMMdd if null
.PARAMETER Exclude
    Specifies the paths to exclude
.PARAMETER Compress
    Swith Compression on and off
.EXAMPLE
    PS C:\> Backup-Sitecore -Source /source -Destination "/backups"
.EXAMPLE
    PS C:\> "/backups" | Backup-Sitecore "/source"
.EXAMPLE
    PS C:\> Backup-Sitecore -Source /source -Destination "/backups" -Exclude ('App_Data')
.INPUTS
    System.String. You can pipe in the Source parameter.
.OUTPUTS
    None.
#>
function Backup-Sitecore
{
	[CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Position=0)]
		[alias("src")]
        [string]$source = "",

		[Parameter(Position=1)]
		[alias("dest")]
        [string]$destination = "",
		
		[Parameter(Position=2)]
        [string[]]$exclude = (""),

		[Parameter(Position=3)]
		[switch] $compress
    )
    begin {
		$ErrorActionPreference = 'Stop'
		$VerbosePreference = "Continue"
		$scriptName = ($MyInvocation.MyCommand.Name.Replace(".ps1",""))

		if (!$source) {
			$source = $pwd
		}

		if (!$destination) {
			$dateFormat = Get-Date -Format "yyyy-MM-dd"
			$backup = "$source.backup.$dateFormat"
			if (Test-Path $backup) {
				$dateFormat = Get-Date -Format "yyyy-MM-dd-hh-mm"
				$backup = "$source.backup.$dateFormat"
			}
			$destination = $backup
		}

		if ($exclude) {
			for ($i = 0; $i -lt $exclude.count; $i++) {
				if (!$exclude[$i].StartsWith($source)) {
					$exclude[$i] = "$source\" + $exclude[$i]
					if (!$exclude[$i].EndsWith("*")) {
						$exclude[$i] += "*"
					}
				}
			}
		}

		Write-Verbose "$scriptName $source $destination $exclude"
	}
	process {
		try {
			if ($PSCmdlet.ShouldProcess($source)) {
				if (!$source.StartsWith("http")) {
					#$items = Get-ChildItem -Path "$source" -Exclude $exclude -Recurse -Force
					$items = Get-ChildItem $source -Recurse | Where-Object{$_.FullName -notlike $exclude -and $_.PSIsContainer -eq $false}
				} else {
					#todo: kudu
					#destionat = default .\backups\resourcegroup\date\xxxx
					#download\zip:\home\site\wwwroot to year-mm-dd-hh-mm-resourcegroup-instance-wwwroot.zip
					#instances: authoring, bizfx, minions ,ops, shops
					#may need to do something different/custom here since they're around 250mb. just get vitals?
					#cd, cm
				}

				if ($items) {
					if (!$compress) {
						#$items | Copy-Item -Destination Join-Path {$destination $_.FullName.Substring($source.length)}
						
						#$itemOutput = New-Object PSObject
						#$itemOutput | Add-Member -Type NoteProperty -Name Source -Value $item.FullName
						#$itemOutput | Add-Member -Type NotePropery -Name Destination -Value $destination
						#$items | Format-List

						foreach ($item in $items) {
							Write-Output $item.FullName
							#Copy-Item -Path $item.FullName -Destination "$destination\$($item.FullName.Substring($source.length))"
						}

					} else {
						$destination = "$destination.zip"
						Compress-Archive -Path $items -DestinationPath $destination -CompressionLevel Fastest
					}
					Write-Output "Backup-Sitecore created: $destination"					
				}
			}
        
		}
        finally {
            #Pop-Location
        }
    }
	
}