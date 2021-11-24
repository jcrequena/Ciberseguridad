#
#Configuración de un cliente RADIUS
#

#Instalar el ROl 'Enrutamiento y acceso remoto'
Install-WindowsFeature DirectAccess-VPN -IncludeManagementTools

#Comprobar el cumplimiento de prerrequisitos
Install-RemoteAccess -PreRequisite

#Instalación de VPN
Install-RemoteAccess -VpnType VPN -RadiusServer 192.25.81.254 -SharedSecret “bMSHJzvP7A5xe#VeBJRPrxHLiEzRDaLvTKUXl#ssLCxAuI#W@ghPG2QybudPQoHG” -IPAddressRange 192.25.81.100, 192.168.11.130
