<#
.SYNOPSIS
Sets the WinRM Listener Configuration

.DESCRIPTION
The script will configure the WinRM Listener for HTTPS 

.PARAMETER RootCA
Specifies the Root CA name of the certificate used for WinRM communication

.PARAMETER ConfigureFirewall
(Optional) Configure the Windows Firewall for WinRM HTTPS traffic. Useful if you are not using other tools to manage the firewall (eg GPO)

.PARAMETER FirewallScope
Used in conjunction with the ConfigureFirewall parameter. Specifies remote addresses that are configured within the Windows Firewall rule.

.EXAMPLE
set-winrm-listener.ps1 -RootCA "ExampleCA" -ConfigureFirewall -FirewallScope "192.168.1.1"

.NOTES
Author: Cuan Leo
Version: 1.0
Credit: Thanks to Malinda Rathnayake for the boilerplate config available here - https://www.multicastbits.com/powershell-remoting-winrm-over-https-using-a-ad-cs-pki-ca-signed-client-certificate/
#>

# Global Variables

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [String]$RootCA, 
    [Parameter(Mandatory=$false)]
    [Switch]$ConfigureFirewall,
    [Parameter(Mandatory=$false)]
    [ValidateScript({
        $_ -match '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\/([12][0-9]|3[0-2]|[0-9]))?$'
    })]
    [String]$FirewallScope    
    )

# Check if script is being run with admin privleges    
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires administrator privileges. Please run the script as an administrator."
    exit 1
}

if ($FirewallScope -ne $null -and $ConfigureFirewall -eq $null) {
    throw "The FirewallScope parameter can only be specified in conjunction with the ConfigureFirewall parameter."
}

# Global Variables 

$port=5986
$hostName = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
$certInfo = (Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object {($_.Subject -Like "CN=$hostname") -and ($_.Issuer -Like "CN=$RootCA*")})
$certThumbprint = $certInfo.Thumbprint
$winRMServiceStatus = (Get-Service -Name "WinRM").Status

# Check WinRM Status and terminate script

if ($winRMServiceStatus -ne "Running") {
    Write-Output "The WinRM Service is not running. Trying to start the service"
    Start-Service -Name "WinRM"
    Write-Output "The WinRM Service was successfully started"
}
else {
    Write-Output "The WinRM Service is already running"
}

# Check if certificate exists

if ($certThumbprint) {
    Write-Output "Required certificate is present on $($env:computerName)"
}
else {
    Write-Output "Required certificate is not present on $($env:computerName). Please make sure the certificate is present and re-run the script"
    exit 2
}

# Configure the WinRM listener with the required certificate

$winRMConfig = Get-WSManInstance -ResourceURI 'winrm/config/listener' -Enumerate | Where-Object {$_.Transport -eq "HTTPS" -and $_.CertificateThumbprint -eq $certThumbprint}

if ($winRMConfig.Length -eq 0) {
    Write-Output "No HTTPS Listener with the required certificate found on $($env:computerName), reconfiguring..."
    Get-ChildItem WSMan:\Localhost\Listener | Where-Object -Property Keys -eq "Transport=HTTPS" | Remove-Item -Recurse -Force
    New-Item -Path WSMan:\Localhost\Listener -Transport HTTPS -Address * -CertificateThumbprint $certThumbprint -HostName $hostName -Force
    Write-Output "The HTTPS Listener has been successfully configured on $($env:computerName)"
}
else {
    Write-Output "An HTTPS Listener with the correct certificate is already present on $($env:computerName)"
}

# Configure Windows Firewall if parameter is present 

if ($ConfigureFirewall) {
    Write-Output "Checking for existing WinRM HTTPS Inbound rule"
    $CheckWinRMFirewallRule = Get-NetFirewallRule -Direction Inbound | Get-NetFirewallPortFilter | Where-Object LocalPort -eq $port
    if ($CheckWinRMFirewallRule.Length -eq 0) {
        Write-Output "No firewall rules found for WinRM HTTPS. Configuring Windows Firewall for WinRM HTTPS"
        New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Direction Inbound -LocalPort $port -Protocol TCP -Action Allow
        Write-Output "Windows Firewall has been successfully configured for WinRM HTTPS"
    }
    else {
        Write-Output "An existing firewall rule is already present for WinRM HTTPS"
    }
}