$subdominio =Read-Host "Introduce el subdominio: "
$dominio =Read-Host "Introduce el dominio sin el sufijo: "
$sufijo =Read-Host "Introduce el sufijo"

$dc="dc="+$subdominio+",dc="+$dominio+",dc="+$sufijo

if (!(Get-Module -Name ActiveDirectory)) #AccederÃ¡ al then solo si no existe una entrada llamada ActiveDirectory
{
  Import-Module ActiveDirectory #Se carga el mÃ³dulo
}

function CrearUsuarios{
    
    $fichero_csv=Read-Host "Introduce el fichero csv de los usuarios:"


    $fichero_csv_importado = import-csv -Path $fichero_csv -Delimiter : 			     
    foreach($linea_leida in $fichero_csv_importado)
    {
        $rutaContenedor =$linea_leida.Path+","+$dc 
        
        $passAccount=ConvertTo-SecureString $linea_leida.Password -AsPlainText -force
        
        $name=$linea_leida.Name
        $nameShort=$linea_leida.Name+'.'+$linea_leida.Surname1
        $Surnames=$linea_leida.Surname1+' '+$linea_leida.Surname2
        $nameLarge=$linea_leida.Name+' '+$linea_leida.Surname1+' '+$linea_leida.Surname2
    
    
        if (Get-ADUser -filter { name -eq $nameShort })
        {
            $nameShort=$linea_leida.Name+'.'+$linea_leida.Surname1+"."+$linea_leida.Surname2
        }
        
        [boolean]$Habilitado=$true
        If($linea_leida.Enabled -Match 'false') { $Habilitado=$false}
    
        $ExpirationAccount = $linea_leida.TurnPassDays
        $timeExp = (get-date).AddDays($ExpirationAccount)
        
        

        New-ADUser `
                -SamAccountName $nameShort `
                -UserPrincipalName $nameShort `
                -Name $nameShort `
                -Surname $Surnames `
                -DisplayName $nameLarge `
                -GivenName $name `
                -LogonWorkstations:$linea_leida.Computer `
                -Description "Cuenta de $nameLarge" `
                -EmailAddress $linea_leida.email `
                -AccountPassword $passAccount `
                -Enabled $Habilitado `
                -Department $linea_leida.Department `
                -Organization $linea_leida.Delegation `
                -CannotChangePassword $false `
                -ChangePasswordAtLogon $true `
                -PasswordNotRequired $false `
                -Path $rutaContenedor `
                -AccountExpirationDate $timeExp `

                Write-Host "Se ha creado el usuario :"+ $nameShort
        
            foreach($group in $linea_leida.Groups.Split(",")){
                
                Add-ADGroupMember -Identity $group -Members $nameShort

            }
            
        
        
        Import-Module .\SetADUserLogonTime.psm1
        Set-OSCLogonHours -SamAccountName $nameShort -DayofWeek Monday,Tuesday,Wednesday,Thursday,Friday -From $linea_leida.ScheduleFrom -To $linea_leida.ScheduleTo
    }
}

function CrearGrupos{
    
    $fichero_csv=Read-Host "Introduce el fichero para crear los grupos"

    $fichero_csv_importado = import-csv -Path $fichero_csv -Delimiter :
                    
    foreach($linea_leida in $fichero_csv_importado)
    {

    #if (Get-ADGroup -filter { name -eq $nameShort })
        #{
        #	Write-Host "a"
        #}

        $rutaContenedor =$linea_leida.Path+","+$dc
        $Name=$linea_leida.Name



        if (!(Get-ADGroup -filter { name -eq $Name })) {

            Write-Host "Se ha creado el grupo: "+$Name
            New-ADGroup -Name:$Name `
            -GroupCategory $linea_leida.Category `
            -GroupScope $linea_leida.Scope `
            -Path:$rutaContenedor
        
        }
    }
}

function CrearEquipos{

    $fichero_csv=Read-Host "Introduce el fichero csv de los Equipos:"

    $fichero_csv_importado = import-csv -Path $fichero_csv -Delimiter : 			     
    foreach($linea_leida in $fichero_csv_importado)
    {
        $rutaContenedor =$linea_leida.Path+","+$dc

        $Name = $linea_leida.Name | Out-String -Stream

        New-ADComputer -Enabled:$true -Name:$Name -Path:$rutaContenedor -SamAccountName:$linea_leida.Name
        Write-Host "Se ha creado el equipo: "+$Name
    }
}

