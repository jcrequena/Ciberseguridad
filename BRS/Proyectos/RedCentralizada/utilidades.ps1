#Consola cmd
#
#Comprobar la lista de controladores del dominio con cuentas en el dominio

netdom query dc

#
#Compronar controlador del dominio principal
#
netdom query fsmo

#
#Información sobre el proceso de replicación
#
repadmin /showrepl
#Comprobar errores en la replicación
repadmin /ReplSummary

#Comprobar la replicación
repadmin /replsum * /bysrc /bydest /sort:delta

