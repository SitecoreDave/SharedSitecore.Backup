$repoPath = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
. $repoPath\tests\TestRunner.ps1 {
    $repoPath = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
    . $repoPath\tests\TestUtils.ps1
    $ModuleName = Split-Path $repoPath -Leaf
    $ModuleScriptName = 'SharedSitecore.Backup.psm1'
    $ModuleManifestName = 'SharedSitecore.Backup.psd1'
    $ModuleScriptPath = "$repoPath\src\$ModuleName\$ModuleScriptName"
    $ModuleManifestPath = "$repoPath\src\$\ModuleName\$ModuleManifestName"

    if (!(Get-Module PSScriptAnalyzer -ErrorAction SilentlyContinue)) {
        Install-Module -Name PSScriptAnalyzer -Repository PSGallery -Force
    }

    Describe 'Module Tests' {
        $repoPath = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
        $ModuleName = Split-Path $repoPath -Leaf
        $ModuleScriptName = "$ModuleName.psm1"
        #$ModuleManifestName = 'SharedSitecore.Backup.psd1'
        $ModuleScriptPath = "$repoPath\src\$ModuleName\$ModuleScriptName"
        #$ModuleManifestPath = "$PSScriptRoot\..\..\src\$ModuleManifestName"

        It 'imports successfully' {
            $ModuleScriptFolder = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
            $ModuleName = Split-Path $ModuleScriptFolder -Leaf
            $ModuleScriptPath = "$ModuleScriptFolder\$ModuleName.psm1"
            { Import-Module -Name $ModuleScriptPath -ErrorAction Stop } | Should -Not -Throw
        }

        It 'passes default PSScriptAnalyzer rules' {
            $ModuleScriptFolder = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
            $ModuleName = Split-Path $ModuleScriptFolder -Leaf
            $ModuleScriptPath = "$ModuleScriptFolder\$ModuleName.psm1"
            Invoke-ScriptAnalyzer -Path $ModuleScriptPath | Should -BeNullOrEmpty
        }
    }

    Describe 'Module Manifest Tests' {
        It 'passes Test-ModuleManifest' {
            $ModuleScriptFolder = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
            $ModuleName = Split-Path $ModuleScriptFolder -Leaf
            $ModuleManifestName = "$ModuleName.psd1"
            $ModuleManifestPath = "$ModuleScriptFolder\$ModuleManifestName"

            Write-Output $ModuleManifestPath
            Test-ModuleManifest -Path $ModuleManifestPath | Should -Not -BeNullOrEmpty
            $? | Should -Be $true
        }
    }
}