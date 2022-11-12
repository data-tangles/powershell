######################

# This script will allow you to check open file handles for files within an Azure File Share. I most often use this for checking open file handles for FSLogix profile disks for Citrix or Aazure Virtual Desktop

######################

# Check if Az Modules are installed

$azmodule = Get-Module -Name Az

if ($azmodule) {
    Write-Host "Az Module is installed"
} else {
    Write-Host "Installing Az Module"
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
}

# Connect to Azure

Connect-AzAccount

$ResourceGroup = Get-AzResourceGroup | Out-GridView -OutputMode Single -Title "Choose Resource Group"
Write-Host "Setting Resource Group to $ResourceGroupName" -ForegroundColor Green

$StorageAccountName = Get-AzStorageAccount | Out-GridView OutputMode Single -Title "Choose Storage Account"
Write-Host "Setting Storage Account to $StorageAccountName.Name" -ForegroundColor Green

Set-AzCurrentStorageAccount -ResourceGroupName $ResourceGroup -AccountName $StorageAccountName

$ShareName = Get-AzStorageShare | Out-GridView -Title "Choose Share"
Write-Host "Setting Share Name to $ShareName" -ForegroundColor Green

$username = Get-AzStorageFile -ShareName $ShareName | Out-GridView -Title "Choose User" -PassThru

Get-AzStorageFileHandle -ShareName $ShareName -Path $username -Recursive | Sort-Object clientIP,OpenTime

$user = Read-Host -Prompt 'Input the username for the profile you would like to check or type "all" to get all results'
Write-Host "Setting user to search for to $user" -ForegroundColor Green

if ($user -eq 'all'){
    Get-AzStorageFileHandle -ShareName $ShareName -Recursive | Sort-Object clientIP,OpenTime
}

if ($user -ne 'all'){
    Get-AzStorageFileHandle -ShareName $ShareName -Path $username -Recursive | Sort-Object clientIP,OpenTime
}





