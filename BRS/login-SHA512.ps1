[Reflection.Assembly]::LoadWithPartialName("System.Web")
$hash = [System.Web.Security.FormsAuthentication]::HashPasswordForStoringInConfigFile("brs", "SHA512")
 
$nombre_pass="juancar,$hash"
$nombre_pass | Out-File usuarioBRS.dat
 
$usuario = Read-Host "Introduce el nombre del usuario"
$passdeUsuario = Read-Host "Introduce el password del usuario"
 
$hash2 = [System.Web.Security.FormsAuthentication]::HashPasswordForStoringInConfigFile($passdeUsuario, "SHA512")
 
$compruebaNombrePassr = (gc .\usuarioBRS.dat)
 
if($compruebaNombrePassr.split(",")[0] -eq $usuario -and $compruebaNombrePassr.split(",")[1] -eq $hash2)
{
    "hace login"
}
else
{
    "no hace login"
}
