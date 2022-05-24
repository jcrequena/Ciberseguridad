#!/bin/bash


#Faltaría añadir al script, la parte de activación del forward para que los clientes pudiesen navegar a través del servidor.


# Actualizamos repositorios e instalamos los paquetes necesarios
apt-get update
apt-get install wireguard wireguard-tools wireguard-dkms -y
apt-get install qrencode -y

# Configuracion del servidor (IP Publica, puerto y nombre de la interface de red)
IP_RED="192.168.1.131"
PUERTO="51820"
INTERFACE="enp0s3"

# Config Server VPN
PRIVATE_SERVER=$(/usr/bin/wg genkey)
PUBLIC_SERVER=$(echo ${PRIVATE_SERVER} | /usr/bin/wg pubkey)
IP_SERVER="192.168.100.1/24"

# Config Cliente 1
PRIVATE_CLIENT1=$(/usr/bin/wg genkey)
PUBLIC_CLIENT1=$(echo ${PRIVATE_CLIENT1} | /usr/bin/wg pubkey)
IP_CLIENT1="192.168.100.2"

# Config Cliente2
PRIVATE_CLIENT2=$(/usr/bin/wg genkey)
PUBLIC_CLIENT2=$(echo ${PRIVATE_CLIENT2} | /usr/bin/wg pubkey)
IP_CLIENT2="192.168.100.3"

# Creamos todos los ficheros de configuracion (servidor y 2 clientes)
echo "[Interface]
Address = ${IP_SERVER}
PrivateKey = ${PRIVATE_SERVER}
ListenPort = ${PUERTO}
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ${INTERFACE} -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ${INTERFACE} -j MASQUERADE

[Peer]
PublicKey = ${PUBLIC_CLIENT1}
AllowedIPs = ${IP_CLIENT1}/32

[Peer]
PublicKey = ${PUBLIC_CLIENT2}
AllowedIPs = ${IP_CLIENT2}/32" > /etc/wireguard/wg0.conf

echo "[Interface]
PrivateKey = ${PRIVATE_CLIENT1}
Address = ${IP_CLIENT1}/24
DNS = 8.8.8.8,8.8.4.4

[Peer]
PublicKey = ${PUBLIC_SERVER}
Endpoint = ${IP_RED}:${PUERTO}
AllowedIPs = 0.0.0.0/0" > /etc/wireguard/cliente1.conf 

echo "[Interface]
PrivateKey = ${PRIVATE_CLIENT2}
Address = ${IP_CLIENT2}/24
DNS = 8.8.8.8,8.8.4.4

[Peer]
PublicKey = ${PUBLIC_SERVER}
Endpoint = ${IP_RED}:${PUERTO}
AllowedIPs = 0.0.0.0/0" > /etc/wireguard/cliente2.conf 

clear

#Reiniciamos la vpn (si no se ha crado la interface, el propio wireguard la crea)
/usr/bin/wg-quick down wg0 
/usr/bin/wg-quick up wg0 

# Generamos los QR para los clientes
echo "CLIENTE 1"
/usr/bin/qrencode -t ansiutf8 < /etc/wireguard/cliente1.conf

echo "CLIENTE 2"
/usr/bin/qrencode -t ansiutf8 < /etc/wireguard/cliente2.conf
