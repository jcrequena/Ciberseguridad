#Establecer política de contraseñas (ejemplo: Longitud mínima 12, complejidad de la contraseña sí)
#En este ejemplo se crea una directiva habilitada con las siguientes propiedades:
#Requiere una contraseña compleja
#Al menos 12 caracteres de longitud
#Requiere una contraseña
#fuente: https://learn.microsoft.com/es-es/powershell/module/configurationmanager/new-cmfdvpassphrasepolicy?view=sccm-ps

New-CMFDVPassPhrasePolicy -PolicyState Enabled -PasswordComplexity Require -MinimumLength 12 -RequirePassword
