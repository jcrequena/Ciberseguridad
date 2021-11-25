#ESCENARIO de Ejemplo
#dominio: ciber.local
#subdominio:brs.ciber.local
#Grupo Global dominio raíz: CIBER-GG-Radius
#Usuario del subdominio brs.ciber.local: jcrequena
#UO=teletrabajo. En esta UO están todos los usuarios que teletrabajan.


#
# 1. Instalar el Rol Servicios de acceso y directivas de redes
#
Install-WindowsFeature -name NPAS -IncludeAllSubFeature  -IncludeManagementTools

# 2. Configuración del servidor RADIUS
# 2.1 Registrar el servidor NPS en Active Directory. 
#     De esta forma, el servidor tendrá autoridad para leer las propiedades de las cuentas de usuario de Active Directory para autenticar a los usuarios. 
#     El servidor se agregará al grupo de dominio integrado Servidores RAS e IAS.
netsh ras add registeredserver


# 2.2 Añadir clientes radius
# https://docs.microsoft.com/en-us/powershell/module/nps/new-npsradiusclient?view=windowsserver2019-ps
# Este comando, configurara un cliente Radius,donde
# Name, será el nombre que le daremos a la maquina que usaremos como cliente.
# Address será la Ip de dicha maquina.
# VendorName será el tipo de radius que usaremos.
# Sharesecret la contraseña para establecer la conexión.

New-NpsRadiusClient -Name “ClientRadius-Subdominio1” -Address “192.168.11.253” `-SharedSecret “eeepc20” -VendorName “Radius Standard”

# Reiniciamos el servicio para que actualice las nueos clientes radius
Restart-Service IAS

# 2.3 Configurar NPS Policies
#     Las políticas de NPS permiten autenticar usuarios remotos y otorgarles permisos de acceso configurados en el rol de NPS.
#     1. Políticas de solitud de conexión
#     2. Políticas de red.
#     Se pueden crear en un servidor con GUI y exportarlas para luego importarlas en el Servidor Radius Core.     
#     Export-NpsConfiguration -Path c:\ps\backup_nps.xml
#     Import-NpsConfiguration -Path c:\ps\backup_nps.xml

# 2.4 Establecer el Marcado del usuario del subdominio que se autenticará en el Servidor Radius
Get-ADUser jcrequena -Properties msNPAllowDialin -Server brs.ciber.local
# Si el comando anterior no devolvió ningún resultado (vacío), 
# esto significa que se utiliza el valor predeterminado "Control de acceso a través de la política de red NPS"
# Para establecer el marcado de manera masiva a los usuarios de una UO, hacemos
Get-ADUser -SearchBase "ou=Teletrabajo,dc=brs,dc=ciber,dc=local" -LDAPFilter "(msNPAllowDialin=*)" | % {Set-ADUser $_ -Properties msNPAllowDialin}

