# Crear el almacén de claves
filebeat --strict.perms=false keystore create --force
# Añadir al almacén la clave con el password del usuario de Elasticsearc
echo "Añadiendo E_PASS al almacén de claves..."
filebeat keystore add E_PASS
# Añadir al almacén la clave con el nombre del usuario de Elasticsearc
echo "Añadiendo E_USER al almacén de claves..."
filebeat keystore add E_USER
# Se lista el almacén para comprobar que se han creado bien
echo "Listando el almacén de claves..."
filebeat --strict.perms=false keystore list

echo "Cargando Dashboards..."
filebeat setup --dashboards
