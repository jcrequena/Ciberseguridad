#Variables globales
$domain="dc=ciber,dc=mylocal"
#
#Funciones en la cabecera del script
#

function Show-Menu
{
     param (
           [string]$Titulo = 'Menú principal'
     )
     Clear-Host
     Write-Host "================ $Titulo ================"
    
     Write-Host "1: Opción '1' Crear UOs."
     Write-Host "2: Opción '2' Crear Grupos."
     Write-Host "3: Opción '3' Crear Usuarios."
     Write-Host "Q: Opción 'Q' Salir."
}
function alta_UOs
{
     $ficheroCsvUO=Read-Host "Introduce el fichero csv de UO's:"
     $ficheroImportado = import-csv -Path $ficheroCsvUO -delimiter :
     foreach($line in $ficheroImportado)
     {
          New-ADOrganizationalUnit -Description:$line.Description -Name:$line.Name `
		-Path:$line.Path -ProtectedFromAccidentalDeletion:$true 
     }
     Write-Host "Se han creado las UOs satisfactoriamente en el dominio $domain"
}
function alta_grupos
{
     	$gruposCsv=Read-Host "Introduce el fichero csv de Grupos:"
	$ficheroImportado = import-csv -Path $gruposCsv -delimiter :
	foreach($linea in $ficheroImportado)
	{
		
		New-ADGroup -Name:$linea.Name -Description:$linea.Description `
			-GroupCategory:$linea.Category `
			-GroupScope:$linea.Scope  `
			-Path:$linea.Path
	}
 	 Write-Host "Se han creado las grupos satisfactoriamente en el dominio $domain"
     
}
function alta_usuarios
{
	$fileUsersCsv=Read-Host "Introduce el fichero csv de los usuarios:"
	$ficheroImportado = import-csv -Path $fileUsersCsv -Delimiter : 				     
	foreach($linea in $ficheroImportado)
	{
		$passAccount=ConvertTo-SecureString $linea.DNI -AsPlainText -force
		$Surnames=$linea.FirstName+' '+$linea.LastName
		$nameLarge=$linea.Name+' '+$linea.FirstName+' '+$linea.LastName
		$email=$linea.Email
		[boolean]$Habilitado=$true
    		If($linea.Enabled -Match 'false') { $Habilitado=$false}
		#Establecer los días de expiración de la cuenta (Columna del csv ExpirationAccount)
   		$ExpirationAccount = $linea.ExpirationAccount
    		$timeExp = (get-date).AddDays($ExpirationAccount)
		#
		# Ejecutamos el comando para crear el usuario
		#
		New-ADUser -SamAccountName $linea.Account -UserPrincipalName $linea.Account -Name $linea.Account `
			-Surname $Surnames -DisplayName $nameLarge -GivenName $linea.Name `
			-Description "Cuenta de $nameLarge" -EmailAddress $email `
			-AccountPassword $passAccount -Enabled $Habilitado `
			-CannotChangePassword $false -ChangePasswordAtLogon $true `
			-PasswordNotRequired $false -Path $linea.Path -AccountExpirationDate $timeExp `
   		-LogonWorkstations $linea.computer
		
  		#
  		## Establecer horario de inicio de sesión       
      $horassesion = $linea.NetTime -replace(" ","")
      net user $linea.Account /times:$horassesion 
		
  		#Asignar cuenta de Usuario a Grupo
		# Distingued Name CN=Nombre-grupo,ou=..,ou=..,dc=..,dc=...
		#En este caso el grupo se encuentra en la misma UO que el usuario
    $cnGrpAccount="Cn="+$linea.Group+","+$linea.Path
		Add-ADGroupMember -Identity $cnGrpAccount -Members $linea.Account
		
	}     
}


#Primero comprobaremos si se tiene cargado el módulo Active Directory
if (!(Get-Module -Name ActiveDirectory)) #Accederá al then solo si no existe una entrada llamada ActiveDirectory
{
  Import-Module ActiveDirectory #Se carga el módulo
}


#
#MENU PRINCIPAL
#
do
{
     Show-Menu
     $input = Read-Host "Por favor, pulse una opción"
     switch ($input)
     {
           '1' {
                Clear-Host
                alta_UOs
           } '2' {
                Clear-Host
                alta_grupos
           } '3' {
                Clear-Host
                alta_usuarios
           } 'q' {
                'Salimos de la App'
                return
           }
     }
     pause
}
until ($input -eq 'q')
