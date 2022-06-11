Write-Host "==================================================="
Write-Host "            AD User Creation Script                "
Write-Host "==================================================="

Import-Module ActiveDirectory
Write-Host = "Importing Active Directory module"

## Script Variables

$name = Read-Host -Prompt "Provide the name and surname for the user"
Write-Host = "The name has been set to $name" -ForegroundColor Green

$username = Read-Host -Prompt "Provide the username for the user"
Write-Host = "The username has been set to $username"

$city = Read-Host -Prompt "Provide the city the user is located in"
Write-Host = "The city has been set to $city" -ForegroundColor Green

$description = Read-Host -Prompt "Provide a descripition for the user eg: Sales Director"
Write-Host = "The description has been set to $description" -ForegroundColor Green

$pwd1 = Read-Host "Provide an initial password for this account. Note: the password will need to be changed at first login" -AsSecureString

$OU = Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Out-Gridview -Title "Select the OU where to place the user" -PassThru
Write-Host = "The OU where the user will be created is $OU"

New-ADUser -Name $name -SamAccountName $username -UserPrincipalName $username -City $city -Description $description -AccountPassword $pwd1 -ChangePasswordAtLogon $true -Enabled $true -Path $OU
Write-Host = "User is being created"

$anotheruser = Read-Host -Prompt "Would you like to create another user"

do {
    $name = Read-Host -Prompt "Provide the name and surname for the user"
    Write-Host = "The name has been set to $name" -ForegroundColor Green
    
    $username = Read-Host -Prompt "Provide the username for the user"
    Write-Host = "The username has been set to $username"
    
    $city = Read-Host -Prompt "Provide the city the user is located in"
    Write-Host = "The city has been set to $city" -ForegroundColor Green
    
    $description = Read-Host -Prompt "Provide a descripition for the user eg: Sales Director"
    Write-Host = "The description has been set to $description" -ForegroundColor Green
    
    $pwd1 = Read-Host "Provide an initial password for this account. Note: the password will need to be changed at first login" -AsSecureString
    
    $OU = Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Out-Gridview -Title "Select the OU where to place the user" -PassThru
    Write-Host = "The OU where the user will be created is $OU"
    
    New-ADUser -Name $name -SamAccountName $username -UserPrincipalName $username -City $city -Description $description -AccountPassword $pwd1 -ChangePasswordAtLogon $true -Enabled $true -Path $OU
    Write-Host = "User is being created" 

    $anotheruser = Read-Host -Prompt "Would you like to create another user"
} while (
    $anotheruser -eq "Yes")

Write-Host = "The script will now exit" -ForegroundColor Green

