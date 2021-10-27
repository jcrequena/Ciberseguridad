#alta_UnidadesOrg.ps1 : Parámetro 1 el dc (nombre netbios del dominio) parámetro 2 el sufijo
#
#Creación de las unidades organizativas
#
#El fichero csv usado es el siguiente
#Name:Description:Path
#Ventas:UO Dep.Ventas:
#Marketing:UO Dep. Marketing:

param($dominio,$sufifoDominio)
#Componemos el Domain Component para el dominio que se pasa por parámetro
# en este caso, el dominio es smr.local
#Por lo que hay que componer dc=smr,dc=local
$domainComponent="dc="+$dominio+",dc="+$sufijoDominio

#Solicitamos por pantalla al usuario el fichero csv y guardamos el valor en la variable $ficheroCsvUO
#Ejemplo, el usuario introduce el fichero con la ruta donde se encuentra el mismo: C:\ficherosCsv\unidadesOrgnizativasSMR.csv
$ficheroCsvUO=Read-Host "Introduce el fichero csv de UO's:"

#Leemos el fichero csv mediante la función import-csv de Powershell y esta,
#crea objetos personalizados similares a tablas a partir de los elementos (líneas) en un archivo CSV.
#Con el parámetro delimitador, le decimos a la función qué caracter se usa en el fichero csv para separar cada uno de los
#campos (columnas)
#Cada columna en el archivo CSV se convierte en una propiedad del objeto personalizado $fichero
#y los elementos en filas se convierten en los valores de propiedad.
#Referencia: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-csv?view=powershell-6
$fichero = import-csv -Path $ficheroCsvUO -delimiter :
#Mediante el bucle foreach, leemos el objeto $fichero, es decir, cada pasada por el bucle es la lectura de una
#de las líneas del fichero csv. Cada línea que se lee, se guarda en el objeto $linea
foreach($line in $fichero)
{
	#Con este if condicional, comprobamos si el campo Path del objeto $linea no está vacío.
	#Si no está vacío, componemos la ruta con el valor del campo más el Domain Component. De esta forma
	#componemos el path (ruta) de la unidad organizativa, es decir, su ubicación en el árbol del dominio
	#Si está vacío, guardamos en la variable $pathObjectUO, el contenido de la variable $domainComponent 
	#que hemos compuesto al inicio  del script y que contiene el Domain Component
	if !($line.Path -noMatch '') { $pathObjectUO=$line.Path+","+$domainComponent}
	else {$pathObjectUO=$domainComponent}
	#Antes de crear la OU, primero comprobamos que no exista en el sistema, para ello,
	#hacemos uso del if condicional
	if ( !(Get-ADOrganizationalUnit -Filter { name -eq $line.Name }) )
	{
        	New-ADOrganizationalUnit -Description:$line.Description -Name:$line.Name `
		-Path:$pathObjectUO -ProtectedFromAccidentalDeletion:$true
        }
	else { Write-Host "La unidad organizativa $line.Name ya existe en el sistema"}
}
