#Ver de que servidor obtiene la hora nuestro windows
W32tm /query /configuration

#Establecer un servidor personalizado del que obtener la hora
w32tm /config /manualpeerlist:"0.es.pool.ntp.org time.google.com" /syncfromflags:manual /update

#Comprobar que se han establecido los dos servidores correctamente
W32tm /query /configuration

#Comprobar que la fecha se ha establecido correctamente
get-date
