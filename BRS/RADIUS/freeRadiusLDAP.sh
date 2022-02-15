#https://sysopstechnix.com/wpa2-enterprise-secure-your-organization-wi-fi-network/
hostnamectl set-hostname radius-openldap.ciber.local
nano /etc/hosts
127.0.1.1 radius-openldap
192.168.0.30 radius-openldap.ciber.local

apt update -y && apt upgrade -y
#Install LDAP and reqired Utils
apt install slapd ldap-utils

#Se genera un hash de contraseña para los usuarios del directorio para incluirlo
#en el archivo create_ldap_objects.ldif para cada usuario
root@radius-openldap:~# slappasswd
New password:
Re-enter new password:
{SSHA}0/hPk9iPBJQJxuFmM53j+YhQUuSvTzRt

#Crear el fichero ldif con los objetos ldap
#Añadir el fichero al servidor LDAP
ldapadd -x -D cn=admin,dc=ciber,dc=local -W -f crear_objetos_ldap.ldif 

#Install & Configure FreeRADIUS as AAA Server. Required utilities for LDAP integration
apt install freeradius freeradius-ldap freeradius-utils

nano /etc/freeradius/3.0/clients.conf
#El cliente será un punto de acceso o router inalámbrico 	 
client uradius-client {
ipaddr = 192.168.0.50
secret = testing123
}
#Integrate FreeRADIUS with LDAP (for Authentication)
#Add the LDAP server domain name to hosts file
nano /etc/hosts
192.168.0.30 radius-openldap.ciber.local

#Configure LDAP module with LDAP server details
nano /etc/freeradius/3.0/mods-available/ldap
#Añadir la siguiente sección
server = 'radius-openldap.ciber.local
base_dn = 'ou=depInformatica,dc=ciber,dc=local'
identity = 'cn=admin,dc=ciber,dc=local'
password = Camina-100
user {
base_dn = "ou=depInformatica,dc=ciber,dc=local"
#I'm using user's mail id as a username.
filter = "(mail=%{%{Stripped-User-Name}:-%{User-Name}})"
}
group {
 base_dn = "ou=grupos,ou=depInformatica,dc=ciber,dc=local"
filter = '(objectClass=GroupOfNames)'
membership_filter = "(|(&(objectClass=GroupOfNames)(member=%{control:Ldap-UserDn}))(&(objectClass=GroupOfNames)(member=%{control:Ldap-UserDn})))"
membership_attribute = 'member'
}

#Enable the LDAP module
cd /etc/freeradius/3.0/mods-enabled/
ln -s ../mods-available/ldap .

#Restricting access to a specific LDAP groups (for Authorization)
#lines to the file /etc/freeradius/3.0/users:
DEFAULT Ldap-Group == "cn=GGProgramacion,ou=grupos,ou=depInformatica,dc=ciber,dc=local"
Reply-Message = "You are Accepted"
DEFAULT Auth-Type := Reject
Reply-Message = "You are not allowed to access the WLAN!"

#Testing the LDAP Connectivity
#systemctl stop freeradius.service
freeradius -X
#En un equipo cliente radius, vamos a chequear la autenticación de un usuario LDAP en FreeRADIUS server.
apt install freeradius-utils
radtest user03-01@ciber.local abc123 192.168.0.30 10 testing123
