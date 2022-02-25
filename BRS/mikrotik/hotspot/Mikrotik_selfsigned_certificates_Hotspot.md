#
#Crear un certificado para que el acceso al hotspot sea por https
#

#Crear certificado raíz
certificate add name=LocalCA common-name=LocalCA key-usage=key-cert-sign,crl-sign
#Firmar el certificado
certificate sign LocalCA

#
#Crear certificado para servidor hotspot
#
certificate add name=cert-Hotspot common-name=192.168.11.1 country=SP state=Castellon locality=Castellon organization=IESCaminas trusted=yes
#Firmar el certificado por la CA raíz
certificate sign certHotspot ca=LocalCA 
#Validar certificado
certificate set trusted=yes certHotspot
