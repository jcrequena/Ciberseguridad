#Ejecutar Powershell como Administrador
#Referencia: https://www.solvetic.com/tutoriales/article/8728-cambiar-contrasena-administrador-local-dominio-powershell/
#P@ssw0rd es la contraseña a modificar

$NewPassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
#En Usuario poner el usuario al que se le quiere cambiar el password
Set-LocalUser -Name Usuario -Password $NewPassword
