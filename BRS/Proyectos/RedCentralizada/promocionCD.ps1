#
# Script de Windows PowerShell para implementación de AD DS en nuevo Bosque
#

$dominioFQDN = "bsr.local"
$dominioNETBIOS = "BSR"
$adminPass = "jcr-bsr2021."

if (!(Get-Module -Name ADDSDeployment)) #Se comprueba si se tiene cargado el módulo
{
  Import-Module ADDSDeployment #Se carga el módulo
}

Install-ADDSForest `
-CreateDnsDelegation:$False `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName $dominioFQDN `
-DomainNetbiosName $dominioNETBIOS `
-SafeModeAdministratorPassword (ConvertTo-SecureString -string $adminPass -AsPlainText -Force)
-ForestMode "WinThreshold" `
-InstallDns:$True `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$False `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
