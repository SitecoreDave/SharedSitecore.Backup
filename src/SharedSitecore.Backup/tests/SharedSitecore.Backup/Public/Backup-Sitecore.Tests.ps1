$ModuleScriptFolder = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
. $ModuleScriptFolder\tests\TestRunner.ps1 {
    $ModuleScriptFolder = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
    . $ModuleScriptFolder\tests\TestUtils.ps1 
        Describe 'Backup-Sitecore.Tests' {
            $ModuleScriptFolder = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
            #$ModuleScriptFolder = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
            $ModuleScriptName = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Leaf
            Write-Verbose "ModuleScriptName:$ModuleScriptName"
            #$ModuleScriptName = $PSScriptRoot | Split-Path -Parent -Parent -Leaf
            $ModuleScriptPath = Join-Path $ModuleScriptFolder "$ModuleScriptName.psm1"
            Write-Output "ModuleScriptPath:$ModuleScriptPath"
            It 'imports successfully' {
                $ModuleScriptFolder = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
                $ModuleName = Split-Path $ModuleScriptFolder -Leaf
                $ModuleScriptPath = "$ModuleScriptFolder\$ModuleName.psm1"
                { Import-Module -Name $ModuleScriptPath -ErrorAction Stop } | Should -Not -Throw
            }
            #TODO: TEST FOR BAD PARAMS
            #TODO: MOCK IT - https://www.red-gate.com/simple-talk/sysadmin/powershell/advanced-testing-of-your-powershell-code-with-pester/
            It 'Should create backup folder' {
                $results = Backup-Sitecore
                #$results | Should -BeLike "Backup-Sitecore created:*"

                $ModuleScriptFolder = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

                $sourceDefault = Join-Path $ModuleScriptFolder "assets\sc93sc.dev.local"

                $dateFormat = Get-Date -Format "yyyy-MM-dd"
                $backup = "$sourceDefault.backup.$dateFormat"
                Test-Path $backup | Should -BeTrue                
            }
            It 'Should Backup compress' {
                $results = Backup-Sitecore -Compress
                #$results | Should -BeLike "Backup-Sitecore created:*"
                Test-Path (Join-Path . "sc93sc.dev.local.backup.yymmddhh.zip") | Should -BeTrue
            }          
    }
}