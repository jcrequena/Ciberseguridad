#Referencia: https://technet.microsoft.com/es-es/library/hh852258(v=wps.630).aspx
#Para este caso de ejemplo, usamos el csv que contiene lo siguiente
#Computer:Path
#W10-CLI001:OU=Equipos-DepInf,OU=Dep-Informatica
#W10-CLI002:OU=Equipos-DepInf,OU=Dep-Informatica
#Es decir, queremos crear los equipos, en la OU Equipos-DepInf que esta dentro de la OU Dep-Informatica
#Por lo tanto para crear el equipo en esa ruta sobre el dominio smr.local quedaría así:
#OU=Equipos-DepInf,OU=Dep-Informatica,DC=smr,DC=local

#Ponemos el Domain Component para el dominio en cuestión, que para este caso es smr.local
$domain="dc=smr,dc=local"

#
#Creación de los grupos a partir de un fichero csv
#
#Lee el fichero grupos.csv. El carácter delimitador de columna es :
$equiposCsv=Read-Host "Introduce el fichero csv de Equipos:"
$fichero= import-csv -Path $equiposCsv -delimiter ":"

foreach($line in $fichero)
{
	New-ADComputer -Enabled:$true -Name:$line.Computer -Path:$line.Path -SamAccountName:$line.Computer
}

write-Host ""
write-Host "Se han creado los equipos en el dominio $domain" -Fore green
write-Host "" 
