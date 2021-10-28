
$pass="VuestroPassword"
$passAccount=ConvertTo-SecureString $pass -AsPlainText -force

New-LocalUser “nombre_usuario” -Password $passAccount –Fullname “Nombre completo” -Description “Descripción de la cuenta”


Add-LocalGroupMember -Group “Administradores” -Member “usuario_creado” 
