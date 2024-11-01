#El fichero csv usado tiene estos campos/columnas
Name*Surname*Surname1*Surname2*Account*OU*Group*Departament*Enabled*Password*ExpirationAccount*NetTime
# Llamada: alta_Usuarios.ps1 ciber mylocal
#Capturamos los 2 parámetros que hemos pasado en la ejecución del script
PParam(
    [string] $dominio,
    [string] $sufijo
)
$dc="dc="+$dominio+",dc="+$sufijo

#Primero comprobaremos si se tiene cargado el módulo Active Directory
if (!(Get-Module -Name ActiveDirectory)) #Accederá al then solo si no existe una entrada llamada ActiveDirectory
{
  Import-Module ActiveDirectory #Se carga el módulo
}
#
#Creación de los usuarios
#
$fileUsersCsv=Read-Host "Introduce el fichero csv de los usuarios"

#
#Los campos del fichero csv están separados por el carácter asterisco (*)
#
$fichero = import-csv -Path $fileUsersCsv -Delimiter *					     		     
foreach($linea in $fichero)
{
	$passAccount=ConvertTo-SecureString $linea.Password -AsPlainText -force
	$Surnames=$linea.Name+' '+$linea.Surname
	$nameLarge=$linea.Name+' '+$linea.Surname1+' '+$linea.Surname2
	$email=$linea.Account + '@' + $dominio + '.' + $sufijo
	[boolean]$Habilitado=$true
    	If($linea.Enabled -Match 'false') { $Habilitado=$false}
	#Establecer los días de expiración de la cuenta (Columna del csv ExpirationAccount)
   	$ExpirationAccount = $linea.ExpirationAccount
    	$timeExp = (get-date).AddDays($ExpirationAccount)
        $rutaObjeto= 'OU='+ $linea.OU + ',' + $dc
	#
	# Ejecutamos el comando para crear el usuario
	#
        New-ADUser -SamAccountName $linea.Account -UserPrincipalName $linea.Account -Name $linea.Account `
		-Surname $Surnames -DisplayName $nameLarge -GivenName $linea.Name `
		-Description "Cuenta de $nameLarge" -EmailAddress $email `
		-AccountPassword $passAccount -Enabled $Habilitado `
		-CannotChangePassword $false -ChangePasswordAtLogon $true `
		-PasswordNotRequired $false -Path $rutaObjeto -AccountExpirationDate $timeExp
		
  	## Establecer horario de inicio de sesión       
        $horassesion = $linea.NetTime -replace(" ","")
        net user $linea.Account /times:$horassesion 
	#Asignar cuenta de Usuario a Grupo
	# Distingued Name CN=Nombre-grupo,ou=..,ou=..,dc=..,dc=...
	$cnGrpAccount="Cn="+$linea.Group+","+$rutaObjeto
	Add-ADGroupMember -Identity $cnGrpAccount -Members $linea.Account
	
} 
Write-Host "Se han creado los usuarios correctamente en el dominio $dominio" 

# A continuación, las propiedades de New-ADUser que se han utilizado son:
#SamAccountName: nombre de la cuenta SAM para compatibilidad con equipos anteriores a Windows 2000.
#UserPrincipalName: Nombre opcional que puede ser más corto y fácil de recordar que el DN (Distinguished Name) y que puede ser utilizado por el sistema.
#Name: Nombre de la cuenta de usuario.
#Surname: Apellidos del usuario.
#DisplayName: Nombre del usuario que se mostrará cuando inicie sesión en un equipo.
#GivenName: Nombre de pila.
#Description: Descripción de la cuenta de usuario.
#EmailAddress: Dirección de correo electrónico.
#AccountPassword: Contraseña cifrada.
#Enabled: Cuenta habilitada ($true) o deshabilitada ($false).
#CannotChangePassword: El usuario no puede cambiar la contraseña (como antes, tiene dos valores: $true y $false).
#ChangePasswordAtLogon: Si su valor es $true obliga al usuario a cambiar la contraseña cuando vuelva a iniciar sesión.
#PasswordNotRequired: Permite que el usuario no tenga contraseña.
