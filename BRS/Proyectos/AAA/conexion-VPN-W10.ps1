#Creación de conexión en Windows 10 utilizando PowerShell
#
#-ServerAddress 192.25.81.2: Es la ip del NAS o cliente Radius
#MSChapv2: Es el protocolo de autenticación basado en contraseña. Es un método de autenticación en VPN basadas en PPTP (Protocolo de túnel punto a punto)
#Fuente: https://support.microsoft.com/es-es/topic/implementaci%C3%B3n-de-la-autenticaci%C3%B3n-peap-ms-chap-v2-para-vpn-pptp-de-microsoft-d5ca1ebe-d9ee-4379-fd3f-e7be05fa3ae2
#
Add-VpnConnection -Name “NombreVPN” -ServerAddress “192.25.81.2” -TunnelType PPTP -AuthenticationMethod MSChapv2 -RememberCredential
