#!/bin/bash
#set -x
# Menú principal
while true; do
    echo "Seleccione una opción:"
    echo "1. Distribuir el certificado público de la entidad de certificación"
    echo "2. Crear solicitudes de firma de certificados"
    echo "3. Firmar una CSR"
    echo "4. Revocar un certificado"
    echo "5. Generar una lista de revocación de certificados"
    echo "6. Transferir una lista de revocación de certificados"
    echo "7. Verificar los componentes de una CRL"
    echo "8. Salir"
    read -p "Opción: " opcion

    case $opcion in
        1)
           # Opción 1: Distribuir el certificado público de la entidad de certificación
           read -p "Ingrese la dirección IP del destino: " ip_destino
           read -p "Ingrese el nombre de usuario SSH: " usuario_ssh
           read -p "Ingrese la ruta de destino (presione Enter para utilizar la ruta por defecto /home/usuario): " ruta_destino

           # Si no se ingresó ninguna ruta, usar la ruta por defecto
           if [ -z "$ruta_destino" ]; then
           ruta_destino="~"
           fi

           # Verificar si el archivo ca.crt ya existe en la máquina de destino
           ssh $usuario_ssh@$ip_destino "[ -e $ruta_destino/ca.crt ]"

           # Almacenar el estado de salida del comando anterior
           estado_salida=$?

           # Verificar y crear la ruta en el servidor SSH si no existe
           ssh $usuario_ssh@$ip_destino "[ -d $ruta_destino ] || mkdir -p $ruta_destino"

           # Copiar el archivo ca.crt al servidor SSH si no existe
           if [ $estado_salida -ne 0 ]; then
               sudo scp "./pki/ca.crt" $usuario_ssh@$ip_destino:$ruta_destino
               echo "El archivo ca.crt se ha copiado con éxito a la máquina de destino en la ruta: $ruta_destino"
           else
               echo "El archivo ca.crt ya existe en la máquina de destino."
           fi
           ;;
        2)
            # Opción 2: Crear solicitudes de firma de certificados
            read -p "Ingrese la dirección IP del servidor SSH: " ip_ssh
            read -p "Ingrese el nombre de usuario SSH: " usuario_ssh
            read -p "Ingrese el nombre para el certificado: " nombre_certificado

            # Conectarse al servidor SSH y ejecutar los comandos
            ssh $usuario_ssh@$ip_ssh "openssl req -new -key $nombre_certificado.key -out $nombre_certificado.req && \
                openssl req -in $nombre_certificado.req -noout -subject"
            
            # Copiar CSR al directorio actual
            scp $usuario_ssh@$ip_ssh:$nombre_certificado.req ./
            ;;
        3)
            # Opción 3: Firmar una CSR
            read -p "Ingrese el nombre del certificado a firmar: " nombre_certificado
            ./easyrsa import-req $nombre_certificado.req $nombre_certificado && \
            ./easyrsa sign-req server $nombre_certificado
            ;;
        4)
            # Opción 4: Revocar un certificado
            read -p "Ingrese el nombre del certificado a revocar: " nombre_certificado
            ./easyrsa revoke $nombre_certificado
            ;;
        5)
            # Opción 5: Generar una lista de revocación de certificados
            echo "Si se usó una frase de contraseña cuando se creó el archivo ca.key, se solicitará ingresar la misma."
            ./easyrsa gen-crl
            ;;
        6)
            # Opción 6: Transferir una lista de revocación de certificados
            read -p "Ingrese la dirección IP del destino: " ip_destino
            read -p "Ingrese el nombre de usuario SSH: " usuario_ssh
            scp pki/crl.pem $usuario_ssh@$ip_destino:~/
            ;;
        7)
            # Opción 7: Verificar los componentes de una CRL
            openssl crl -in pki/crl.pem -noout -text
            ;;
        8)
            # Opción 8: Salir
            echo "Saliendo del script."
            exit 0
            ;;
        *)
            echo "Opción no válida. Por favor, seleccione una opción del menú."
            ;;
    esac
done
