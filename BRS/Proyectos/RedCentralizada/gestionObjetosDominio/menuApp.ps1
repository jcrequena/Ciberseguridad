# Fuente: https://gallery.technet.microsoft.com/scriptcenter/Menu-simple-en-PowerShell-95e1f923
# Paso de parámetros al ejecutar el script en la consola
# Este script recoge 2 parámetros en la llamada del mismo en la consola. 
# La ejecución del script será de esta forma, donde el parámetro distinguishedName será el de vuestro subdominio.
# ejemplo: brs.ciber.local, donde brs es el subdominio de ciber.local
#./menuApp.ps1 distinguishedName
Param(
  [string]$Param1,
)
$distinguishedName= $Param1


#Función 1. Crear grupos
function crearGrupos
{
    Write-Host "Crear grupos.."
}

#Función 1. Crear administradoresParciales
function crearAdminParciales
{
  Write-Host "Crear AdminParciales.."
}

#Función mostrarMenu muestra un menú por pantalla con 3 opciones y una última para salir del mismo
# La función “mostrarMenu”, puede tomar como parámetro un título y devolverá por pantalla 
# "================ $Titulo================" , donde $Titulo será el título pasado por parámetro.
#Si no se le pasa un parámetro, por defecto $Titulo contendrá la cadena 'Selección de opciones'  
#https://technet.microsoft.com/es-es/library/jj554301.aspx
function mostrarMenu 
{ 
     param ( 
           [string]$Titulo = 'Selección de opciones' 
     ) 
     Clear-Host 
     Write-Host "================ $Titulo================" 
      
     
     Write-Host "1. Primera Opción" 
     Write-Host "2. Segunda Opción" 
     Write-Host "3. Tercera Opción" 
     Write-Host "S. Presiona 'S' para salir" 
}
#Bucle principal del Script. El bucle se ejecuta de manera infinita hasta que se cumple
#la condición until ($input -eq 's'), es decir, hasta que se pulse la tecla s.
do 
{ 
     #Llamamos a la función mostrarMenu, para dibujar el menú de opciones por pantalla
     mostrarMenu 
     #Recogemos en la varaible input, el valor que el usuario escribe por teclado (opción del menú)
     $input = Read-Host "Elige una opción" 
     switch ($input) 
     { 
           '1' { 
                Clear-Host  
                'Primera Opción' 
                pause
           } '2' { 
                Clear-Host  
                'Segunda Opción' 
                pause
           } '3' { 
                Clear-Host  
                'Tercera Opción' 
                pause
           } 's' {
                'Saliendo del script...'
                return 
           } 
           #Si no se selecciona una de las opciones del menú, es decir, se pulsa algun carácter
           #que no sea 1, 2, 3 o s, sacamos por pantalla un aviso e indicamos lo que hay que realizar.
           default { 
              'Por favor, Pulse una de las opciones disponibles [1-3] o s para salir'
           }
     } 
     pause 
} 
until ($input -eq 's')
