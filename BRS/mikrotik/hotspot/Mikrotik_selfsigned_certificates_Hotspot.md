#
#Crear un certificado para que el acceso al hotspot sea por https
#
#
#Crear certificado raíz y firmarlo
#
certificate add name=LocalCA common-name=LocalCA key-usage=key-cert-sign,crl-sign

certificate sign LocalCA

#
#Crear certificado para servidor hotspot, firmarlo por la CA raíz y validarlo
#
certificate add name=cert-Hotspot common-name=192.168.11.1 country=SP state=Castellon locality=Castellon organization=IESCaminas trusted=yes

certificate sign certHotspot ca=LocalCA 

certificate set trusted=yes certHotspot
