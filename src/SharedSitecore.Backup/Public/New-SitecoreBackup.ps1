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
        [string[]]$exclude = ("")
    )
    begin {
		$ErrorActionPreference = 'Stop'

		#Clear-Host
		$VerbosePreference = "Continue"

		$scriptName = ($MyInvocation.MyCommand.Name.Replace(".ps1",""))
		$scriptPath = $PSScriptRoot #$MyInvocation.MyCommand.Path
		$scriptFolder = Split-Path $scriptPath
		
		$reposPath = Split-Path (Split-Path (Split-Path $scriptPath -Parent) -Parent) -Parent
		Write-Verbose "reposPath:$reposPath"

		if (!$destination) {
			$dateFormat = Get-Date -Format "yyyyMMdd"
			$backup = "$destination.backup.$dateFormat"
			if (Test-Path $backup) {
				$dateFormat = Get-Date -Format "yyyyMMddmm"
				$backup = "$destination.backup.$dateFormat"
			}
			$destination = $backup
		}

		Write-Verbose "$scriptName $source $destination"
	}
	process {
		try {
			if($PSCmdlet.ShouldProcess($config)) {
				Copy-Item -Path (Get-Item -Path "$source\*" -Exclude $exclude.FullName -Destination $destination -Recurse -Force

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
        }
        finally {
            #Pop-Location
        }
    }
}