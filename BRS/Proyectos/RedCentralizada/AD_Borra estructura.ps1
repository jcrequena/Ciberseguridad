get-adgroup -filter * | ? {$_.Name -like "Técnicos*"} |Remove-ADGroup -Confirm:$false
get-adgroup -filter * | ? {$_.Name -like "Usuarios*"} |Remove-ADGroup -Confirm:$false
get-adgroup -filter * | ? {$_.Name -like "Administradores*"} | Remove-ADGroup -Confirm:$false
get-aduser -filter {SamAccountName -eq "adminjcrequena"} | Remove-ADUser -Confirm:$false
get-aduser -filter {SamAccountName -eq "Operador"} | Remove-ADUser -Confirm:$false
get-content .\OUs_es.txt | foreach-object {Get-ADOrganizationalUnit -Filter {Name -eq $_ } | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion:$false}
get-content .\OUs_es.txt | foreach-object {Get-ADOrganizationalUnit -Filter {Name -eq $_ } | Remove-ADOrganizationalUnit -confirm:$false}
Get-ADOrganizationalUnit -filter *
write-host ("Active Directory limpio de la estructura estandard") -ForegroundColor Yellow
