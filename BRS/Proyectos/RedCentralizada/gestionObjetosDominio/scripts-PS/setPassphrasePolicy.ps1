#Establecer política de contraseñas (ejemplo: Longitud mínima 12, complejidad de la contraseña sí)
#En este ejemplo se crea una directiva habilitada con las siguientes propiedades:
#Requiere una contraseña compleja
#Al menos 12 caracteres de longitud
#Requiere una contraseña
#fuente: https://learn.microsoft.com/es-es/powershell/module/configurationmanager/new-cmfdvpassphrasepolicy?view=sccm-ps

New-CMFDVPassPhrasePolicy -PolicyState Enabled -PasswordComplexity Require -MinimumLength 4 -RequirePassword

#Bloqueo de cuentas 
#Se configura para que se bloquee si se falla al intento 3.
net accounts /lockoutthreshold:3
#Duración del bloqueo 60 minutos
net accounts /lockoutduration:60
#Ventana de bloqueo (tiempo en minutos antes de que se restablezca el contador de intentos fallidos de contraseña )
net accounts /lockoutwindow:60
#Para consultar la configuración de los parámetros establecidos
net accounts 
