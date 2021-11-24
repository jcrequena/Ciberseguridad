#
#1. Instalar el Rol Servicios de acceso y directivas de redes
#
Install-WindowsFeature NPAS -IncludeManagementTools

#
#Una vez se instala el cliente Radius
#

#2. Configuración del servidor RADIUS
#Crear un cliente radius
PS C:\>New-NpsRadiusClient -Name “ClienteRADIUS” -Address “192.168.11.253” `
-SharedSecret “eeepc20” `
-VendorName “Radius Standard” Restart-Service IAS

#Reiniciamos el servicio
PS C:\>Get-NPSSharedSecretTemplate
