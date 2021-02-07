#set-alias x exit
#set-alias p powershell

$ModuleName = "SharedSitecore.Backup"
Import-Module .\$ModuleName\src\$ModuleName\$ModuleName.psm1 -verbose
#Push-Location $ModuleName
#Invoke-Pester #Invoke-Tests someday
#Build-SitecoreDocker

#Pop-Location

#$exclude = @('*.pdb','*.config')
#$exclude = @('App_Data','temp')
#$exclude = @('logs','temp', 'debug','DeviceDetection','diagnostics','MediaCache','packages')
$exclude = @('App_Data', 'temp')
$src = "c:\inetpub\wwwroot\sc93sc.dev.local"
#remove-item "$src.*"
Backup-Sitecore $src -Exclude $exclude
Exit 0


#$ScriptName = "Get-ModuleBase"
#$results = .\$ScriptName\$ScriptName.ps1
#$results = .\Get-ModuleBase\Get-ModuleBase.ps1
#Write-Verbose "results:$results"
#Write-Verbose "pwd:$pwd"
#Push-Location $ScriptName
#Write-Verbose "pwd:$pwd"
#Invoke-Pester #Invoke-Tests someday
#Pop-Location
#Exit 0

$ModuleName = "SharedSitecore.SitecoreDocker"
Import-Module .\$ModuleName\src\$ModuleName\$ModuleName.psm1 -verbose
Push-Location $ModuleName
#Invoke-Pester #Invoke-Tests someday
Build-SitecoreDocker
Pop-Location

#Import-Module .\PesterInvoker\src\PesterInvoker.psm1 -verbose
#Invoke-Tests PesterInvoker