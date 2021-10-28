Acciones a realizar en el Subdominio
1.Despromocionar el subdomino: Quitar el Rol AD DS (disminuir el controlador de dominio de nivel).
Los comandos powershell que realizan la despromoción son los siguientes:
Uninstall-addsdomaincontroller
Uninstall-windowsfeature

2.Acceder al sistema con la cuenta local del equipo: Administrador
3.Crear una cuenta nueva que pertenezca al grupo Administradores
Ejemplo:
$pass="Eeuptca-100"
$passAccount=ConvertTo-SecureString $pass -AsPlainText -force
New-LocalUser “jcrequena” -Password $passAccount –Fullname “Juan Carlos Requena” -Description “Cuenta local de administración del equipo”
#Añadir un usuario a un grupo
Add-LocalGroupMember -Group “Administradores” -Member "jcrequena" 


1.Comprobaciones a realizar en el master (dominio-raiz)
2.Comprobar la replicación
3.Abrir una consola cmd y ejecutar:
repadmin /replsum * /bysrc /bydest /sort:delta
Si aparece algun error referido a: Se presentaron los siguientes errores operativos al intentar recuperar la información de replicación:
athos.LAPLANA.san-gva.local
porthos.GENERAL.san-gva.local
Es decir, el dominio raíz muestra información de los subdominios que se acaban de despromocionar, por lo tanto, hay que eliminar en el dominio raíz cualquier información residual de subdominios que existieron en su momento, pero ya no están operativos.

4.Limpiar los metadatos (por si existe información residual de los subdominios que se han despromocionado)
5.Abrir una consola cmd como Administrador
6.Ejecutar el comando ntdsutil y pulsar Enter.
7.Aparecerá en la consola esto --> ntdsutil: --> Hay que escribir metadata cleanup y pulsar Enter.
8.Aparecerá en la consola esto --> metadata cleanup: --> Hay que escribir remove selected server <ServerName> y pulsar Enter, donde <ServerName> es el servidor a eliminar.
 Ejemplo: 
  remove selected server athos.LAPLANA.san-gva.local
  remove selected server porthos.GENERAL.san-gva.local
9.En el cuadro de diálogo Quitar configuración del servidor,revisad la información y la advertencia y, a continuación, 
  hay que hacer clic en Sí para quitar el objeto de servidor y los metadatos.
10.En este momento, Ntdsutil confirma que el controlador de dominio se quitó correctamente. 
 Si recibe un mensaje de error que indica que no se encuentra el objeto, es posible que el controlador de dominio se haya quitado anteriormente.
11.Escribe quit para salir.


Referencias: 
 https://docs.microsoft.com/es-es/windows-server/identity/ad-ds/deploy/ad-ds-metadata-cleanup
 https://docs.microsoft.com/es-es/windows-server/identity/ad-ds/deploy/demoting-domain-controllers-and-domains--level-200-
