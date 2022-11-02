#Establecer política de contraseñas (ejemplo: Longitud mínima 12, complejidad de la contraseña sí) para un Dominio (brs.ciber)
#En este ejemplo se crea una directiva habilitada con las siguientes propiedades:
#Requiere una contraseña compleja
#Al menos 12 caracteres de longitud
#Caduca la contraseña a los 10 días (MaxPasswordAge D.H:M:S.F )
#Recuerda las 5 últimas contraseñas (PasswordHistoryCount 5)
#Se configura para que se bloquee si se falla al intento 3.
#Duración del bloqueo 60 minutos
#Ventana de bloqueo (tiempo en minutos antes de que se restablezca el contador de intentos fallidos de contraseña )
#fuente: https://learn.microsoft.com/en-us/powershell/module/activedirectory/set-addefaultdomainpasswordpolicy?view=windowsserver2022-ps


Set-ADDefaultDomainPasswordPolicy -Identity brs.ciber -MinPasswordLength 12 -ComplexityEnabled $True -PasswordHistoryCount 5 -MaxPasswordAge 10.00:00:00 
-LockoutThreshold 3 -LockoutDuration 00:60:00 -LockoutObservationWindow 00:60:00 -ReversibleEncryptionEnabled $False 


#Bloqueo de cuentas con comando net
#Se configura para que se bloquee si se falla al intento 3.
net accounts /lockoutthreshold:3
#Duración del bloqueo 60 minutos
net accounts /lockoutduration:60
#Ventana de bloqueo (tiempo en minutos antes de que se restablezca el contador de intentos fallidos de contraseña )
net accounts /lockoutwindow:60
#Para consultar la configuración de los parámetros establecidos
net accounts 
