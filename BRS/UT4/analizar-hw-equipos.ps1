$credenciales=Get-Credential
1..254 | %{
    (Get-WmiObject Win32_AutochkSetting -ComputerName ('192.25.81.254) -Credential $credenciales).SettingID
    (Get-WmiObject Win32_BaseBoard -ComputerName ('192.25.81.'+$_) -Credential $credenciales).Manufacturer
    (Get-WmiObject Win32_BIOS -ComputerName ('192.25.81.'+$_) -Credential $credenciales).Version
    (Get-WmiObject Win32_Bus -ComputerName ('192.25.81.'+$_) -Credential $credenciales).DeviceID
    Get-WmiObject Win32_Processor -ComputerName ('192.25.81.'+$_) -Credential $credenciales
    Get-WmiObject Win32_SystemEnclosure -ComputerName ('192.25.81.'+$_) -Credential $credenciales
    Get-WmiObject Win32_Battery -ComputerName ('192.25.81.'+$_) -Credential $credenciales
    Get-WmiObject Win32_Printer -ComputerName ('192.25.81.'+$_) -Credential $credenciales
}

#Sistema operativo instalado sobre una partición
(Get-WmiObject Win32_AutochkSetting).SettingID

#Fabricante de placa base
(Get-WmiObject Win32_BaseBoard).Manufacturer

#Versión de la BIOS
(Get-WmiObject Win32_BIOS).Version

#Buses conectados
(Get-WmiObject Win32_Bus).DeviceID

#Información sobre el procesador
Get-WmiObject Win32_Processor
if((Get-WmiObject Win32_Processor).Caption -match "Intel"){"Intel"}else{"No es Intel"}

#Serial del fabricante que identifica el equipo
Get-WmiObject Win32_SystemEnclosure
(Get-WmiObject Win32_SystemEnclosure).SerialNumber


#Almacenar información sobre hardware
(Get-WmiObject Win32_AutochkSetting).SettingID | Out-File infoHW.txt -Append
(Get-WmiObject Win32_BaseBoard).Manufacturer | Out-File infoHW.txt -Append
(Get-WmiObject Win32_BIOS).Version | Out-File infoHW.txt -Append
(Get-WmiObject Win32_Bus).DeviceID | Out-File infoHW.txt -Append
Get-WmiObject Win32_Processor | Out-File infoHW.txt -Append
Get-WmiObject Win32_SystemEnclosure | Out-File infoHW.txt -Append

