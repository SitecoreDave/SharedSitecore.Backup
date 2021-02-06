Clear-Host
#$filePath = "C:\code\Caleres\Sitecore_Commerce\Scripts\Arm-Templates\paas\ecom-uat.local.azuredeploy.parameters.json"
#$fileParameters = Get-Content $filePath | ConvertFrom-Json 


$secret = "ecom-dev-pr-sxc-cm-kudu-apikey"
$secret = "ecom-uat-sxc-cm-kudu-apikey"
$secretValue = (Get-AzureKeyVaultSecret -vaultName "ecom-vault" -Name "ecom-dev-pr-sxc-cm-kudu-apikey").secretValue
Write-Output "$($secret):  $($secretValue.SecretValueText) "

$vaultUrl = "https://ecom-vault.vault.azure.net/"
 
$url = "{vaultBaseUrl}/secrets/$secret/4387e9f3d6e14c459867679a90fd0f79?api-version=7.0"
#Invoke-Rest "{vaultBaseUrl}/secrets/$secret/4387e9f3d6e14c459867679a90fd0f79?api-version=7.0"


Invoke-RestMethod -Uri $url -Method GET -ContentType "content/json"

https://login.microsoftonline.com/{{directoryId}}/oauth2/v2.0/token

