Set-StrictMode -Version Latest
#####################################################
#  New-SitecoreBackup
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
    PS C:\> New-SitecoreBackup -Source /source -Destination "/backups"
.EXAMPLE
    PS C:\> "/backups" | New-SitecoreBackup "/source"
.EXAMPLE
    PS C:\> New-SitecoreBackup -Source /source -Destination "/backups" -Exclude ('App_Data')
.INPUTS
    System.String. You can pipe in the Source parameter.
.OUTPUTS
    None.
#>
function New-SitecoreBackup
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
			$dateFormat = Get-Date -Format "yyyyMMdd"
			$backup = "$source.backup.$dateFormat"
			if (Test-Path $backup) {
				$dateFormat = Get-Date -Format "yyyyMMdd.hhmm"
				$backup = "$source.backup.$dateFormat"
			}
			$destination = $backup
		}

		Write-Verbose "$scriptName $source $destination $exclude"
	}
	process {
		try {
			if ($PSCmdlet.ShouldProcess($source)) {
				if (!$source.StartsWith("http")) {
					$items = Get-ChildItem -Path "$source" -Exclude $exclude -Recurse -Force
				} else {
					#todo:
					#kudu
					#destionat = default .\backups\resourcegroup\date\xxxx
					#download\zip:\home\site\wwwroot to year-mm-dd-hh-mm-resourcegroup-instance-wwwroot.zip

					#authoring
					#bizfx
					#minions
					#ops
					#shops

					#may need to do something different/custom here since they're around 250mb. just get vitals?
					#cd
					#cm
				}

				if ($items) {
					if (!$compress) {

						Copy-Item -Destination Join-Path $destination $_.FullName.Substring($source.length)

					} else {
						Compress-Archive -Path $items -DestinationPath $destination -CompressionLevel Fastest
					}
				}
			}
        }
        finally {
            #Pop-Location
        }
    }
}