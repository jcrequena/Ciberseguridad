#alta_Usuarios.ps1 : Parámetro 1 el dc (nombre netbios del dominio) parámetro 2 la extensión y parámetro 3 la ruta del fichero csv
#El fichero csv usado tiene estos campos/columnas
#Name:FirstName:LastName:DNI:Group:ContainerPath:Computer:ExpirationAccount:Group:Enabled
#Capturamos los 2 parámetros que hemos pasado en la ejecución del script
# Ejemplo: alta_Usuarios.ps1 smr local 
param($dominio,$sufijoDominio)
#Componemos el Domain Component para el dominio que se pasa por parámetro
# en este caso, el dominio es smr.local
#Por lo que hay que componer dc=smr,dc=local
$domainComponent="dc="+$dominio+",dc="+$sufijoDominio

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
$fichero = import-csv -Path $fileUsersCsv -Delimiter : 
						     
foreach($linea in $fichero)
{
	$containerPath =$linea.ContainerPath+","+$domainComponent #Ruta donde se creará el usuario

	#Guardamos de manera segura la contraseña que en este caso corresponde al DNI-
	$passAccount=ConvertTo-SecureString $linea.DNI -AsPlainText -force
	
	
	$nameShort=$linea.Name+'.'+$linea.FirstName
	$Surnames=$linea.FirstName+' '+$linea.LastName
	$nameLarge=$linea.Name+' '+$linea.FirstName+' '+$linea.LastName
	$email=$nameShort+"@"+$dominio+"."+$sufijoDominio
	

	#Si el usaurio ya existe (Nombre + 1er Apellido), ampliamos el nombre corto con el 2 Apellido   
	if (Get-ADUser -filter { name -eq $nameShort })
	{
		$nameShort=$linea.Name+'.'+$linea.FirstName+$linea.LastName
	}
	#El parámetro -Enabled es del tipo booleano por lo que hay que leer la columna del csv
	#que contiene el valor tru/false para habilitar/no habilitar el usuario y convertirlo en boolean.
	[boolean]$Habilitado=$true
    	If($linea.Enabled -Match 'false') { $Habilitado=$false}
	
	#Establecer los días de expiración de la cuenta (Columna del csv ExpirationAccount)
	#https://technet.microsoft.com/en-us/library/ee617253.aspx
	#
   	$ExpirationAccount = $linea.ExpirationAccount
    	$timeExp = (get-date).AddDays($ExpirationAccount)
	#
	# Ejecutamos el comando para crear el usuario
	#
	New-ADUser -SamAccountName $nameShort -UserPrincipalName $nameShort -Name $nameShort `
		-Surname $Surnames -DisplayName $nameLarge -GivenName $linea.Name -LogonWorkstations:$linea.Computer `
		-Description "Cuenta de $nameLarge" -EmailAddress $email `
		-AccountPassword $passAccount -Enabled $Habilitado `
		-CannotChangePassword $false -ChangePasswordAtLogon $true `
		-PasswordNotRequired $false -Path $containerPath -AccountExpirationDate $timeExp
	#Asignar cuenta de Usuario a Grupo
	# Distingued Name CN=Nombre-grupo,ou=..,ou=..,dc=..,dc=...
	$cnGrpAccount="Cn="+$linea.Group+","+$containerPath
	Add-ADGroupMember -Identity $cnGrpAccount -Members $nameShort
	#
	## Establecer horario de inicio de sesión de 8am - 6pm Lunes (Monday) to Viernes (Friday)   
	# Para ello, importamos una utilidad (Set-OSCLogonHours) que nos permite establecer el horario
	#
	Import-Module C:\Scripts\LogonHours\SetADUserLogonTime.psm1
	Set-OSCLogonHours -SamAccountName $nameShort -DayofWeek Monday,Tuesday,Wednesday,Thursday,Friday -From 8AM -To 6PM
	
}

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