function CrearUOs{
    $fichero_csv=Read-Host "Introduce el fichero csv de las UO:"

    $fichero_csv_importado = import-csv -Path $fichero_csv -Delimiter : 			     
    foreach($linea_leida in $fichero_csv_importado)
    {
        $rutaContenedor=$dc
        if($linea_leida.Path -ne ""){$rutaContenedor =$linea_leida.Path+","+$dc}
        
        Write-Host "Se ha creado la UO: " $linea_leida.Name
        New-ADOrganizationalUnit -Name:$linea_leida.Name -Path:$rutaContenedor

    }

}

function DeleteAll{

    $Path = Read-Host "Introduce la ruta de la UO a eliminar"
    $Path = $Path +","+ $dc

    Set-ADOrganizationalUnit -Identity $Path -ProtectedFromAccidentalDeletion $false
    Remove-ADOrganizationalUnit -Identity $Path -Recursive

}

function CrearUOIndividual{

    $Name = Read-Host "Introduce el nombre de la UO a crear"
    $Path = Read-Host "Introduce la ruta de la UO sin el Dominio"

    $rutaContenedor = $dc
    if($Path -ne ""){$rutaContenedor =$Path+","+$dc}

    New-ADOrganizationalUnit `
    -Name $Name `
    -Path $rutaContenedor


}

function CrearGrupoIndividual{

    $Name = Read-Host "Introduce el nombre del Grupo a crear"
    
    if (!(Get-ADGroup -filter { name -eq $Name })) {

        $Category = Read-Host "Introdce el tipo de grupo(Security/Distibution)" 
        $Scope = Read-Host "Introduce la categoria del grupo"
        $Path = Read-Host "Introduce la ruta del Grupo sin el Dominio" 

        $Path = $Path +","+ $dc

        New-ADGroup `
        -Name $Name `
        -GroupCategory $Category  `
        -GroupScope $Scope `
        -Path $Path
    }

}

function CrearEquipoIndividual{

    $Name = Read-Host "Introduce el nombre del Equipo a crear"
    
    if (!(Get-ADComputer -filter { name -eq $Name })) {

        $Path = Read-Host "Introduce la ruta del Grupo sin el Dominio"

        $Path = $Path +","+ $dc

        New-ADComputer `
        -Name $Name `
        -Enabled $true `
        -SamAccountName:$Name `
        -Path $Path
    }

}

