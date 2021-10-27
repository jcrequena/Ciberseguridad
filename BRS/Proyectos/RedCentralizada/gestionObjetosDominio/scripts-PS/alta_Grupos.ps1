#alta_Grupos.ps1 : Parámetro 1 el dc (nombre netbios del dominio) parámetro 2 el sufijo del dominio
#Referencia: https://technet.microsoft.com/en-us/library/ee617258.aspx
#El fichero csv que leemos es:
#Name:Path:Description:Category:Scope
#SMR-GG-DepInformatica:OU=Dep-Informatica:Grupo global y de seguridad del Dep.Informatica:Security:Global
#SMR-GG-DepLogistica:OU=Dep-Logistica:Grupo global y de seguridad del Dep.Logistica:Security:Global
param($dominio,$sufijoDominio)

#Componemos el Domain Component para el dominio que se pasa por parámetro
# en este caso, el dominio es smr.local
#Por lo que hay que componer dc=smr,dc=local
$domainComponent="dc="+$dominio+",dc="+$sufijoDominio

#
#Creación de los grupos a partir de un fichero csv
#
$gruposCsv=Read-Host "Introduce el fichero csv de Grupos:"
#Lee el fichero grupos.csv
$fichero = import-csv -Path $gruposCsv -delimiter :
foreach($linea in $fichero)
{
	$pathObject=$linea.Path+","+$domainComponent
	#Comprobamos si no existe el grupo antes de crearlo.
	if ( !(Get-ADGroup -Filter { name -eq $linea.Name }) )
	{
		New-ADGroup -Name:$linea.Name -Description:$linea.Description `
		-GroupCategory:$linea.Category `
		-GroupScope:$linea.Scope  `
		-Path:$pathObject
	}
	else { Write-Host "El grupo $line.Name ya existe en el sistema"}
}
