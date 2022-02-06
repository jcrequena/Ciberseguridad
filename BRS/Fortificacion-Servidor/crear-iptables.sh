#!/bin/bash

#Limpiamos las tablas
iptables -F
iptables -X
# Limpiamos NAT
iptables -t nat -F
iptables -t nat -X

#Opcional: Tabla mangle para cosas como PPPoE, PPP, and ATM
iptables -t mangle -F
iptables -t mangle -X
#
#Politicas por defecto
# Output(salida) todo porque son conexiones salientes
# Input se descarta todo
# No se hace forward.
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

#Intranet LAN
intranet=enp3s0

#Extranet wan
extranet=enp4s0

# Todo lo que ya está conectado (establecido) lo dejamos así
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Looback device.
iptables -A INPUT -i lo -j ACCEPT

# Si se tiene un servidor http/s
# queremos que sea por todas
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# ssh solo internamente y desde este rango de ip's
iptables -A INPUT -p tcp -s 192.168.0.x/24 -i $intranet --dport 7659 -j ACCEPT
