#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 

#requires -Version 2.0

#Check if ActiveDirectory module is imported.
If(-not(Get-Module -Name ActiveDirectory))
{
    Import-Module -Name ActiveDirectory
}

Function Set-OSCLogonHours
{
<#
 	.SYNOPSIS
        Set-OSCLogonHours is an advanced function which can be used to set active directory user's logon time.
    .DESCRIPTION
        Set-OSCLogonHours is an advanced function which can be used to set active directory user's logon time.
    .PARAMETER  SamAccountName
        Specifies the SamAccountName
    .PARAMETER  CsvFilePath
		Specifies the path you want to import csv files.
    .PARAMETER  DayofWeek
		Specifies the day of the week.
    .PARAMETER  From
		Specifies a start time.
    .PARAMETER  To
		Specifies an end time.
    .EXAMPLE
        C:\PS> Set-OSCLogonHours -SamAccountName doris,katrina -DayofWeek Monday,Saturday -From 6AM -To 7PM
        Successfully set user 'doris' logon time.
        Successfully set user 'katrina' logon time.
		This command will set user's logon time attributes.
    .EXAMPLE
        C:\PS> Set-OSCLogonHours -CsvFilePath C:\Script\SamAccountName.csv -DayofWeek Wednesday,Friday -From 7AM -To 8PM
        
        Successfully set user 'doris' logon time.
        Successfully set user 'katrina' logon time.
		This command will set user's logon time attributes based on imported user list.
#>
    [CmdletBinding(DefaultParameterSetName = 'SamAccountName')]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='SamAccountName')]
        [Alias('sam')][String[]]$SamAccountName,

        [Parameter(Mandatory=$true,Position=0,ParameterSetName='CsvFilePath')]
        [Alias('')][String]$CsvFilePath,

        [Parameter(Mandatory=$true,Position=1)]
        [ValidateSet("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")]
        [Alias('day')][String[]]$DayofWeek,

        [Parameter(Mandatory=$true,Position=2)]
        [ValidateSet("12AM","1AM","2AM","3AM","4AM","5AM","6AM","7AM","8AM","9AM","10AM",
        "11AM","12PM","1PM","2PM","3PM","4PM","5PM","6PM","7PM","8PM","9PM","10PM","11PM")]
        [Alias('f')][String]$From,

        [Parameter(Mandatory=$true,Position=3)]
        [ValidateSet("12AM","1AM","2AM","3AM","4AM","5AM","6AM","7AM","8AM","9AM","10AM",
        "11AM","12PM","1PM","2PM","3PM","4PM","5PM","6PM","7PM","8PM","9PM","10PM","11PM")]
        [Alias('t')][String]$To
    )

    
    #Define a custom 24-hours hashtable
    $Objs = @()
    Foreach($i in 1..24)
    {
        $Obj = New-Object -TypeName PSObject
        $Obj | Add-Member -MemberType NoteProperty -Name "12Hours" -Value $(If($i -le 11)
        {"$($i)AM"}Else{If($i -eq 12){"12PM"}ElseIf($i -eq 24){"12AM"}Else{"$($i-12)PM"}})
        $Obj | Add-Member -MemberType NoteProperty -Name "24Hours" -Value $i

        $Objs += $Obj
    }
   
    #The 12-hours will be convert into 24-hours type.
    $HrsFrom = $Objs | Where{$_."12Hours" -eq $From} | Select-Object -ExpandProperty "24Hours"
    $HrsTo = $Objs | Where{$_."12Hours" -eq $To} | Select-Object -ExpandProperty "24Hours"

    If($HrsFrom -le $HrsTo)
    {
       #Define 3 time binary blocks
       $HoursBlock1 = @{"12AM"=1; "1AM"=2; "2AM"=4; "3AM"=8; "4AM"=16; "5AM"=32; "6AM"=64; "7AM"=128}
       $HoursBlock2 = @{"8AM"=1; "9AM"=2; "10AM"=4; "11AM"=8; "12PM"=16; "1PM"=32; "2PM"=64; "3PM"=128}
       $HoursBlock3 = @{"4PM"=1; "5PM"=2; "6PM"=4; "7PM"=8; "8PM"=16; "9PM"=32; "10PM"=64; "11PM"=128}

       #Initialize multiple values to multiple variables.
       $HourBinary1,$HourBinary2,$HourBinary3 = 0,0,0

       $TimePeriod = $HrsFrom..$($HrsTo-1)
       Foreach($Time in $TimePeriod)
       {
            #The 24-hours will be convert into 12-hours type.
            $Hour = $Objs | Where{$_."24Hours" -eq $Time} | Select-Object -ExpandProperty "12Hours"  

            If($HoursBlock1.ContainsKey($Hour))
            {
                $HourBinary1 += $HoursBlock1.$Hour
            }
            If($HoursBlock2.ContainsKey($Hour))
            {
                $HourBinary2 += $HoursBlock2.$Hour
            }
            If($HoursBlock3.ContainsKey($Hour))
            {
                $HourBinary3 += $HoursBlock3.$Hour
            }
        }
            
        #Define Initial logon time
        $HourBinary = 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

        #Iterating replace the specified value
        Foreach($day in $DayofWeek)
        {
            Switch($day)
            {
                "Sunday" {$HourBinary[1],$HourBinary[2],$HourBinary[3] = $HourBinary1,$HourBinary2,$HourBinary3;Break}
                "Monday" {$HourBinary[4],$HourBinary[5],$HourBinary[6] = $HourBinary1,$HourBinary2,$HourBinary3;Break}
                "Tuesday" {$HourBinary[7],$HourBinary[8],$HourBinary[9] = $HourBinary1,$HourBinary2,$HourBinary3;Break}
                "Wednesday" {$HourBinary[10],$HourBinary[11],$HourBinary[12] = $HourBinary1,$HourBinary2,$HourBinary3;Break}
                "Thursday" {$HourBinary[13],$HourBinary[14],$HourBinary[15] = $HourBinary1,$HourBinary2,$HourBinary3;Break}
                "Friday" {$HourBinary[16],$HourBinary[17],$HourBinary[18] = $HourBinary1,$HourBinary2,$HourBinary3;Break}
                "Saturday" {$HourBinary[19],$HourBinary[20],$HourBinary[0] = $HourBinary1,$HourBinary2,$HourBinary3;Break}
            }
        }
    
        #Assign logon binary value to 'Logonhours' attribute.
        If($SamAccountName)
        {
            Foreach($User in $SamAccountName)
            {
                Get-ADUser -Identity $User | Set-ADUser -Replace @{Logonhours = [Byte[]]$HourBinary}
                Write-Host "Successfully set user '$User' logon time."
            }
        }

        If($CsvFilePath)
        {
            If(Test-Path -Path $CsvFilePath)
            {
                #import the csv file and store in a variable
                $Names = (Import-Csv -Path $CsvFilePath).SamAccountName

                Foreach($Name in $Names)
                {
                    Get-ADUser -Identity $Name | Set-ADUser -Replace @{Logonhours = [Byte[]]$HourBinary}
                    Write-Host "Successfully set user '$Name' logon time."
                }
            }
            Else
            {
                Write-Warning "Cannot find path '$CsvFilePath', because it does not exist."
            } 
        }
    }
    Else
    {
        Write-Warning "You enter the wrong time period, please make sure that input correct."
    }
}
