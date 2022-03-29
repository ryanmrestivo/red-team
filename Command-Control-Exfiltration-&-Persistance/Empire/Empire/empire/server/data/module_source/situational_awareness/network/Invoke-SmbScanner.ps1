function Invoke-SMBScanner {
<#
.SYNOPSIS

    Tests a username/password combination across a number of machines.
    If no machines are specified, the domain will be queries for active machines.
    For domain accounts, use the form DOMAIN\username for username specifications.

    Author: Chris Campbell (@obscuresec), mods by @harmj0y, more mods by @kevin
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None
    Version: 0.1.1
 
.DESCRIPTION

    Tests a username/password combination across a number of machines.
    If no machines are specified, the domain will be queries for active machines.
    For domain accounts, specify a domain to query 

.EXAMPLE

    PS C:\> Invoke-SMBScanner -Domain 'Borgar.local' -ComputerName DC01 -Usernames 'kclark','Administrator','SQLSvc' -Password 'P@ssw0rd'
    
    ComputerName Domain       Username      Password Valid
    ------------ ------       --------      -------- -----
    DC01         Borgar.local kclark        P@ssw0rd False
    DC01         Borgar.local Administrator P@ssw0rd True
    DC01         Borgar.local SQLSvc        P@ssw0rd False


    PS C:\> Invoke-SMBScanner -ComputerName '127.0.0.1' -Usernames 'kclark','Administrator','localadmin' -Password 'P@sssw0rd'
    
    ComputerName Domain Username      Password  Valid
    ------------ ------ --------      --------  -----
    127.0.0.1    <None> kclark        P@sssw0rd False
    127.0.0.1    <None> Administrator P@sssw0rd False
    127.0.0.1    <None> localadmin    P@sssw0rd True

#>
    
    [CmdletBinding()] Param(
        [Parameter(Mandatory = $False,ValueFromPipeline=$True)]
        [String[]] $ComputerName,

        [parameter(Mandatory = $True)]
        [String[]] $Usernames,

        [parameter(Mandatory = $True)]
        [String] $Password,
		
        [parameter(Mandatory = $False)]
        [String] $Domain,

        [parameter(Mandatory = $False)]
        [Switch] $NoPing
    )

    Begin {
        Set-StrictMode -Version 2
        [Collections.ArrayList]$OutList = @()
        #try to load assembly
        Try {Add-Type -AssemblyName System.DirectoryServices.AccountManagement}
        Catch {Write-Error $Error[0].ToString() + $Error[0].InvocationInfo.PositionMessage}
    }

    Process {
        $ComputerNames = @()

        # if no computer names are specified, try to query the current domain
        if(-not $ComputerName){
            Write-Verbose "Querying the domain for active machines."
            "Querying the domain for active machines."

            $ComputerNames = [array] ([adsisearcher]'objectCategory=Computer').Findall() | ForEach {$_.properties.cn}

            Write-Verbose "Retrived $($ComputerNames.Length) systems from the domain."
        }
        else {
            $ComputerNames = @($ComputerName)
        }

        foreach ($Computer in $ComputerNames){     
            try {
                
                Write-Verbose "Checking: $Computer"

                $up = $true
                if(-not $NoPing){
                    $up = Test-Connection -count 1 -Quiet -ComputerName $Computer 
                }
                if($up){

                    if ($Domain) {
                        $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
                    }
                    else{
                        # otherwise assume a local account
                        $Domain = "<None>"
                        $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Machine
                    }
                
                    foreach($Username in $Usernames) {
                        $PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext($ContextType, $Computer)
                        $Valid = $PrincipalContext.ValidateCredentials($Username, $Password).ToString()           

                        $out = new-object psobject
                        $out | add-member Noteproperty 'ComputerName' $Computer
                        $out | add-member Noteproperty 'Domain' $Domain
                        $out | add-member Noteproperty 'Username' $Username
                        $out | add-member Noteproperty 'Password' $Password
                        $out | add-member Noteproperty 'Valid' $Valid
                        $null = $OutList.Add($out)
                    }
                }
            }
            catch {
                Write-Error $($Error[0].ToString() + $Error[0].InvocationInfo.PositionMessage)
            }
        }
    }
    End {
        $OutList | Format-Table
        Write-Output "SMBScanner execution completed"
    }
}