function CrearUsuarioIndividual{

    $Name = Read-Host "Introduce el nombre del Usuario a crear"
    $Surname = Read-Host "Introduce el apellido del Usuario a crear"
    $Surname2 = Read-Host "Introduce el segundo apellido del Usuario a crear"
    
    $nameShort=$Name+'.'+$Surname


    if (Get-ADUser -filter { name -eq $nameShort }){
		$nameShort=$Name+'.'+$Surname+"."+$Surname2
	}

    if (!(Get-ADUser -filter { name -eq $nameShort })) {
        
        $Surnames=$Surname+' '+$Surname2
        $nameLarge=$Name+' '+$Surname+' '+$Surname2

        $Computer = Read-Host "Introduce el ordenador de este usuario"
        $Pass = Read-Host "Introduce la pass del Usuario"
        $Pass = $passAccount=ConvertTo-SecureString -AsPlainText -force 
        
        $Departament = Read-Host "Introduce el Departamento del Usuario" 
        $Organization = Read-Host "Introduce el Departamento la Organizacion"

        $Path = Read-Host "Introduce la ruta del Usuario"
        $Path = $Path +","+ $dc

        $timeExp = Read-Host "Introduce en cuantos dias se cadicara la pass"
        $timeExp = (get-date).AddDays($timeExp )

        New-ADUser `
    		-SamAccountName $nameShort `
   	 	    -UserPrincipalName $nameShort `
    		-Name $nameShort `
		    -Surname $Surnames `
    		-DisplayName $nameLarge `
    		-GivenName $Name `
    		-LogonWorkstations $Computer `
		    -Description "Cuenta de $nameLarge" `
		    -AccountPassword $Pass `
    		-Enabled $Habilitado `
			-Department $Departament `
			-Organization $Organization `
		    -CannotChangePassword $false `
    		-ChangePasswordAtLogon $true `
		    -PasswordNotRequired $false `
    		-Path $Path `
    		-AccountExpirationDate $timeExp
    
    }

}

function BuscarEquipo{

    $Name = Read-Host "Introduce el nombre del Equipo a buscar"
    
    dsquery Computer -name $Name

}

function BuscarUsuario{

    $Name = Read-Host "Introduce el nombre del Usuario a buscar"
    
    dsquery user -name $Name

}

function BuscarGrupo{

    $Name = Read-Host "Introduce el nombre del Grupo a buscar"
    
    dsquery group -name $Name

}

function EliminarUOIndividual{

    #$Name = Read-Host "Introduce el nombre de la UO a crear"
    $Path = Read-Host "Introduce la ruta de la UO a eliminar sin el Dominio"

    $rutaContenedor = $dc
    if($Path -ne ""){$rutaContenedor =$Path+","+$dc}


    Set-ADOrganizationalUnit -Identity $rutaContenedor -ProtectedFromAccidentalDeletion $false
    Remove-ADOrganizationalUnit -Identity $rutaContenedor -Recursive


}

function EliminarGrupoIndividual{

    $Name = Read-Host "Introduce el nombre del Grupo a eliminar"
    
    Remove-ADGroup -Identity $Name

}

function EliminarEquipoIndividual{

    $Name = Read-Host "Introduce el nombre del Equipo a eliminar"
    
    Remove-ADComputer -Identity $Name

}

function EliminarUsuarioIndividual{

    $nameShort = Read-Host "Introduce el nombre del usuario a eliminar"

    Remove-ADUser -Identity $nameShort

}


function Submenu_GestDep
{
    param (
        [string]$Titulo = 'Submenu.....'
    )
    Clear-Host 
    Write-Host "================ $ Submenu Gestion Objetos dominio principal================"
    
    Write-Host "1: Crear todas las UOs de los departamentos"
    Write-Host "2: Crear Grupos"
    Write-Host "3: Crear Equipos"
    Write-Host "4: Crear Usuarios"
    Write-Host "5: Eliminar todo"
    Write-Host "s: Ir al menu principal"
    do
    {
    $Option = Read-Host "Por favor, introduzca una opcion"
    switch ($Option)
    {
            '1' {
                #Creacion de UOs
                Clear-Host
                CrearUOs
                
                return
            } '2' {
                #Creacion de Grupos   
                Clear-Host
                CrearGrupos
                return
            } '3' {
               #Creacion de Equipos'
               Clear-Host
               CrearEquipos
                return
            } '4' {
               #Creacion de Usuarios'
               Clear-Host
               CrearUsuarios
                return
            } '5' {
               #Creacion de Usuarios'
               Clear-Host
               DeleteAll
                return
            } 's' {
                Clear-Host
                #Vuelta al menu principal'
                mostrarMenu
            break
            }

        }           
    }
until ($Option -eq 'q')
}


function Submenu_Find
{
    param (
        [string]$Titulo = 'Submenu.....'
    )
    Clear-Host 
    Write-Host "================ $ Submenu Gestion Objetos dominio principal================"
    
    Write-Host "1: Buscar Grupo"
    Write-Host "2: Buscar Equipo"
    Write-Host "3: Buscar Usuario"
    Write-Host "s: Ir al menu principal"
    do
    {
    $Option = Read-Host "Por favor, introduzca una opcion"
    switch ($Option)
    {
            '1' {
                #Creacion de UOs
                Clear-Host
                BuscarGrupo
                
                return
            } '2' {
                #Creacion de Grupos   
                Clear-Host
                BuscarEquipo
                return
            } '3' {
               #Creacion de Equipos'
               Clear-Host
               BuscarUsuario
                return
            } 's' {
                Clear-Host
                #Vuelta al menu principal'
                mostrarMenu
            break
            }

        }           
    }
until ($Option -eq 'q')
}



function Submenu_CreateInd
{
    
    param (
           [string]$Titulo = 'Submenu.....'
    )
    Clear-Host 
    Write-Host "================ $ Submenu Gestion de objetos individuales================"
    
    Write-Host "1: Crear Usuario"
    Write-Host "2: Crear Grupos"
    Write-Host "3: Crear UO"
    Write-Host "4: Crear Equipo"
    Write-Host "s: Ir al menu principal"
    do
    {
    $Option = Read-Host "Por favor, introduzca una opcion"
    switch ($Option)
    {
            '1' {
                #Creacion plantillas
                Clear-Host
                CrearUsuarioIndividual
                Write-Host "Se han creado las plantillas con exito"
                return
            } '2' {
                #Listar plantillas   
                Clear-Host
               CrearGrupoIndividual
                
                return
            } '3' {
               #Eliminar plantillas

                Clear-Host
                CrearUOIndividual
                return
            } '4' {
               #Eliminar plantillas

                Clear-Host
                CrearEquipoIndividual
                return
            } 's' {
                Clear-Host
                #Vuelta al menu principal
                mostrarMenu
                break
            }

        }           
    }
    until ($Option -eq 'q')
}


function Submenu_RemoveInd
{
    
    param (
           [string]$Titulo = 'Submenu.....'
    )
    Clear-Host 
    Write-Host "================ $ Submenu Gestion de objetos individuales================"
    
    Write-Host "1: Eliminar Usuario"
    Write-Host "2: Eliminar Grupos"
    Write-Host "3: Eliminar UO"
    Write-Host "4: Eliminar Equipo"
    Write-Host "s: Ir al menu principal"
    do
    {
    $Option = Read-Host "Por favor, introduzca una opcion"
    switch ($Option)
    {
            '1' {
                #Creacion plantillas
                Clear-Host
                EliminarUsuarioIndividual
                return
            } '2' {
                #Listar plantillas   
                Clear-Host
                EliminarGrupoIndividual
                
                return
            } '3' {
               #Eliminar plantillas

                Clear-Host
                EliminarUOIndividual
                return
            } '4' {
               #Eliminar plantillas

                Clear-Host
                EliminarEquipoIndividual
                return
            } 's' {
                Clear-Host
                #Vuelta al menu principal
                mostrarMenu
                break
            }

        }           
    }
    until ($Option -eq 'q')
}




function Submenu_RemoveInd
{
    
    param (
           [string]$Titulo = 'Submenu.....'
    )
    Clear-Host 
    Write-Host "================ $ Submenu Gestion de objetos individuales================"
    
    Write-Host "1: Eliminar Usuario"
    Write-Host "2: Eliminar Grupos"
    Write-Host "3: Eliminar UO"
    Write-Host "4: Eliminar Equipo"
    Write-Host "s: Ir al menu principal"
    do
    {
    $Option = Read-Host "Por favor, introduzca una opcion"
    switch ($Option)
    {
            '1' {
                #Creacion plantillas
                Clear-Host
                EliminarUsuarioIndividual
                return
            } '2' {
                #Listar plantillas   
                Clear-Host
                EliminarGrupoIndividual
                
                return
            } '3' {
               #Eliminar plantillas

                Clear-Host
                EliminarUOIndividual
                return
            } '4' {
               #Eliminar plantillas

                Clear-Host
                EliminarEquipoIndividual
                return
            } 's' {
                Clear-Host
                #Vuelta al menu principal
                mostrarMenu
                break
            }

        }           
    }
    until ($Option -eq 'q')
}
function mostrarMenu 
{ 
    do 
    {
        param ( 
        [string]$Titulo = 'Menu principal -Fase3' 
        ) 
        Clear-Host 
        Write-Host "================ $ Menu principal - Fase 3================" 
        
        
        Write-Host "1. Gestion de Objetos de los departamentos" 
        Write-Host "2. Crear objetos individuales"
        Write-Host "3. Eliminar objetos individuales"
        Write-Host "4. Buscar objetos"
        Write-Host "s. Presiona 's' para salir"
            $Option = Read-Host "Elegir una Opción" 
        switch ($Option) 
        { 
                '1' { 
                Clear-Host  
                Submenu_GestDep               
                pause
                } '2' { 
                Clear-Host  
                Submenu_CreateInd
                pause
            
                } '3' { 
                Clear-Host    
                Submenu_RemoveInd
                pause
            
                } '4' { 
                Clear-Host  
                Submenu_Find
                pause
            
                } 's' {
                    Clear-Host
                    #Saliendo del script...'
                    break 
                }  
        } 
        
    }until ($Option -eq 's')
}


mostrarMenu
pause
