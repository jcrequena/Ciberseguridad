#alta_Grupos.ps1 
#Referencia: https://technet.microsoft.com/en-us/library/ee617258.aspx
#El fichero csv que leemos es:
#Name:Path:Description:Category:Scope
#SMR-GG-DepInformatica:OU=Dep-Informatica:Grupo global y de seguridad del Dep.Informatica:Security:Global
#SMR-GG-DepLogistica:OU=Dep-Logistica:Grupo global y de seguridad del Dep.Logistica:Security:Global
#
#Creación de los grupos a partir de un fichero csv
#
$gruposCsv=Read-Host "Introduce el fichero csv de Grupos:"
#Lee el fichero grupos.csv
$fichero = import-csv -Path $gruposCsv -delimiter :
foreach($linea in $fichero)
{
	
	New-ADGroup -Name:$linea.Name -Description:$linea.Description `
		-GroupCategory:$linea.Category `
		-GroupScope:$linea.Scope  `
		-Path:$linea.Path
}
write-Host ""
write-Host "Se han creado los grupos en el dominio $domain" -Fore green
write-Host "" 
