#Añadir un usuario de un subdominio a un grupo del dominio raiz
#
Add-ADGroupMember -Identity nombreGrupoGlobalSeguridad -Members subdomino\NombreUsuario

#Caso de ejemplo
#dominio: ciber.local
#subdominio:brs.ciber.local
#Grupo Global dominio raíz: CIBER-GG-Radius
#Usuario del subdominio brs.ciber.local: jcrequena
#El comando a ejecutar en el domino raíz ciber.local sería:
Add-ADGroupMember -Identity  CIBER-GG-Radius -Members brs.ciber.local\jcrequena
