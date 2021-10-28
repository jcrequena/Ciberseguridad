
$pass="VuestroPassword"
$passAccount=ConvertTo-SecureString $pass -AsPlainText -force

New-LocalUser “nombre_usuario” -Password $passAccount –Fullname “Nombre completo” -Description “Descripción de la cuenta”

Add-ADGroupMember -Identity “Administradores” -Members “usuario_creado” 
