$nameServer="master-ejemplo"
Rename-Computer -NewName $nameServer

#Para consultar la información de nuestra interfaz de red
Get-NetIPConfiguration
#Para obtener el adaptador de red
Get-NetAdapter

$IPAddress = ”192.168.1.20”
$Gateway = ”192.168.1.1”
$Prefix = 24
$Dns = "192.168.1.1"

#Para configurar la direccion IP (suponiendo que nuestro adaptador de red es el 2)
New-NetIPAddress -InterfaceIndex 2 -IPAddress $IPAddress -PrefixLength $Prefix -DefaultGateway $Gateway
#Para configurar el DNS (suponiendo que nuestro adaptador de red es el 2)
Set-DnsClientServerAddress -InterfaceIndex 2 -ServerAddresses $Dns 

Restart-Computer -force

#NOTA:Si se tiene sólo 1 interfaz de red el comando se puede simplificar
New-NetIPAddress –IPAddress $IPAddress -DefaultGateway $Gateway -PrefixLength $Prefix -InterfaceIndex (Get-NetAdapter).InterfaceIndex
Set-DNSClientServerAddress –InterfaceIndex (Get-NetAdapter).InterfaceIndex –ServerAddresses $IPAddress

#Deshabilitar ipv6
Get-NetAdapterBinding -ComponentID ‘ms_tcpip6’ | Disable-NetAdapterBinding -ComponentID ‘ms_tcpip6’ -PassThru


#Obtener SSID
Get-LocalUser | Select-Object -First 1 -ExpandProperty SID | Write-Host
