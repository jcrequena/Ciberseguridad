hostnamectl set-hostname radius-openldap.ciber.local
nano /etc/hosts
192.168.0.30 radius-openldap.ciber.local

apt update -y && apt upgrade -y
#Install LDAP and reqired Utils
apt install slapd ldap-utils
root@radius-openldap:~# slappasswd
New password:
Re-enter new password:
nano create_ldap_objects.ldif
#Create organizational Units
dn: ou=depInformatica,dc=ciber,dc=local
objectClass: organizationalUnit
ou: depInformatica
dn: ou=grupos,ou=depInformatica,dc=ciber,dc=local
objectClass: organizationalUnit
ou: grupos
#Create LDAP Users
dn: uid=usuInf-01,ou=depInformatica,dc=ciber,dc=local
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: top
cn: Usuario 01 Informática
sn: usuInf01
displayName: Usuario 01 Informática
givenName: UsuInf01
mail: usuInf-01@ciber.local
userPassword: {SSHA}jFQAulicFL0des89xJCDVkyrLlq3dAT3
dn: uid=usuInf-02,ou=depInformatica,dc=ciber,dc=local
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: top
cn: Usuario 02 Informática
sn: usuInf02
displayName: Usuario 02 Informática
givenName: UsuInf02
mail: usuInf-02@ciber.local
userPassword: {SSHA}jFQAulicFL0des89xJCDVkyrLlq3dAT3

#Create global group
dn: cn=GGDepInformatica,ou=grupos,ou=depInformatica,dc=ciber,dc=local
objectClass: groupOfNames
objectClass: top
cn: GGDepInformatica
#Add users in global group
member: uid=usuInf-01,ou=depInformatica,dc=ciber,dc=local
member: uid=usuInf-02,ou=depInformatica,dc=ciber,dc=local

	 
