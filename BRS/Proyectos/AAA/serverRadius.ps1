#
# 1. Instalar el Rol Servicios de acceso y directivas de redes
#
Install-WindowsFeature -name NPAS -IncludeAllSubFeature  -IncludeManagementTools

# 2. Configuración del servidor RADIUS
# Crear un cliente radius
# https://docs.microsoft.com/en-us/powershell/module/nps/new-npsradiusclient?view=windowsserver2019-ps
# Este comando, configurara un cliente Radius,donde
# Name, será el nombre que le daremos a la maquina que usaremos como cliente.
# Address será la Ip de dicha maquina.
# VendorName será el tipo de radius que usaremos.
# Sharesecret la contraseña para establecer la conexión.

New-NpsRadiusClient -Name “ClientRadius-Subdominio1” -Address “192.168.11.253” `-SharedSecret “eeepc20” -VendorName “Radius Standard”

# Reiniciamos el servicio para que actualice las nueos clientes radius
Restart-Service IAS
