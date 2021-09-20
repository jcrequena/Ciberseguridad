
#Funcion login: usuario/contraseña
#El usuario y contraseña (hash en MD5) correcto se escriben en el bloque BEGIN
 
#Ejecución del script: loginH usuario contraseña
 
function loginH
{
  param
  (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [String[]]
    [AllowEmptyString()] 
    $User,$Pass
  )
 
  begin
  {
    Write-Host "Principio de login"
    $usercorrecto="user"
    #El pass en MD5
    #$passcorrecto="pass"
    $passcorrecto="1A1DC91C907325C69271DDF0C944BC72"
  }
 
  process
  {
   #Realizar el MD5 del pass introducido por el usuario
   [Reflection.Assembly]::LoadWithPartialName("System.Web")
   $Pass
   if($User -eq $usercorrecto -and [System.Web.Security.FormsAuthentication]::HashPasswordForStoringInConfigFile($Pass, "MD5") -eq $passcorrecto)
    {
        $bok=1
    }
    else
    {
        $bok=0
    }
  }
  end
  {
   if($bok)
    {
        Write-Host "User correcto"
    }
    else
    {
        Write-Host "User no correcto"
    }
    Write-Host "Fin de login"
  }
}
