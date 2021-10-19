[Reflection.Assembly]::LoadWithPartialName("System.Web")
$hash = [System.Web.Security.FormsAuthentication]::HashPasswordForStoringInConfigFile("brs", "SHA512")
 
$nombre_pass="juancar,$hash"
#Se guarda en el fichero usuarioBRS.dat el nombre de usuario y el hash del password (brs)
$nombre_pass | Out-File usuarioBRS.dat
 
$usuario = Read-Host "Introduce el nombre del usuario"
$passdeUsuario = Read-Host "Introduce el password del usuario"
 
$hash2 = [System.Web.Security.FormsAuthentication]::HashPasswordForStoringInConfigFile($passdeUsuario, "SHA512")
 
#Con el cmdLet gc (Get-Content) almacenamos en la variable $compruebaNombrePass el contenido del fichero usuarioBRS.dat
$compruebaNombrePass = (gc .\usuarioBRS.dat)
if($compruebaNombrePassr.split(",")[0] -eq $usuario -and $compruebaNombrePass.split(",")[1] -eq $hash2)
{
    "hace login"
}
else
{
    "NO hace login"
}
