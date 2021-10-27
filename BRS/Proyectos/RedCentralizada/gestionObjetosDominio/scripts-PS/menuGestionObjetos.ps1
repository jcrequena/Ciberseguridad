#
#Funciones en la cabcera del script
#

function Show-Menu
{
     param (
           [string]$Titulo = 'Menú principal'
     )
     Clear-Host
     Write-Host "================ $Titulo ================"
    
     Write-Host "1: Opción '1' Acción 1."
     Write-Host "2: Opción '2' Acción 2."
     Write-Host "3: Opción '3' Acción 3."
     Write-Host "Q: Opción 'Q' Salir."
}
#
# Antes de insertar un objeto en AD, hay que comprobar que NO existe
#

#Primero comprobaremos si se tiene cargado el módulo Active Directory
if (!(Get-Module -Name ActiveDirectory)) #Accederá al then solo si no existe una entrada llamada ActiveDirectory
{
  Import-Module ActiveDirectory #Se carga el módulo
}

#Cada vez que se inserta un objeto en AD, primero hay que comprobar que no existe
#Comprobar si existe un objeto UO en el Controlador del Dominio
$UO=UnidadOrganizativa
if ( !(Get-ADOrganizationalUnit -Filter{ name -eq $UO })) #Devuelve false cuando ya existe la unidad organizativa $UO, y true cuando no existe.
{
}

#Para Grupos
$GRP=Grupo1
if ( !(Get-ADGroup -Filter { name -eq $GRP })) #Devuelve false cuando ya existe el grupo $GRP, y true cuando no existe.
{
}

#Para usuarios
$usu=JC
if ( !!(Get-ADUser -filter { name -eq $usu }) ) #Devuelve false cuando ya existe el grupo $usu, y true cuando no existe.
{
}
#Para equipos
$computer=W7-001
if ( !!(Get-ADComputer -filter { name -eq $computer }) ) #Devuelve false cuando ya existe el ordenador $computer, y true cuando no existe.
{
}
#
# Fin comprobación de objetos
#

#
#MENU PRINCIPAL
#
do
{
     Show-Menu
     $input = Read-Host "Por favor, pulse una opción"
     switch ($input)
     {
           '1' {
                Clear-Host
                #llamar a la función que haga la acción 1
           } '2' {
                Clear-Host
                #llamar a la función que haga la acción 2
           } '3' {
                Clear-Host
                #llamar a la función que haga la acción 2
           } 'q' {
                'Salimos de la App'
                return
           }
     }
     pause
}
until ($input -eq 'q')
