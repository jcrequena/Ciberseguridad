# Crear el almacén de claves
/usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash create

# Añadir al almacén la clave con el password del usuario de Elasticsearc
echo "Añadiendo ELS_PWD al almacén de claves..."
/usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash add ELS_PWD

# Añadir al almacén la clave con el nombre del usuario de Elasticsearc
echo "Añadiendo USER al almacén de claves..."
/usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash add USER

# Se lista el almacén para comprobar que se han creado bien
echo "Listando el almacén de claves..."
/usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash list

