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

nano create_ldap_objects.ldif
#Crear UOs
dn: ou=depInformatica,dc=ciber,dc=local
objectClass: organizationalUnit
ou: depInformatica

dn: ou=grupos,ou=depInformatica,dc=ciber,dc=local
objectClass: organizationalUnit
ou: grupos
#Create LDAP Users
dn: uid=user01,ou=depInformatica,dc=ciber,dc=local
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: top
cn: Usuario 01 Informática
sn: user01
displayName: Usuario 01 Informática
givenName: Informática
mail: user01@ciber.local
userPassword: {SSHA}0/hPk9iPBJQJxuFmM53j+YhQUuSvTzRt

dn: uid=user02,ou=depInformatica,dc=ciber,dc=local
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: top
cn: Usuario 02 Informática
sn: user02
displayName: Usuario 02 Informática
givenName: Informática
mail: user01@ciber.local
userPassword: {SSHA}0/hPk9iPBJQJxuFmM53j+YhQUuSvTzRt

dn: uid=user03,ou=depInformatica,dc=ciber,dc=local
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: top
cn: Usuario 03 Informática
sn: user03
displayName: Informática User03
givenName: Informática
mail: user03@ciber.local
userPassword: {SSHA}0/hPk9iPBJQJxuFmM53j+YhQUuSvTzRt

dn: uid=user04,ou=depInformatica,dc=ciber,dc=local
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: top
cn: Informatica User04
sn: user04
displayName: Usuarios 04 Informática
givenName: Informática
mail: user04@ciber.local
userPassword: {SSHA}0/hPk9iPBJQJxuFmM53j+YhQUuSvTzRt

#Create global group
dn: cn=GGProgramacion,ou=grupos,ou=depInformatica,dc=ciber,dc=local
objectClass: groupOfNames
objectClass: top
cn: GGProgramacion
member: uid=user01,ou=depInformatica,dc=ciber,dc=local
member: uid=user02,ou=depInformatica,dc=ciber,dc=local

dn: cn=GGRedes,ou=grupos,ou=depInformatica,dc=ciber,dc=local
objectClass: groupOfNames
objectClass: top
cn: GGRedes
member: uid=user03,ou=depInformatica,dc=ciber,dc=local
member: uid=user04,ou=depInformatica,dc=ciber,dc=local

#Añadir el fichero al servidor LDAP
ldapadd -x -D cn=admin,dc=ciber,dc=local -W -f create_ldap_objects.ldif 

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
