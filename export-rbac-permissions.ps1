######################

# This script will gather the Owner, Contributor and Reader RBAC permissions for each subscription in a given Azure tenant and place this in separate CSV files within a created folder.
# You can edit this script to include more roles or even remove the roles entirely to export all RBAC permissions
# You will first need to login to your Azure tenant using Connect-AzAccount

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

# Script Variables

$subscriptionlist = Get-AzSubscription | where State -eq "Enabled"
$tenant = "Example"
$exportpath = "C:\scripts\Export-AzRoleAssignment\$($customer)"


# Create export directory if it does not exist

if (Test-Path $exportpath) {
    Write-Host "Folder exists"
}
else {
    New-Item $exportpath -ItemType Directory 
    Write-Host "Folder Created successfully"
}

# Loop through each sub and export RBAC permissions to CSV

foreach ($subscription in $subscriptionlist) {
    Set-AzContext -Subscription $($subscription.name)

    Write-Verbose -Message "Exporting Owner RBAC roles for $($subscription.Name)" -Verbose
    Get-AzRoleAssignment | Where-Object {$_.RoleDefinitionName -eq "Owner"} | Select-Object ObjectType,DisplayName,SignInName | Export-Csv -Path C:\scripts\Export-AzRoleAssignment\$tenant\$($subscription.Name)-Owner.csv -NoTypeInformation

    Write-Verbose -Message "Exporting Contributor RBAC roles for $($subscription.Name)" -Verbose
    Get-AzRoleAssignment | Where-Object {$_.RoleDefinitionName -eq "Contributor"} | Select-Object ObjectType,DisplayName,SignInName | Export-Csv -Path C:\scripts\Export-AzRoleAssignment\$tenant\$($subscription.Name)-Contributor.csv -NoTypeInformation
    
    Write-Verbose -Message "Exporting Reader RBAC roles for $($subscription.Name)" -Verbose
    Get-AzRoleAssignment | Where-Object {$_.RoleDefinitionName -eq "Reader"} | Select-Object ObjectType,DisplayName,SignInName | Export-Csv -Path C:\scripts\Export-AzRoleAssignment\$tenant\$($subscription.Name)-Reader.csv -NoTypeInformation
}