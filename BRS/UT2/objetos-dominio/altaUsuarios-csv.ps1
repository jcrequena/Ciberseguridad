alta_Usuarios.ps1
#A la ejeción del script le pasamos 2 parámetros para capturar el nombre del dominio y sufijo 
#(donde queremos crear los usuarios)
#Parámetro 1: el nombre netbios del dominio.
#Parámetro 2: el sufijo del dominio
#Ejemplo: brs.ciber.local --> Parámetro 1 sería smr y Parámetro 2 local
#Ejemplo de ejecución del script: alta_Usuarios.ps1 smr local 

#
#Capturamos los 2 parámetros que hemos pasado en la ejecución del script ($a será el nombre del dominio y $b el sufijo)
#
param($a,$b,$c)
$subdominio=$a
$dominio=$b
$sufijo=$c
#En la variable dc componemos el nombre subdominio, dominio y sufijo. Ejemplo: dc=brs,dc=ciber,dc=local.
$dc="dc="+$subdominio+","dc="+$dominio+",dc="+$sufijo

#
#Primero hay que comprobar si se tiene cargado el módulo Active Directory
#
if (!(Get-Module -Name ActiveDirectory)) #Accederá al then solo si no existe una entrada llamada ActiveDirectory
{
  Import-Module ActiveDirectory #Se carga el módulo
}

#
#Creación de los usuarios
#
#
#Preguntamos al usuario que nos indique el fichero csv
#
$fichero_csv=Read-Host "Introduce el fichero csv de los usuarios:"

#El fichero csv tiene esta estructura (9 campos)
#Name:Surname:Surname2:NIF:Group:ContainerPath:RemoteAccess

#
#Importamos el fichero csv (comando import-csv) y lo cargamos en la variable fichero_csv. 
#El delimitador usado en el csv es el : (separador de campos)
#
$fichero_csv_importado = import-csv -Path $fichero_csv -Delimiter : 			     
foreach($linea_leida in $fichero_csv_importado)
{
	#Componemos la ruta donde queda ubicado el objeto a crear (usuario). Ejemplo: OU=DepInformatica,dc=smr,dc=local
  	$rutaContenedor =$linea_leida.ContainerPath+","+$dc 
	
	#
  #Guardamos de manera segura la contraseña con el comando ConvertTo-SecureString. En este caso, la contraseña corresponde al NIF (9 números + letra)
	#
  $passAccount=ConvertTo-SecureString $linea_leida.NIF -AsPlainText -force
	
	#Asignamos a las variables lo capturado de los campos del csv
	$name=$linea.Name
	$nameShort=$linea.Name+'.'+$linea_leida.Surname
	$Surnames=$linea.Surname+' '+$linea_leida.Surname2
	$nameLarge=$linea.Name+' '+$linea_leida.Surname+' '+$linea_leida.Surname2
	$email=$nameShort+"@"+$a+"."+$b
	
	#
	#El parámetro -Enabled es del tipo booleano por lo que hay que leer la columna del csv
	#que contiene el valor true/false para habilitar o no habilitar el usuario y convertirlo en boolean.
	#
	[boolean]$Habilitado=$true
  If($linea_leida.RemoteAccess -Match 'false') { $Habilitado=$false}
  
	New-ADUser `
    		-SamAccountName $nameShort `
    		-UserPrincipalName $nameShort `
    		-Name $nameShort `
		    -Surname $Surnames `
    		-DisplayName $nameLarge `
    		-GivenName $name `
		    -Description "Cuenta de $nameLarge" `
    		-EmailAddress $email `
		    -AccountPassword $passAccount `
		    -CannotChangePassword $false `
    		-ChangePasswordAtLogon $true `
		    -PasswordNotRequired $false `
    		-Path $rutaContenedor
    		
  #Asignar la cuenta de Usuario creada a un Grupo
	# Distingued Name CN=Nombre-grupo,ou=..,ou=..,dc=..,dc=...
	$cnGrpAccount="Cn="+$linea_leida.Group+","+$rutaContenedor
	 Add-ADGroupMember -Identity $cnGrpAccount -Members $nameShort
}
#
#Las propiedades de New-ADUser que se han utilizado son:
#
#SamAccountName: nombre de la cuenta SAM para compatibilidad con equipos anteriores a Windows 2000.
#UserPrincipalName: Nombre opcional que puede ser más corto y fácil de recordar que el DN (Distinguished Name) y que puede ser utilizado por el sistema.
#Name: Nombre de la cuenta de usuario.
#Surname: Apellidos del usuario.
#DisplayName: Nombre del usuario que se mostrará cuando inicie sesión en un equipo.
#GivenName: Nombre de pila.
#Description: Descripción de la cuenta de usuario.
#EmailAddress: Dirección de correo electrónico.
#AccountPassword: Contraseña encriptada.
#CannotChangePassword: El usuario no puede cambiar la contraseña (como antes, tiene dos valores: $true y $false).
#ChangePasswordAtLogon: Si su valor es $true obliga al usuario a cambiar la contraseña cuando vuelva a iniciar sesión.
#PasswordNotRequired: Permite que el usuario no tenga contraseña.
