#El fichero csv usado tiene estos campos/columnas
Name*Surname*Surname1*Surname2*account*path*dni*Departament*Enabled*Password*ExpirationAccount*email*NetTime*computer*Group
#Capturamos los 2 parámetros que hemos pasado en la ejecución del script


#Ponemos el Domain Component para el dominio en cuestión, que para este caso es smr.local
$domain="dc=ciber,dc=mylocal"

#Primero comprobaremos si se tiene cargado el módulo Active Directory
if (!(Get-Module -Name ActiveDirectory)) #Accederá al then solo si no existe una entrada llamada ActiveDirectory
{
  Import-Module ActiveDirectory #Se carga el módulo
}
#
#Creación de los usuarios
#
$fileUsersCsv=Read-Host "Introduce el fichero csv de los usuarios:"
#
#Los campos del fichero csv están separados por el carácter ,
#
$fichero = import-csv -Path $fileUsersCsv -Delimiter *
						     		     
foreach($linea in $ficheroImportado)
{
	
	$passAccount=ConvertTo-SecureString $linea.Password -AsPlainText -force
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
		-PasswordNotRequired $false -Path $linea.Path -AccountExpirationDate $timeExp
  		-LogonWorkstations $linea.computer
		
  
  	## Establecer horario de inicio de sesión       
        $horassesion = $linea.NetTime -replace(" ","")
        net user $linea.Account /times:$horassesion 
	
	#Asignar cuenta de Usuario a Grupo
	# Distingued Name CN=Nombre-grupo,ou=..,ou=..,dc=..,dc=...
	$cnGrpAccount="Cn="+$linea.Group+","+$linea.Path
	Add-ADGroupMember -Identity $cnGrpAccount -Members $linea.Account
	
} 
Write-Host "Se han creado los usuarios correctamente en el dominio $domain" 

# A continuación, las propiedades de New-ADUser que se han utilizado son:
SamAccountName: nombre de la cuenta SAM para compatibilidad con equipos anteriores a Windows 2000.
UserPrincipalName: Nombre opcional que puede ser más corto y fácil de recordar que el DN (Distinguished Name) y que puede ser utilizado por el sistema.
Name: Nombre de la cuenta de usuario.
Surname: Apellidos del usuario.
DisplayName: Nombre del usuario que se mostrará cuando inicie sesión en un equipo.
GivenName: Nombre de pila.
Description: Descripción de la cuenta de usuario.
EmailAddress: Dirección de correo electrónico.
AccountPassword: Contraseña encriptada.
Enabled: Cuenta habilitada ($true) o deshabilitada ($false).
CannotChangePassword: El usuario no puede cambiar la contraseña (como antes, tiene dos valores: $true y $false).
ChangePasswordAtLogon: Si su valor es $true obliga al usuario a cambiar la contraseña cuando vuelva a iniciar sesión.
PasswordNotRequired: Permite que el usuario no tenga contraseña.
LogonWorkstations: Permite añadir el equipo que usará el usuario para iniciar sesión.
