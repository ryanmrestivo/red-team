#requires -version 2

<#
    File: Invoke-FindPersistence.ps1
    Author: Alexander Rymdeko-Harvey(@Killswitch-GUI)
    License: BSD 3-Clause

    Copyright (c) 2016, Alexander Rymdeko-Harvey 
    All rights reserved. 

    Redistribution and use in source and binary forms, with or without 
    modification, are permitted provided that the following conditions are met: 

     * Redistributions of source code must retain the above copyright notice, 
       this list of conditions and the following disclaimer. 
     * Redistributions in binary form must reproduce the above copyright 
       notice, this list of conditions and the following disclaimer in the 
       documentation and/or other materials provided with the distribution. 
     * Neither the name of  nor the names of its contributors may be used to 
       endorse or promote products derived from this software without specific 
       prior written permission. 

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
    ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
    LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
#>

<#
    PowerSploit File: PowerView.ps1
    Functions Used:  Get-NetComputer, Convert-LDAPProperty, Get-NetDomain 
    Author: Will Schroeder (@harmj0y)
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None
#>

<#
Test Weighted values and their max 
coresponding values. All have the max
values of 100 int.

Keep in mind all values are relational to the 
highest and lowest values which is why we 
will caculate the Stnadard deviation. This
will help us identify unique points in the
network with ease. 

1) WmiBootTime = %40 WA
    # in months:
    - .25 = 30
    - .5 = 40
    - 1 = 60
    - 2 = 75
    - 3 = 85
    - 4 = 90
    - 5 = 95
    - 6 = 100
2) WmiOS = %10
4) WmiServer = %10
3) WmiInstallDate = %5
    - Bellow 6 months = 20
    - Bellow 1 years = 40
    - Bellow 2 years = 80
    - Bellow 3 years =  100
5) WmiArch = %2
    - 32 bit = 50
    - 64 bit = 100
6) WmiSuite = %5
7) WmiDisk = %2
8) WmiLPorcCount = %5
    -
9) WmiPorcCores = %2
    - 
10) WmiProcSpeed = %2
    - 1500 = 20 I3
    - 2000 = 40 I5
    - 2500 = 80 I5
    - 2950 = 100 I7
11) WmiPowerSettign= %5
12) WmiEnlosure = %10
13) WmiPointerDevice = %2
14) WmiLoggedOnUser = %5
    - 0 = 20
    - 1 = 30
    - 2 = 50
    - 3 = 70
    - 4 = 90
    - 5 = 100
15) WmiPorcessCount = %5
    Less than:
    - 7 = 20
    - 9 = 40
    - 10 = 50
    - 12 = 65
    - 15 = 80
    - 18 = 100
16) WmiPatchLevel = 2%
17) WmiSystemEnclosure = %10
18) WmiCollectorService = %5
19) WmiRamSize = %5
    in GB:
    - 1 = 20
    - 2 = 30
    - 
20) WmiNICData = %5
21) WmiAVQuery %2

Bool Values for sorting
23) WmiPortabelOS
24) WmiVMChecks
25) WmiLogging
#>

######################
# PS Wmi Object Calls#
######################
function Get-WmiOS{
    <#
    .SYNOPSIS
    This function will query the target for its OS wmi object and return this object.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER Targets
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WmiBootTime
    NONE

    .LINK
    NONE
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName
    )

    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName -credential $Credential
                return $Wmi
            }
            catch 
            {
                Write-Warning "[!] Error opening Wmi OS on $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName -credential $Credential
                return $Wmi
            }
            catch 
            {
                Write-Warning "[!] Error opening Wmi OS on $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName
                return $Wmi
            }
            catch 
            {
                Write-Warning "[!] Error opening Wmi OS on $HostName."
            }

        } 
    }
}
####################
# Weighted Average #
####################

function Get-WmiBootTime{
    <#
    .SYNOPSIS
    This function will query the target for last boot time in epoch time.

    .DESCRIPTION
    This function will query the target for last boot time in epoch time.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER WmiOS
    Pass the OS Wmi on the CLI to enhance speed / remote calls.

    .PARAMETER Targets
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WmiBootTime
    NONE

    .LINK
    NONE
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName,

        [Parameter(ValueFromPipeline=$True)]
        $WmiOS
    )

    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                if ($WmiOS){
                    $LastBoot = $WmiOS.LastBootUpTime
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName -credential $Credential
                    $LastBoot = $Wmi.LastBootUpTime
                }
                return $LastBoot
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                if ($WmiOS){
                    $LastBoot = $WmiOS.LastBootUpTime
                }
                else{
                     $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName -credential $Credential
                    $LastBoot = $Wmi.LastBootUpTime
                }
                return $LastBoot
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context             
                if ($WmiOS){
                    $LastBoot = $WmiOS.LastBootUpTime
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName   
                    $LastBoot = $Wmi.LastBootUpTime
                }
                return $LastBoot
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }

        } 
    }
}
function Get-WmiInstallDate{
    <#
    .SYNOPSIS
    This function will query the target for install date of OS.

    .DESCRIPTION
    Date object was installed. This property does not require a value to indicate that the object is installed.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER WmiOS
    Pass the OS Wmi on the CLI to enhance speed / remote calls.

    .PARAMETER Targets
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WmiBootTime
    NONE

    .LINK
    NONE
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName,

        [Parameter(ValueFromPipeline=$True)]
        $WmiOS
    )

    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                if ($WmiOS){
                    $InstallDate = $WmiOS.InstallDate
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName -credential $Credential
                    $InstallDate = $Wmi.InstallDate
                }
                return $InstallDate
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                if ($WmiOS){
                    $InstallDate = $WmiOS.InstallDate
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName -credential $Credential
                    $InstallDate = $Wmi.InstallDate
                }
                return $InstallDate
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context
                if ($WmiOS){
                    $InstallDate = $WmiOS.InstallDate
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName
                    $InstallDate = $Wmi.InstallDate
                }
                return $InstallDate
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }

        } 
    }
}
function Get-WmiOS{
    <#
    .SYNOPSIS
    This function will query the target for the current OS level.

    .DESCRIPTION
    This function will query the target for the current OS level. This will use the current verison a build number to indicate the highest
    windows version. This can help us determine the newest verison of windows we want. We can also apply filters to this value.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER Targets
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WmiOS
    NONE

    .LINK
    NONE
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName
    )
}
function Get-WmiServer{
    <#
    .SYNOPSIS
    This function will query the product type of the OS at a basic level.

    .DESCRIPTION
    Additional system information on the product type.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER WmiOS
    Pass the OS Wmi on the CLI to enhance speed / remote calls.

    .PARAMETER Targets
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WmiBootTime
    NONE

    .LINK
    NONE
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName,

        [Parameter(ValueFromPipeline=$True)]
        $WmiOS
    )

    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                if ($WmiOS){
                    $ProductType = $WmiOS.ProductType
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName -credential $Credential
                    $ProductType = $Wmi.ProductType
                }
                return $ProductType
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # Server Types
            # Work Station (1)
            # Domain Controller (2)
            # Server (3)
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                if ($WmiOS){
                    $ProductType = $WmiOS.ProductType
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName -credential $Credential
                    $ProductType = $Wmi.ProductType
                }
                return $ProductType
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context
                if ($WmiOS){
                    $ProductType = $WmiOS.ProductType
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName
                    $ProductType = $Wmi.ProductType
                }
                return $ProductType
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }

        } 
    }
}
function Get-WmiRamSize{
    <#
    .SYNOPSIS
    Total capacity of the physical memory in bytes.

    .DESCRIPTION
    This value comes from the Memory Device structure in the SMBIOS version information. 
    For SMBIOS versions 2.1 thru 2.6 the value comes from the Size member. 
    For SMBIOS version 2.7+ the value comes from the Extended Size member.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER HostName
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WmiRamSize
    NONE

    .LINK
    https://msdn.microsoft.com/en-us/library/aa394373(v=vs.85).aspx
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName
    )

    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                $Capacity = 0
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_PhysicalMemory -computername $HostName -credential $Credential | %{$Capacity = $_.Capacity / 1GB + $Capacity}
                return $Capacity
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                $Capacity = 0
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_PhysicalMemory -computername $HostName -credential $Credential | %{$Capacity = $_.Capacity / 1GB + $Capacity}
                return $Capacity
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                $Capacity = 0
                # execute in current user context
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_PhysicalMemory -computername $HostName | %{$Capacity = $_.Capacity / 1GB + $Capacity}
                return $Capacity
            }
            catch 
            {
                Write-Warning "[!] Error opening Ram Size time one $HostName."
            }

        } 
    }
}
function Get-WmiArch{
    <#
    .SYNOPSIS
    This function will query the target for its OS arch.

    .DESCRIPTION
    Architecture of the operating system, as opposed to the processor. This property can be localized.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER WmiOS
    Pass the OS Wmi obj on the CLI to enhance speed / remote calls.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER HostName
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WmiArch
    NONE

    .LINK
    NONE
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName,

        [Parameter(ValueFromPipeline=$True)]
        $WmiOS

    )

    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                if ($WmiOS){
                    $OSArchitecture = $WmiOS.OSArchitecture
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName -credential $Credential
                    $OSArchitecture = $Wmi.OSArchitecture
                }
                return $OSArchitecture
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                if ($WmiOS){
                    $OSArchitecture = $WmiOS.OSArchitecture
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName -credential $Credential
                    $OSArchitecture = $Wmi.OSArchitecture
                }
                return $OSArchitecture
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context
                if ($WmiOS){
                    $OSArchitecture = $WmiOS.OSArchitecture
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName
                    $OSArchitecture = $Wmi.OSArchitecture
                }
                return $OSArchitecture
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }

        } 
    }
}
function Get-WMiDisk{
    <#
    .SYNOPSIS
    This function will query the target for its free space on the disk count.

    .DESCRIPTION
    Space, in bytes, available on the logical disk. returns the space size in GB.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER HostName
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WMiDisk
    NONE

    .LINK
    https://msdn.microsoft.com/en-us/library/aa394173(v=vs.85).aspx
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName
    )
    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                $TotalSpace = 0
                Get-WmiObject -Namespace "root\cimv2" -Class Win32_LogicalDisk -computername $HostName -credential $Credential | %{$TotalSpace = $_.freespace / 1GB + $TotalSpace}
                return $TotalSpace
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                $TotalSpace = 0
                Get-WmiObject -Namespace "root\cimv2" -Class Win32_LogicalDisk -computername $HostName -credential $Credential | %{$TotalSpace = $_.freespace / 1GB + $TotalSpace}
                return $TotalSpace
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context
                $TotalSpace = 0
                Get-WmiObject -Namespace "root\cimv2" -Class Win32_LogicalDisk -computername $HostName | %{$TotalSpace = $_.freespace / 1GB + $TotalSpace}
                return $TotalSpace
            }
            catch 
            {
                Write-Warning "[!] Error opening Disk Size on $HostName."
            }

        } 
    }
}
function Get-WmiLProcessorCount{
    <#
    .SYNOPSIS
    This function will query the target for its Number Of Logical Processors count.

    .DESCRIPTION
    Number of logical processors for the current instance of the processor. 
    For processors capable of hyperthreading, this value includes only the processors which have hyperthreading enabled.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER HostName
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WmiLProcessorCount
    NONE

    .LINK
    https://msdn.microsoft.com/en-us/library/aa394373(v=vs.85).aspx
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName
    )

    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_Processor -computername $HostName -credential $Credential
                $NumberOfLogicalProcessors = $Wmi.NumberOfLogicalProcessors
                return $NumberOfLogicalProcessors
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_Processor -computername $HostName -credential $Credential
                $NumberOfLogicalProcessors = $Wmi.NumberOfLogicalProcessors
                return $NumberOfLogicalProcessors
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_Processor -computername $HostName
                $NumberOfLogicalProcessors = $Wmi.NumberOfLogicalProcessors
                return $NumberOfLogicalProcessors
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }

        } 
    }
}
function Get-WmiProcessorCores{
    <#
    .SYNOPSIS
    This function will query the target for its Number Of Processors Cores.

    .DESCRIPTION
    Number of cores for the current instance of the processor. 
    A core is a physical processor on the integrated circuit. 
    For example, in a dual-core processor this property has a value of 2. 

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER HostName
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WmiLProcessorCount
    NONE

    .LINK
    https://msdn.microsoft.com/en-us/library/aa394373(v=vs.85).aspx
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName
    )

    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_Processor -computername $HostName -credential $Credential
                $NumberOfCores = $Wmi.NumberOfCores
                return $NumberOfCores
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_Processor -computername $HostName -credential $Credential
                $NumberOfCores = $Wmi.NumberOfCores
                return $NumberOfCores
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_Processor -computername $HostName
                $NumberOfCores = $Wmi.NumberOfCores
                return $NumberOfCores
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }

        } 
    }
}
function Get-WmiProcessorSpeed{
    <#
    .SYNOPSIS
    This function will query the target for Maximum speed of the processor, in MHz.

    .DESCRIPTION
    This value comes from the Max Speed member of the Processor 
    Information structure in the SMBIOS information.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER HostName
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WmiLProcessorCount
    NONE

    .LINK
    https://msdn.microsoft.com/en-us/library/aa394373(v=vs.85).aspx
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName
    )

    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_Processor -computername $HostName -credential $Credential
                $MaxClockSpeed = $Wmi.MaxClockSpeed
                return $MaxClockSpeed
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_Processor -computername $HostName -credential $Credential
                $MaxClockSpeed = $Wmi.MaxClockSpeed
                return $MaxClockSpeed
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_Processor -computername $HostName
                $MaxClockSpeed = $Wmi.MaxClockSpeed
                return $MaxClockSpeed
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }

        } 
    }
}
function Get-WmiProcessCount{
    <#
    .SYNOPSIS
    This function will query the target for its process count.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER HostName
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WMiDisk
    NONE

    .LINK
    https://msdn.microsoft.com/en-us/library/aa394173(v=vs.85).aspx
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName
    )
    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                $TotalCount = 0
                Get-WmiObject -Namespace "root\cimv2" -Class Win32_Process -computername $HostName -credential $Credential | %{$TotalCount = 1 + $TotalCount}
                return $TotalCount
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                $TotalCount = 0
                Get-WmiObject -Namespace "root\cimv2" -Class Win32_Process -computername $HostName -credential $Credential | %{$TotalCount = 1 + $TotalCount}
                return $TotalCount
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context
                $TotalCount = 0
                Get-WmiObject -Namespace "root\cimv2" -Class Win32_Process -computername $HostName | %{$TotalCount = 1 + $TotalCount}
                return $TotalCount
            }
            catch 
            {
                Write-Warning "[!] Error opening Disk Size on $HostName."
            }

        } 
    }
}
function Get-WmiSystemEnclosure{
    <#
    .SYNOPSIS
    This function will query the target for its $ChassisTypes and return an array.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER HostName
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WMiDisk
    NONE

    .LINK
    https://msdn.microsoft.com/en-us/library/aa394173(v=vs.85).aspx
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName
    )
    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_SystemEnclosure -computername $HostName -credential $Credential
                $ChassisTypes = $Wmi.ChassisTypes
                return $ChassisTypes
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_SystemEnclosure -computername $HostName -credential $Credential 
                $ChassisTypes = $Wmi.ChassisTypes
                return $ChassisTypes
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_SystemEnclosure -computername $HostName
                $ChassisTypes = $Wmi.ChassisTypes
                return $ChassisTypes
            }
            catch 
            {
                Write-Warning "[!] Error opening Disk Size on $HostName."
            }

        } 
    }
}

#function Get-WmiLoggedOnUsers{}
#function Get-WmiCollectorService{}
#function Get-WmiNICData{}
#function Get-WmiAVQuery{}
#function Get-WmiPowerSettings{}
#function Get-WmiOSuite{}
#function Get-WmiPointerDevice{}

####################
#  Boolean Values  #
####################
function Get-WmiPortableOS{
    <#
    .SYNOPSIS
    This function will query the target for its OS portable Bool Values.

    .DESCRIPTION
    Specifies whether the operating system booted from an external USB device. If true, 
    the operating system has detected it is booting on a supported locally connected storage device.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER WmiOS
    Pass the OS Wmi on the CLI to enhance speed / remote calls.

    .PARAMETER Targets
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WmiPortableOS
    NONE

    .LINK
    NONE
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName,

        [Parameter(ValueFromPipeline=$True)]
        $WmiOS
    )

    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                if ($WmiOS){
                    $PortableOS = $Wmi.PortableOperatingSystem
                    return $PortableOS
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName -credential $Credentiall
                    $PortableOS = $Wmi.PortableOperatingSystem
                    return $PortableOS
                }
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                if ($WmiOS){
                    $PortableOS = $Wmi.PortableOperatingSystem
                    return $PortableOS
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName -credential $Credential
                    $PortableOS = $Wmi.PortableOperatingSystem
                    return $PortableOS
                }
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context
                if ($WmiOS){
                    $PortableOS = $Wmi.PortableOperatingSystem
                    return $PortableOS
                }
                else{
                    $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem -computername $HostName
                    $PortableOS = $Wmi.PortableOperatingSystem
                    return $PortableOS
                }
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }

        } 
    }
}
# VM checks are very important as values
# will lie to you! but they have 
# there place in implants
function Get-WmiVMChecks{
    <#
    .SYNOPSIS
    This function will query the target for a few enviromental variables. 

    .DESCRIPTION
    Specifies whether the OS is being virtulized or on metal. This is an important factor 
    to the reliablity of the returned values as uptime can lie.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER Targets
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost.

    .EXAMPLE
    > Get-WmiPortableOS
    NONE

    .LINK
    NONE
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [string]$HostName
    )

    Process 
    {
        if( -Not $HostName)
        {
            $HostName = $env:computername
        }

        if ($Credential)
        {
            # execute with cred object
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_PointingDevice -computername $HostName -credential $Credential
                $VMware = $False
                $Wmi.HardwareType | foreach{
                    if ($_ -match "VMware"){
                        $VMware = $True
                        
                    }
                }
                return $VMware
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_PointingDevice -computername $HostName -credential $Credential
                $VMware = $False
                $Wmi.HardwareType | foreach{
                    if ($_ -match "VMware"){
                        $VMware = $True
                        
                    }
                }
                return $VMware
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }
        }
        else
        {
            try
            {
                # execute in current user context
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_PointingDevice -computername $HostName
                $VMware = $False
                $Wmi.HardwareType | foreach{
                    if ($_ -match "VMware"){
                        $VMware = $True
                        
                    }
                }
                return $VMware
            }
            catch 
            {
                Write-Warning "[!] Error opening lastboot time one $HostName."
            }

        } 
    }
}
function Get-WmiLogging{}

########################
# Claculate Functions  #
########################

function Calc-WmiBootTime{
<#
    .SYNOPSIS
    This function will query the target for last boot time in epoch time.

    .DESCRIPTION
    This function will query the target for last boot time in epoch time.

    .PARAMETER Time 
    Pass a time to calculate the values and return them.

    .EXAMPLE
    > 
    NONE

    .LINK
    NONE
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Time
    )
    Process 
    {
        # we will now caculate the value of the time
        if($Time)
        {
            # Enter the main loop
            # Get current date and time
            $TodaysDate=(Get-Date)
            # Do i need to build this to get the datetime object?
            $Boot = Get-WmiObject Win32_OperatingSystem
            $BootDate= $Boot.ConvertToDateTime($Time)
            $TimeDif = New-TimeSpan -Start $BootDate -End $TodaysDate
            if($TimeDif) 
            {
                $Days = $TimeDif.Days
                switch ($Days)
                {
                    {$_ -lt 8}
                    {
                        $Value = .30
                        break
                    }
                    {$_ -lt 16}
                    {
                        $Value = .40
                        break
                    }
                    {$_ -lt 31}
                    {
                        $Value = .60
                        break
                    }
                    {$_ -lt 61}
                    {
                        $Value = .75
                        break
                    }
                    {$_ -lt 91}
                    {
                        $Value = .85
                        break
                    }
                    {$_ -lt 121}
                    {
                        $Value = .90
                        break
                    }
                    {$_ -lt 151}
                    {
                        $Value = .95
                        break
                    }
                    {$_ -gt 152}
                    {
                        $Value = 1.00
                    }
                    default{$Value = .20}
                }
                return $Value
            }
        }
        else
        {
            # Return a zero value
            $Value = 0
            return $Value
        }
    }

}
function Calc-WmiInstallDate{
<#
    .SYNOPSIS
    This function will query the target for last boot time in epoch time.

    .PARAMETER Time 
    Pass a time to calculate the values and return them.

    .EXAMPLE
    > 
    NONE

    .LINK
    NONE
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Time
    )
    Process
    {
        # we will now caculate the value of the time
        if($Time)
        {
            # Enter the main loop
            # Get current date and time
            $TodaysDate=(Get-Date)
            # Do i need to build this to get the datetime object?
            $Boot = Get-WmiObject Win32_OperatingSystem
            $BootDate= $Boot.ConvertToDateTime($Time)
            $TimeDif = New-TimeSpan -Start $BootDate -End $TodaysDate
            if($TimeDif) 
            {
                $Days = $TimeDif.Days
                switch ($Days)
                {
                    {$_ -lt 180}
                    {
                        $Value = .20
                        break
                    }
                    {$_ -lt 360}
                    {
                        $Value = .40
                        break
                    }
                    {$_ -lt 720}
                    {
                        $Value = .80
                        break
                    }
                    {$_ -gt 1080}
                    {
                        $Value = 1.00
                    }
                    default{$Value = .20}
                }
                return $Value
            }
        }
        else
        {
            # Return a zero value
            $Value = 0
            return $Value
        }
    }

}
function Calc-WmiArch{
<#
    .SYNOPSIS
    This function will query the target for last boot time in epoch time.

    .PARAMETER Arch 
    Pass a time to calculate the values and return them.

    .EXAMPLE
    > 
    NONE

    .LINK
    NONE
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Arch
    )
    Process
    {
        # we will now caculate the value of the time
        if($Arch)
        {
            # Enter the main loop
            switch ($Arch)
            {
                {$_ -eq 32}
                {
                    $Value = .50
                    break
                }
                {$_ -eq 64}
                {
                    $Value = 1.00
                }
                default{$Value = .30}
             }
             return $Value
        }
        else
        {
            # Return a zero value
            $Value = 0.0
            return $Value
        }
    }
}
function Calc-WmiProcSpeed{
<#
    .SYNOPSIS
    This function will query the target for last boot time in epoch time.

    .PARAMETER Speed 
    Pass a time to calculate the values and return them.

    .EXAMPLE
    > 
    NONE

    .LINK
    NONE
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Speed
    )
    Process
    {
        # caculate the value of the Proc Speed in MHz
        if($Speed)
        {
            # Enter the main loop
            switch ($Speed)
            {
                {$_ -lt 1500}
                {
                    $Value = 0.20
                    break
                }
                {$_ -lt 2000}
                {
                    $Value = 0.40
                    break
                }
                {$_ -lt 2500}
                {
                    $Value = 0.80
                    break
                }
                {$_ -lt 2949}
                {
                    $Value = 0.90
                    break
                }
                {$_ -gt 2950}
                {
                    $Value = 1.00
                }
                default{$Value = 0.30}
             }
             return $Value
        }
        else
        {
            # Return a zero value
            $Value = 0
            return $Value
        }
    }
}
function Calc-WmiLProcCount{
<#
    .SYNOPSIS
    

    .PARAMETER LProc 
    Pass a LProc Count to calculate the values and return them.

    .EXAMPLE
    > 
    NONE

    .LINK
    NONE
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $LProc
    )
    Process
    {
        # caculate the value of Logical Proc.
        if($Lproc)
        {
            # Enter the main loop
            switch ($LProc)
            {
                {$_ -lt 2}
                {
                    $Value = .30
                    break
                }
                {$_ -lt 3}
                {
                    $Value = .50
                    break
                }
                {$_ -lt 4}
                {
                    $Value = .65
                    break
                }
                {$_ -lt 5}
                {
                    $Value = .80
                    break
                }
                {$_ -lt 6}
                {
                    $Value = .90
                }
                {$_ -gt 6}
                {
                    $Value = 1.00
                }
                default{$Value = .30}
             }
             return $Value
        }
        else
        {
            # Return a zero value
            $Value = 0
            return $Value
        }
    }
}
function Calc-WmiDisk{
<#
    .SYNOPSIS
    

    .PARAMETER LProc 
    Pass a GB Disk size and calculate the value.

    .EXAMPLE
    > 
    NONE

    .LINK
    NONE
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Disk
    )
    Process
    {
        # caculate the value of Logical Proc.
        if($Disk)
        {
            # Enter the main loop
            switch ($Disk)
            {
                {$_ -lt 50}
                {
                    $Value = .30
                    break
                }
                {$_ -lt 200}
                {
                    $Value = .50
                    break
                }
                {$_ -lt 500}
                {
                    $Value = .70
                    break
                }
                {$_ -lt 1000}
                {
                    $Value = .80
                    break
                }
                {$_ -lt 1500}
                {
                    $Value = .90
                }
                {$_ -gt 1800}
                {
                    $Value = 1.00
                }
                default{$Value = .30}
             }
             return $Value
        }
        else
        {
            # Return a zero value
            $Value = 0.0
            return $Value
        }
    }
}
function Calc-WmiRamSize{
<#
    .SYNOPSIS
    

    .PARAMETER LProc 
    Pass a GB Ram size and calculate the value.

    .EXAMPLE
    > 
    NONE

    .LINK
    NONE
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Ram
    )
    Process
    {
        # caculate the value of Logical Proc.
        if($Ram)
        {
            # Enter the main loop
            switch ($Ram)
            {
                {$_ -lt 1}
                {
                    $Value = .20
                    break
                }
                {$_ -lt 2}
                {
                    $Value = .30
                    break
                }
                {$_ -lt 3}
                {
                    $Value = .50
                    break
                }
                {$_ -lt 4}
                {
                    $Value = .70
                    break
                }
                {$_ -lt 6}
                {
                    $Value = .80
                }
                {$_ -lt 8}
                {
                    $Value = .90
                }
                {$_ -gt 20}
                {
                    $Value = 1.00
                }
                default{$Value = .30}
             }
             return $Value
        }
        else
        {
            # Return a zero value
            $Value = 0.0
            return $Value
        }
    }
}
function Calc-WmiServer{
<#
    .SYNOPSIS
   

    .PARAMETER Type 
    Pass a Os Type Code, and return proper value.

    .EXAMPLE
    > 
    NONE

    .LINK
    NONE
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Type
    )
    Process
    {
        # caculate the value of Logical Proc.
        if($Type)
        {
            # Enter the main loop
            switch ($Type)
            {
                {$_ -eq 1}
                {
                    # Workstation
                    $Value = 0.33
                    break
                }
                {$_ -eq 2}
                {
                    # DC
                    $Value = 0.66
                    break
                }
                {$_ -eq 3}
                {
                    # Server
                    $Value = 1.00
                    break
                }
                default{$Value = 0.30}
             }
             return $Value
        }
        else
        {
            # Return a zero value
            $Value = 0.0
            return $Value
        }
    }
}
function Calc-WmiProcessCount{
<#
    .SYNOPSIS
   

    .PARAMETER Type 
    Pass a Process count for a return value.

    .EXAMPLE
    > 
    NONE

    .LINK
    NONE
#>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Count
    )
    Process
    {
        # caculate the value of Logical Proc.
        if($Count)
        {
            # Enter the main loop
            switch ($Count)
            {
                {$_ -lt 8}
                {
                    # Workstation
                    $Value = 0.40
                    break
                }
                {$_ -lt 10}
                {
                    # Workstation
                    $Value = 0.60
                    break
                }
                {$_ -lt 12}
                {
                    # DC
                    $Value = 0.70
                    break
                }
                {$_ -lt 15}
                {
                    # Workstation
                    $Value = 0.80
                    break
                }
                {$_ -gt 15}
                {
                    # Server
                    $Value = 1.00
                    break
                }
                default{$Value = 0.30}
             }
             return $Value
        }
        else
        {
            # Return a zero value
            $Value = 0.0
            return $Value
        }
    }
}
function Calc-WmiSystemEnclosure{
<#
    .SYNOPSIS
    Calcuate the value of an array of system enclosures.

    .PARAMETER Code 
    Pass a Process count for a return value.

    .EXAMPLE
    > 
    NONE

    .LINK
    NONE
#>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Code
    )
    Process
    {
        if($Code)
        {
            # Enter the main loop
            $Value = 0
            ForEach ($i in $Code)
            {
            switch ($i)
            <#
            Other (1)
            Unknown (2)
            Desktop (3)
            Low Profile Desktop (4)
            Pizza Box (5)
            Mini Tower (6)
            Tower (7)
            Portable (8)
            Laptop (9)
            Notebook (10)
            Hand Held (11)
            Docking Station (12)
            All in One (13)
            Sub Notebook (14)
            Space-Saving (15)
            Lunch Box (16)
            Main System Chassis (17)
            Expansion Chassis (18)
            SubChassis (19)
            Bus Expansion Chassis (20)
            Peripheral Chassis (21)
            Storage Chassis (22)
            Rack Mount Chassis (23)
            Sealed-Case PC (24)
            #>
            {
                {$i -eq 1}
                {
                    # Other
                    $Value += 0.10
                    break
                }
                {$i -eq 2}
                {
                    $Value += 0.10
                    break
                }
                {$i -eq 3}
                {
                    $Value += .50
                    break
                }
                {$i -eq 4}
                {
                    $Value = 0.10
                    break
                }
                {$i -eq 6}
                {
                    $Value = .20
                    break
                }
                {$i -eq 7}
                {
                    $Value = .60
                    break
                }
                {$i -eq 8}
                {
                    $Value = 0.10
                    break
                }
                {$i -eq 9}
                {
                    $Value = 0.10
                    break
                }
                {$i -eq 10}
                {
                    $Value = 0.10
                    break
                }
                {$i -eq 11}
                {
                    $Value = 0.10
                    break
                }
                {$i -eq 13}
                {
                    $Value = 0.10
                    break
                }
                {$i -eq 14}
                {
                    $Value = 0.10
                    break
                }
                {$i -gt 17}
                {
                    $Value = 1.00
                    break
                }
                default{$Value = .30}
             }
             if ($Value -gt 1.00) 
             {
                $Value = 1.00
             }
             return $Value
        }
        }
        else
        {
            # Return a zero value
            $Value = 0.0
            return $Value
        }
    }
}

function Calc-WeightedAverage{
    <#
    .SYNOPSIS
    This function will take a set of values and turn them into a object.
    This will return an object for manipulation.

    .PARAMETER Percent
    Pass the float value to be calculated.

    .PARAMETER Weight
    Pass the weight in float for the value.

    .EXAMPLE
    > Get-WmiPortableOS
    NONE

    .LINK
    NONE
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        $Percent,

        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        $Weight
    )
    Process{
        if ($Percent -and $Weight) {
            try {
                $WeightedValue = $Percent * $Weight
                return $WeightedValue
            }
            catch{
            Write-Verbose "[!] Failed to get weighted average."
            return 0.0
            } 
        } # end of if
    } # end of process
}
function Calc-StandardDeviation{

    Process{
                    $ArrayLen = $PersistenceObjects.count
                    $PSTotal = 0
                    $PersistenceObjects | ForEach-Object{
                        $PSTotal += $_.PersistenceSurvivability
                    }
                    $PSMean = $PSTotal / $ArrayLen 
                    $PSMeanPercent = "{0:P0}" -f $PSMean
                    # now calculate the 
                    standard deviation
                    $ValueofSepration = 0
                    $PersistenceObjects | ForEach-Object{
                        # get the current value in float
                        $PSValue = $_.PersistenceSurvivability
                        # Sub the float values by the mean
                        $DiffrenceFromMean = $PSValue - $PSMean
                        # now square root the value
                        $ValueofSepration += [Math]::Pow($DiffrenceFromMean, 2)
                    }
                    # now we will calculate the Variance
                    # also account for sample data if needed
                    $Variance = $ValueofSepration / $ArrayLen
                    $Variance =[Math]::SQRT($Variance)


    }
}
function Weighted-Values{
    <#
    .SYNOPSIS
    This function will return an object of weighted
    values for calculation.
    #>
    Process{   
        $WeightedValue = New-Object PSObject
        $WeightedValue | Add-Member Noteproperty 'LastBoot' 0.40
        $WeightedValue | Add-Member Noteproperty 'InstallDate' 0.05
        $WeightedValue | Add-Member Noteproperty 'OSArch' 0.05
        $WeightedValue | Add-Member Noteproperty 'ServerType' 0.10
        $WeightedValue | Add-Member Noteproperty 'SystemEnclosure' 0.10
        $WeightedValue | Add-Member Noteproperty 'RamSize' 0.05
        $WeightedValue | Add-Member Noteproperty 'DiskSize' 0.05
        $WeightedValue | Add-Member Noteproperty 'ProcessorSpeed' 0.05
        $WeightedValue | Add-Member Noteproperty 'ProcessorLogicalCores' 0.05
        $WeightedValue | Add-Member Noteproperty 'ProcessorCores' 0.05
        $WeightedValue | Add-Member Noteproperty 'ProcessCount' 0.05
        # boolean values
        $WeightedValue | Add-Member Noteproperty 'PortableOS' 0.25
        return $WeightedValue
    }
}

 

#########################
#                       #
#  Main function Calls  #
#                       #
#########################

function Invoke-FindPersitence{
<#
    .SYNOPSIS
    Queries all machines on the domain, for Networks Name,
    DNS Suffix and the MAC of the connected Network.

    .PARAMETER Top
    Display the top # of results for each category. Defualts to top 3 results.

    .PARAMETER MaxHosts
    Only query the selected number of hosts 

    .PARAMETER UserName
    One or more computers to test. DOMAIN\UserName

    .PARAMETER Password
    One or more computers to test

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER NoPing
    Don't ping each host to ensure it's up before enumerating.

    .PARAMETER Delay
     Delay between enumerating hosts, defaults to 0 milliseconds.

    .PARAMETER Jitter
    Jitter for the host delay, defaults to +/- 0-100 milliseconds

    .PARAMETER HostList
    Provid a hostlist on the CLI (IP, NAME).

    .PARAMETER IpSubnet
    Provid a IP with subnet to target.

    .PARAMETER OperatingSystem
     Return computers with a specific operating system, wildcards accepted.

    .PARAMETER ServicePack
        Return computers with a specific service pack, wildcards accepted.

    .PARAMETER Domain
    Domain to query for machines, defaults to the current domain.

    .PARAMETER SPN
     Return computers with a specific service principal name, wildcards accepted.

    .PARAMETER SearchForest
    Switch. Search all domains in the forest for target users instead of just
    a single domain.

    .PARAMETER CheckAdmin
    Switch. Check if the current user has access to the box before procedding.
    This may be important within a forest.

    .PARAMETER Threads
    The maximum concurrent threads to execute. **NEED TO BUILD**

    .PARAMETER RawOutput
    Will return every object to the CLI, this can be used for out-file or
    just to test data being returned.

    .EXAMPLE
    PS> Invoke-FindPersitence 
    This will query the current domain and ALL the hosts that up.

    .EXAMPLE
    PS> Invoke-FindPersitence -Domain tester.org -OperatingSystem *7*
    This will query for computers inside a unique domain, with a specfic OS filter. In this 
    case we are querying for all windows 7 platforms.

    PS> Invoke-FindPersitence -MaxHosts 100 -Top 5
    This will query for computers untill the host limit is reached, as well as 
    only display the top 5 hosts of the report.

    PS> Invoke-FindPersitence -ReturnObjects
    This will allow you to return an PS array of computer objects built.
#>
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True)]
        [Alias('HostName')]
        [String]
        $ComputerName = '*',

        [Parameter(ValueFromPipeline=$True)]
        [Int]$Top = 3,

        [Parameter(ValueFromPipeline=$True)]
        $HostList,

        [Parameter(ValueFromPipeline=$True)]
        $IpSubnet,

        [Parameter(ValueFromPipeline=$True)]
        [Int]$TimeOut = 5,

        [Parameter(ValueFromPipeline=$True)]
        [Int]$Delay = 0,

        [Parameter(ValueFromPipeline=$True)]
        [Int]$Jitter = 100,

        [Parameter(ValueFromPipeline=$True)]
        [Int]$MaxHosts,

        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [String]$User,

        [Parameter(ValueFromPipeline=$True)]
        [String]$Password,

        [Parameter(ValueFromPipeline=$True)]
        [String]$SPN,

        [Parameter(ValueFromPipeline=$True)]
        [String]$OperatingSystem,

        [Parameter(ValueFromPipeline=$True)]
        [String]$ServicePack,

        [Parameter(ValueFromPipeline=$True)]
        [String]$Filter,

        [Parameter(ValueFromPipeline=$True)]
        [String]$Domain,

        [Parameter(ValueFromPipeline=$True)]
        [String]$DomainController,

        [Parameter(ValueFromPipeline=$True)]
        [String]$ADSpath,

        [Parameter(ValueFromPipeline=$True)]
        [Switch]$Unconstrained,

        [Parameter(ValueFromPipeline=$True)]
        [Switch]$ReturnObjects,

        [Parameter(ValueFromPipeline=$True)]
        [Switch]$RawOutput,

        [ValidateRange(1,100)] 
        [Int]$Threads=4,

        [ValidateRange(1,10000)] 
        [Int]
        $PageSize = 200
    )
    begin {
        Write-Verbose "[*] Strating Invoke-FindPersitence" 
        if ($HostList){
            $Computers = $HostList
            Write-Verbose "[*] IP MAIN: hosts passed:"
        }
        if ($IpSubnet){
            $Computers = Get-NetworkRange $IpSubnet
        }
        else {
            # so this isn't repeated if users are passed on the pipeline
            $Computers = Get-NetComputer -Domain $Domain -DomainController $DomainController -OperatingSystem $OperatingSystem -ServicePack $ServicePack -SPN $SPN -PageSize $PageSize -ADSpath $ADSpath -Filter $Filter -ComputerName $ComputerName
        }
    }
    Process {

        if ($Computers) {
                # create weighted value object before loop.
                # declare an array for 
                $PersistenceObjects = @()
                $FinalComputerObjects = @()
                # start main
                $Counter = 1
                if($MaxHosts){
                    # Should we ping all boxes first and supply the right number of hosts
                    # or just feed x hosts?
                    $Computers = $Computers | Select-Object -first $MaxHosts
                }
                # Test if they are up first:
                Write-Verbose "[*] IP MAIN: Calling Invoke-Ping"
                $Computers = Invoke-Ping -Timeout 5 -ComputerName $Computers
                Write-Verbose "[*] IP MAIN: Invoke-Ping Complete"
                # Make sure we can reach RPC / talk to WMI
                Write-Verbose "[*] IP MAIN: Calling Test-Wmi"
                $FinalComputerObjects = Test-Wmi -ComputerName $Computers -Credential $Credential -User $User -Password $Password -Threads $Threads
                Write-Verbose "[*] IP MAIN: Test-Wmi Complete"
                # Build a Script Block 
                    Write-Verbose "[*] IP MAIN: Building script blokc for wmi collection"
                    $sb = [scriptblock] { param($ComputerName) param($User) param($Password) param($Credential) param($Delay) param($Jitter) if($Delay){
                    # create sleep for jitter /delay time
                        $JitterValue = Get-Random -Minimum 0 -Maximum $Jitter
                        # for Postive / Negative Jitter count
                        $RandMulti = Get-Random -input -1,1
                        $SleepJitter = $JitterValue * $RandMulti
                        # calculate the sleep time by adding pot negative #
                        $SleepTime = $Delay + $SleepJitter
                        Start-Sleep -Milliseconds $SleepTime
                    }
                    # setup meta calls for repeated Wmi calls to reduce call traffic
                    $WmiOS = Get-WmiOS -User $User -Password $Password -Credential $Credential -HostName $ComputerName
                    # Obtain required values for calculation
                    try{
                        $LastBoot = Get-WmiBootTime -User $User -Password $Password -Credential $Credential -HostName $ComputerName -WmiOS $WmiOS
                        $InstallDate = Get-WmiInstallDate -User $User -Password $Password -Credential $Credential -HostName $ComputerName -WmiOS $WmiOS
                        $Arch = Get-WmiArch -User $User -Password $Password -Credential $Credential -HostName $ComputerName -WmiOS $WmiOS
                        $Server = Get-WmiServer -User $User -Password $Password -Credential $Credential -HostName $ComputerName -WmiOS $WmiOS
                        $SystemEncl = Get-WmiSystemEnclosure -User $User -Password $Password -Credential $Credential -HostName $ComputerName
                        $RamSize = Get-WmiRamSize -User $User -Password $Password -Credential $Credential -HostName $ComputerName
                        $DiskSize = Get-WMiDisk -User $User -Password $Password -Credential $Credential -HostName $ComputerName
                        $ProcSpeed = Get-WmiProcessorSpeed -User $User -Password $Password -Credential $Credential -HostName $ComputerName
                        $LProcCount = Get-WmiLProcessorCount -User $User -Password $Password -Credential $Credential -HostName $ComputerName
                        $ProcCores = Get-WmiProcessorCores -User $User -Password $Password -Credential $Credential -HostName $ComputerName
                        $ProcCount = Get-WmiProcessCount -User $User -Password $Password -Credential $Credential -HostName $ComputerName
                        # Obtain required boolean values 
                        $PortOS = Get-WmiPortableOS -User $User -Password $Password -Credential $Credential -HostName $ComputerName -WmiOS $WmiOS
                        $VMware = Get-WmiVMChecks -User $User -Password $Password -Credential $Credential -HostName $ComputerName
                    }

                    catch{
                        Write-Verbose "[!] Failed to get WMI values"
                    }
                    try{
                        # Calculate the values of the object
                        $VLastBoot = Calc-WmiBootTime -Time $LastBoot
                        $VInstallDate = Calc-WmiInstallDate -Time $InstallDate
                        $VArch = Calc-WmiArch -Arch $Arch
                        $VServer = Calc-WmiServer -Type $Server
                        $VSystemEncl = Calc-WmiSystemEnclosure -Code $SystemEncl
                        $VRamSize = Calc-WmiRamSize -Ram $RamSize
                        $VDiskSpace = Calc-WmiDisk -Disk $DiskSize 
                        $VProcSpeed = Calc-WmiProcSpeed -Speed $ProcSpeed
                        $VLProcCount = Calc-WmiLProcCount -LProc $LProcCount
                        # $WProcCores = Calc-WmiProcCores -Cores $ProcCores
                        $VProcCount = Calc-WmiProcessCount -Count $ProcCount
                    }
                    catch {
                        Write-Verbose "[!] Failed to calculate values"
                    }
                    try{
                        # calculate weighted averages
                        $WeightedValue = Weighted-Values
                        $WLastBoot = Calc-WeightedAverage -Percent $VLastBoot -Weight $WeightedValue.LastBoot
                        $WInstallDate = Calc-WeightedAverage -Percent $VInstallDate -Weight $WeightedValue.InstallDate
                        $WArch = Calc-WeightedAverage -Percent $VArch -Weight $WeightedValue.OSArch
                        $WServer = Calc-WeightedAverage -Percent $VServer -Weight $WeightedValue.ServerType
                        $WSystemEncl = Calc-WeightedAverage -Percent $VSystemEncl -Weight $WeightedValue.SystemEnclosure
                        $WRamSize = Calc-WeightedAverage -Percent $VRamSize -Weight $WeightedValue.RamSize
                        $WDiskSpace = Calc-WeightedAverage -Percent $VDiskSpace -Weight $WeightedValue.DiskSize
                        $WProcSpeed = Calc-WeightedAverage -Percent $VProcSpeed -Weight $WeightedValue.ProcessorSpeed
                        $WLProcCount = Calc-WeightedAverage -Percent $VLProcCount -Weight $WeightedValue.ProcessorLogicalCores
                        # Cores
                        $WProcCount = Calc-WeightedAverage -Percent $VProcCount -Weight $WeightedValue.ProcessCount
                        # calc the PersistenceSurvivability rating
                        [float]$PersistenceSurvivability = $WLastBoot + $WInstallDate + $WArch + $WServer + $WSystemEncl + $WDiskSpace + $WProcSpeed + $WLProcCount + $WRamSize
                    }
                    catch{
                        Write-Verbose "[!] Failed to build weighted Averages"
                        }
                    try{
                        $IpAddress = [System.Net.Dns]::GetHostAddresses("$ComputerName").IPAddressToString
                    }
                    catch{
                        $IpAddress = "Uknown"
                    }
                    try{
                        # build our object of values
                        $ComputerObject = New-Object PSObject
                        $ComputerObject | Add-Member NoteProperty 'NetBIOSName' $ComputerName
                        $ComputerObject | Add-Member NoteProperty 'IpAddress' $IpAddress
                        $ComputerObject | Add-Member Noteproperty 'LastBoot' $LastBoot
                        $ComputerObject | Add-Member Noteproperty 'InstallDate' $InstallDate
                        $ComputerObject | Add-Member Noteproperty 'OSArch' $Arch
                        $ComputerObject | Add-Member Noteproperty 'ServerType' $Server
                        $ComputerObject | Add-Member Noteproperty 'SystemEnclosure' $SystemEncl
                        $ComputerObject | Add-Member Noteproperty 'RamSize' $RamSize
                        $ComputerObject | Add-Member Noteproperty 'DiskSize' $DiskSize
                        $ComputerObject | Add-Member Noteproperty 'ProcessorSpeed' $ProcSpeed
                        $ComputerObject | Add-Member Noteproperty 'ProcessorLogicalCores' $LProcCount
                        $ComputerObject | Add-Member Noteproperty 'ProcessorCores' $ProcCores
                        $ComputerObject | Add-Member Noteproperty 'ProcessCount' $ProcCount
                        # boolean values
                        $ComputerObject | Add-Member Noteproperty 'PortableOS' $PortOS
                        $ComputerObject | Add-Member NoteProperty 'VMware' $VMware
                        # calculated values
                        $ComputerObject | Add-Member NoteProperty 'LastBootV' $VLastBoot
                        $ComputerObject | Add-Member NoteProperty 'InstallDateV' $VInstallDate
                        $ComputerObject | Add-Member NoteProperty 'OSArchV' $VArch
                        $ComputerObject | Add-Member NoteProperty 'ServerTypeV' $VServer
                        $ComputerObject | Add-Member NoteProperty 'SystemEnclosureV' $VSystemEncl
                        #$ComputerObject | Add-Member NoteProperty 'LastBootValue' $VRamSize
                        $ComputerObject | Add-Member NoteProperty 'DiskSizeV' $VDiskSpace
                        $ComputerObject | Add-Member NoteProperty 'RamSizeV' $VRamSize
                        $ComputerObject | Add-Member NoteProperty 'ProcessorSpeedV' $VProcSpeed
                        $ComputerObject | Add-Member NoteProperty 'ProcessorLogicalCoreV' $VLProcCount
                        #$ComputerObject | Add-Member NoteProperty 'ProcessorCoresV' $VProcCores
                        $ComputerObject | Add-Member NoteProperty 'ProcessCountV' $VProcCount
                        # build out weighted values
                        $ComputerObject | Add-Member NoteProperty 'LastBootWV' $WLastBoot
                        $ComputerObject | Add-Member NoteProperty 'InstallDateWV' $WInstallDate
                        $ComputerObject | Add-Member NoteProperty 'OSArchWV' $WArch
                        $ComputerObject | Add-Member NoteProperty 'ServerTypeWV' $WServer
                        $ComputerObject | Add-Member NoteProperty 'SystemEnclosureWV' $WSystemEncl
                        $ComputerObject | Add-Member NoteProperty 'DiskSizeWV' $WDiskSpace
                        $ComputerObject | Add-Member NoteProperty 'RamSizeWV' $WRamSize
                        $ComputerObject | Add-Member NoteProperty 'ProcessorSpeedWV' $WProcSpeed
                        $ComputerObject | Add-Member NoteProperty 'ProcessorLogicalCoreWV' $WLProcCount
                        $ComputerObject | Add-Member NoteProperty 'ProcessCountWV' $WProcCount
                        # our total values
                        $ComputerObject | Add-Member NoteProperty 'PersistenceSurvivability' $PersistenceSurvivability


                        # print / return value
                        $ComputerObject
                    }
                    catch{
                        "[!] Failed to build computer object!"
                    }
            } # End of script block
            Write-Verbose "[*] IP MAIN: Script block creation complete"
            # call threaded function
            $ScriptParams = @{
                'Computers' = $ComputerName
                'User' = $User
                'Password' = $Password
                'Credential' = $Password
                'Delay' = $Delay
                'Jitter' = $Jitter
            }
            Write-Verbose "[*] IP MAIN: Strating threads on script block"
            $PersistenceObjects = Invoke-ThreadedFunction -ComputerName $FinalComputerObjects -ScriptBlock $sb -Threads $Threads -ScriptParameters $ScriptParams
            if ($RawOutput){
               $PersistenceObjects
            }
            if (!$ReturnObjects){
                # declare arrays for each section
                $VMwareObjects = @()
                $DesktopObjects = @()
                $ServerObjects = @()
                # create loop for sorting etc.
                $PersistenceObjects | ForEach-Object{
                    if($_.VMware){
                        $VMwareObjects += $_
                    } 
                    elseif($_.ServerType -gt 1 -and !$_.VMware){
                        # we should also check for VMware?
                        $ServerObjects += $_
                    } 
                    else{
                        # we should also check for VMware?
                        $DesktopObjects += $_
                    }        
                }# end of foreach loop
                
                # now sort the objects by persistence rating
                try{
                    Write-Host "[*] Top Server locations based on Persistence Survivability rating: "
                    $SortedObjectsServer = Sort-Object -Descending -Property PersistenceSurvivability -InputObject $ServerObjects 
                    $SortedObjectsServer | Select-Object -first $Top
                }
                catch{
                    Write-Verbose "[!] Failed to print the top results (Server Objects)"
                }
                try{
                    Write-Host "[*] Top Desktop locations based on Persistence Survivability rating: "
                    $SortedObjectsDesktop = Sort-Object -Descending -Property PersistenceSurvivability -InputObject $DesktopObjects 
                    $SortedObjectsDesktop | Select-Object -first $Top
                }
                catch{
                    Write-Verbose "[!] Failed to sort Desktop objects"
                }
                try{
                    Write-Host "[*] Top VM locations based on Persistence Survivability rating: "
                    $SortedObjectsVM = Sort-Object -Descending -Property PersistenceSurvivability -InputObject $VMwareObjects 
                    $SortedObjectsVM | Select-Object -first $Top
                }
                catch{
                    Write-Verbose "[!] Failed to sort VMware objects"
                }
                # now build the stat data
                if($PersistenceObjects){
                    $ArrayLen = $PersistenceObjects.count
                    $PSTotal = 0
                    $PersistenceObjects | ForEach-Object{
                        $PSTotal += $_.PersistenceSurvivability
                    }
                    $PSMean = $PSTotal / $ArrayLen 
                    $PSMeanPercent = "{0:P0}" -f $PSMean
                    # now calculate the 
                    # standard deviation
                    $ValueofSepration = 0
                    $PersistenceObjects | ForEach-Object{
                        # get the current value in float
                        $PSValue = $_.PersistenceSurvivability
                        # Sub the float values by the mean
                        $DiffrenceFromMean = $PSValue - $PSMean
                        # now square root the value
                        $ValueofSepration += [Math]::Pow($DiffrenceFromMean, 2)
                    }
                    # now we will calculate the Variance
                    # also account for sample data if needed
                    $Variance = $ValueofSepration / $ArrayLen
                    $Variance =[Math]::SQRT($Variance)
                    # now build the stat object
                    $StatObject = New-Object PSObject
                    $StatObject | Add-Member NoteProperty 'ArrayLen' $PersistenceObjects.count
                    $StatObject | Add-Member NoteProperty 'VMwareLen' $VMwareObjects.count
                    $StatObject | Add-Member NoteProperty 'DesktopLen' $DesktopObjects.count
                    $StatObject | Add-Member NoteProperty 'ServerLen' $ServerObjects.count
                    $StatObject | Add-Member NoteProperty 'PSMean' $PSMeanPercent
                    $StatObject | Add-Member NoteProperty 'Variance' $Variance

                    # print final data stats:
                    Write-Host "[*] Overall Persistence Survivability stats: "
                    Write-Host "    Total number of hosts: " $StatObject.ArrayLen
                    Write-Host "    Total VMware hosts: " $StatObject.VMwareLen
                    Write-Host "    Total Desktop hosts: " $StatObject.DesktopLen
                    Write-Host "    Total Server hosts: " $StatObject.ServerLen
                    Write-Host "    Survivability mean: " $StatObject.PSMean
                    Write-Host "    Standard Deviation Value: " $StatObject.Variance
                        
                } # end if print 
            } # end of if return objects
            else{
                return $PersistenceObjects
            } # return just the objects for your own parsing
        } # End of if computers
    }
    

}

#########################
#                       #
#     Helper Calls      #
#                       #
#########################

# all subnet math http://www.indented.co.uk/2010/01/23/powershell-subnet-math/
# all credit to them for that hard work!
function ConvertTo-Mask {
  <#
    .Synopsis
      Returns a dotted decimal subnet mask from a mask length.
    .Description
      ConvertTo-Mask returns a subnet mask in dotted decimal format from an integer value ranging 
      between 0 and 32. ConvertTo-Mask first creates a binary string from the length, converts 
      that to an unsigned 32-bit integer then calls ConvertTo-DottedDecimalIP to complete the operation.
    .Parameter MaskLength
      The number of bits which must be masked.
  #>
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [Alias("Length")]
    [ValidateRange(0, 32)]
    $MaskLength
  )
  
  Process {
    return ConvertTo-DottedDecimalIP ([Convert]::ToUInt32($(("1" * $MaskLength).PadRight(32, "0")), 2))
  }
}

function ConvertTo-DottedDecimalIP {
  <#
    .Synopsis
      Returns a dotted decimal IP address from either an unsigned 32-bit integer or a dotted binary string.
    .Description
      ConvertTo-DottedDecimalIP uses a regular expression match on the input string to convert to an IP address.
    .Parameter IPAddress
      A string representation of an IP address from either UInt32 or dotted binary.
  #>
 
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [String]$IPAddress
  )
  
  process {
    Switch -RegEx ($IPAddress) {
      "([01]{8}.){3}[01]{8}" {
        return [String]::Join('.', $( $IPAddress.Split('.') | ForEach-Object { [Convert]::ToUInt32($_, 2) } ))
      }
      "\d" {
        $IPAddress = [UInt32]$IPAddress
        $DottedIP = $( For ($i = 3; $i -gt -1; $i--) {
          $Remainder = $IPAddress % [Math]::Pow(256, $i)
          ($IPAddress - $Remainder) / [Math]::Pow(256, $i)
          $IPAddress = $Remainder
         } )
       
        return [String]::Join('.', $DottedIP)
      }
      default {
        Write-Error "Cannot convert this format"
      }
    }
  }
}
function ConvertTo-DottedDecimalIP {
  <#
    .Synopsis
      Returns a dotted decimal IP address from either an unsigned 32-bit integer or a dotted binary string.
    .Description
      ConvertTo-DottedDecimalIP uses a regular expression match on the input string to convert to an IP address.
    .Parameter IPAddress
      A string representation of an IP address from either UInt32 or dotted binary.
  #>
 
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [String]$IPAddress
  )
  
  process {
    Switch -RegEx ($IPAddress) {
      "([01]{8}.){3}[01]{8}" {
        return [String]::Join('.', $( $IPAddress.Split('.') | ForEach-Object { [Convert]::ToUInt32($_, 2) } ))
      }
      "\d" {
        $IPAddress = [UInt32]$IPAddress
        $DottedIP = $( For ($i = 3; $i -gt -1; $i--) {
          $Remainder = $IPAddress % [Math]::Pow(256, $i)
          ($IPAddress - $Remainder) / [Math]::Pow(256, $i)
          $IPAddress = $Remainder
         } )
       
        return [String]::Join('.', $DottedIP)
      }
      default {
        Write-Error "Cannot convert this format"
      }
    }
  }
}
function ConvertTo-DecimalIP {
  <#
    .Synopsis
      Converts a Decimal IP address into a 32-bit unsigned integer.
    .Description
      ConvertTo-DecimalIP takes a decimal IP, uses a shift-like operation on each octet and returns a single UInt32 value.
    .Parameter IPAddress
      An IP Address to convert.
  #>
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [Net.IPAddress]$IPAddress
  )
 
  process {
    $i = 3; $DecimalIP = 0;
    $IPAddress.GetAddressBytes() | ForEach-Object { $DecimalIP += $_ * [Math]::Pow(256, $i); $i-- }
 
    return [UInt32]$DecimalIP
  }
}
function ConvertTo-BinaryIP {
  <#
    .Synopsis
      Converts a Decimal IP address into a binary format.
    .Description
      ConvertTo-BinaryIP uses System.Convert to switch between decimal and binary format. The output from this function is dotted binary.
    .Parameter IPAddress
      An IP Address to convert.
  #>
 
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [Net.IPAddress]$IPAddress
  )
 
  process {  
    return [String]::Join('.', $( $IPAddress.GetAddressBytes() |
      ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') } ))
  }
}
function ConvertTo-MaskLength {
  <#
    .Synopsis
      Returns the length of a subnet mask.
    .Description
      ConvertTo-MaskLength accepts any IPv4 address as input, however the output value 
      only makes sense when using a subnet mask.
    .Parameter SubnetMask
      A subnet mask to convert into length
  #>
 
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
    [Alias("Mask")]
    [Net.IPAddress]$SubnetMask
  )
 
  process {
    $Bits = "$( $SubnetMask.GetAddressBytes() | ForEach-Object { [Convert]::ToString($_, 2) } )" -replace '[\s0]'
 
    return $Bits.Length
  }
}
function Get-NetworkRange( [String]$IP, [String]$Mask ) {
  if ($IP.Contains("/")) {
    $Temp = $IP.Split("/")
    $IP = $Temp[0]
    $Mask = $Temp[1]
  }
 
  if (!$Mask.Contains(".")) {
    $Mask = ConvertTo-Mask $Mask
  }
 
  $DecimalIP = ConvertTo-DecimalIP $IP
  $DecimalMask = ConvertTo-DecimalIP $Mask
  
  $Network = $DecimalIP -band $DecimalMask
  $Broadcast = $DecimalIP -bor ((-bnot $DecimalMask) -band [UInt32]::MaxValue)
 
  for ($i = $($Network + 1); $i -lt $Broadcast; $i++) {
    ConvertTo-DottedDecimalIP $i
  }
}

function Test-Wmi {
    <#
    .SYNOPSIS
    This function will query the target with Wmi to test creds and make sure we have the
    ability to talk to RPC.

    .PARAMETER Credential 
    Pass a credential object on the CLI. Rather than recreating a new credential object it can be re-used.

    .PARAMETER UserName
    DOMAIN\UserName to pass to CLI.

    .PARAMETER Password
    String Password to pass to CLI.

    .PARAMETER ComputerName
    Host to target for the data. Can be a hostname, IP address, or FQDN. Default is set to localhost or list of computers.

    .EXAMPLE
    > Get-WmiBootTime
    NONE

    .LINK
    NONE
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $Credential,

        [Parameter(ValueFromPipeline=$True)]
        [string]$User,

        [Parameter(ValueFromPipeline=$True)]
        [string]$Password,

        [Parameter(ValueFromPipeline=$True)]
        $ComputerName,

        [ValidateRange(1,100)] 
        [Int]
        $Threads=4

    )
    Process 
    {
    $sb = [scriptblock] { param($ComputerName) if( -Not $ComputerName)
        {
            $ComputerName = $env:computername
        }
        # execute with cred object
        if ($Credential)
        {
            # execute with cred object
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_COMSetting -computername $ComputerName -credential $Credential 
                if ($wmi){
                    return $ComputerName
                }
                else{
                }
            }
            catch 
            {
            }
        }
        elseif ($User -and $Password)
        {
            # execute with built credential object
            $Password = ConvertTo-SecureString $Password -AsPlainText -Force
	        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
            try
            {
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_COMSetting -computername $ComputerName -credential $Credential -EA Stop
                if ($wmi){
                    return $ComputerName
                }
                else{
                }
            }
            catch 
            {
            }
        }
        else
        {
            try
            {
                # execute in current user context
                $Wmi = Get-WmiObject -Namespace "root\cimv2" -Class Win32_COMSetting -computername $ComputerName -EA Stop
                if ($wmi){
                    return $ComputerName
                }
                else{ 
                }
            }
            catch 
            {
            }

        }
    } # end of script block
    $ScriptParams = @{
                'Computers' = $ComputerName
    }
    Invoke-ThreadedFunction -ComputerName $ComputerName -ScriptBlock $sb -Threads $Threads
  }
}

function Invoke-ThreadedFunction {
    # Helper used by any threaded host enumeration functions
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [String[]]
        $ComputerName,

        [Parameter(Position=1,Mandatory=$True)]
        [System.Management.Automation.ScriptBlock]
        $ScriptBlock,

        [Parameter(Position=2)]
        [Hashtable]
        $ScriptParameters,

        [Int]
        $Threads = 20,

        [Switch]
        $NoImports
    )

    begin {

        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }

        Write-Verbose "[*] Total number of hosts: $($ComputerName.count)"

        # Adapted from:
        #   http://powershell.org/wp/forums/topic/invpke-parallel-need-help-to-clone-the-current-runspace/
        $SessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        $SessionState.ApartmentState = [System.Threading.Thread]::CurrentThread.GetApartmentState()

        # import the current session state's variables and functions so the chained PowerView
        #   functionality can be used by the threaded blocks
        if(!$NoImports) {

            # grab all the current variables for this runspace
            $MyVars = Get-Variable -Scope 2

            # these Variables are added by Runspace.Open() Method and produce Stop errors if you add them twice
            $VorbiddenVars = @("?","args","ConsoleFileName","Error","ExecutionContext","false","HOME","Host","input","InputObject","MaximumAliasCount","MaximumDriveCount","MaximumErrorCount","MaximumFunctionCount","MaximumHistoryCount","MaximumVariableCount","MyInvocation","null","PID","PSBoundParameters","PSCommandPath","PSCulture","PSDefaultParameterValues","PSHOME","PSScriptRoot","PSUICulture","PSVersionTable","PWD","ShellId","SynchronizedHash","true")

            # Add Variables from Parent Scope (current runspace) into the InitialSessionState
            ForEach($Var in $MyVars) {
                if($VorbiddenVars -NotContains $Var.Name) {
                $SessionState.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $Var.name,$Var.Value,$Var.description,$Var.options,$Var.attributes))
                }
            }

            # Add Functions from current runspace to the InitialSessionState
            ForEach($Function in (Get-ChildItem Function:)) {
                $SessionState.Commands.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList $Function.Name, $Function.Definition))
            }
        }

        # threading adapted from
        # https://github.com/darkoperator/Posh-SecMod/blob/master/Discovery/Discovery.psm1#L407
        #   Thanks Carlos!

        # create a pool of maxThread runspaces
        $Pool = [runspacefactory]::CreateRunspacePool(1, $Threads, $SessionState, $Host)
        $Pool.Open()

        $Jobs = @()
        $PS = @()
        $Wait = @()

        $Counter = 0
    }

    process {

        ForEach ($Computer in $ComputerName) {

            # make sure we get a server name
            if ($Computer -ne '') {
                # Write-Verbose "[*] Enumerating server $Computer ($($Counter+1) of $($ComputerName.count))"

                While ($($Pool.GetAvailableRunspaces()) -le 0) {
                    Start-Sleep -MilliSeconds 500
                }

                # create a "powershell pipeline runner"
                $PS += [powershell]::create()

                $PS[$Counter].runspacepool = $Pool

                # add the script block + arguments
                $Null = $PS[$Counter].AddScript($ScriptBlock).AddParameter('ComputerName', $Computer)
                if($ScriptParameters) {
                    ForEach ($Param in $ScriptParameters.GetEnumerator()) {
                        $Null = $PS[$Counter].AddParameter($Param.Name, $Param.Value)
                    }
                }

                # start job
                $Jobs += $PS[$Counter].BeginInvoke();

                # store wait handles for WaitForAll call
                $Wait += $Jobs[$Counter].AsyncWaitHandle
            }
            $Counter = $Counter + 1
        }
    }

    end {

        Write-Verbose "Waiting for scanning threads to finish..."

        $WaitTimeout = Get-Date

        # set a 60 second timeout for the scanning threads
        while ($($Jobs | Where-Object {$_.IsCompleted -eq $False}).count -gt 0 -or $($($(Get-Date) - $WaitTimeout).totalSeconds) -gt 60) {
                Start-Sleep -MilliSeconds 500
            }

        # end async call
        for ($y = 0; $y -lt $Counter; $y++) {

            try {
                # complete async job
                $PS[$y].EndInvoke($Jobs[$y])

            } catch {
                Write-Warning "error: $_"
            }
            finally {
                $PS[$y].Dispose()
            }
        }
        
        $Pool.Dispose()
        Write-Verbose "All threads completed!"
    }
}



function Invoke-Ping {
# Invoke-Ping adapted from RamblingCookieMonster's code at
# https://github.com/RamblingCookieMonster/PowerShell/blob/master/Invoke-Ping.ps1
<#
.SYNOPSIS
    Ping systems in parallel
    Author: RamblingCookieMonster
    
.PARAMETER ComputerName
    One or more computers to test

.PARAMETER Timeout
    Time in seconds before we attempt to dispose an individual query.  Default is 20

.PARAMETER Throttle
    Throttle query to this many parallel runspaces.  Default is 100.

.PARAMETER NoCloseOnTimeout
    Do not dispose of timed out tasks or attempt to close the runspace if threads have timed out

    This will prevent the script from hanging in certain situations where threads become non-responsive, at the expense of leaking memory within the PowerShell host.

.EXAMPLE
    $Responding = $Computers | Invoke-Ping
    
    # Create a list of computers that successfully responded to Test-Connection

.LINK
    https://github.com/RamblingCookieMonster/PowerShell/blob/master/Invoke-Ping.ps1
    https://gallery.technet.microsoft.com/scriptcenter/Invoke-Ping-Test-in-b553242a
#>

    [cmdletbinding(DefaultParameterSetName='Ping')]
    param(
        [Parameter( ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true, 
                    Position=0)]
        [string[]]$ComputerName,
        
        [int]$Timeout = 20,
        
        [int]$Throttle = 100,

        [switch]$NoCloseOnTimeout
    )

    Begin
    {
        $Quiet = $True

        #http://gallery.technet.microsoft.com/Run-Parallel-Parallel-377fd430
        function Invoke-Parallel {
            [cmdletbinding(DefaultParameterSetName='ScriptBlock')]
            Param (   
                [Parameter(Mandatory=$false,position=0,ParameterSetName='ScriptBlock')]
                    [System.Management.Automation.ScriptBlock]$ScriptBlock,

                [Parameter(Mandatory=$false,ParameterSetName='ScriptFile')]
                [ValidateScript({test-path $_ -pathtype leaf})]
                    $ScriptFile,

                [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
                [Alias('CN','__Server','IPAddress','Server','ComputerName')]    
                    [PSObject]$InputObject,

                    [PSObject]$Parameter,

                    [switch]$ImportVariables,

                    [switch]$ImportModules,

                    [int]$Throttle = 20,

                    [int]$SleepTimer = 200,

                    [int]$RunspaceTimeout = 0,

                    [switch]$NoCloseOnTimeout = $false,

                    [int]$MaxQueue,

                [validatescript({Test-Path (Split-Path $_ -parent)})]
                    [string]$LogFile = "C:\temp\log.log",

                    [switch] $Quiet = $false
            )
    
            Begin {
                
                #No max queue specified?  Estimate one.
                #We use the script scope to resolve an odd PowerShell 2 issue where MaxQueue isn't seen later in the function
                if( -not $PSBoundParameters.ContainsKey('MaxQueue') )
                {
                    if($RunspaceTimeout -ne 0){ $script:MaxQueue = $Throttle }
                    else{ $script:MaxQueue = $Throttle * 3 }
                }
                else
                {
                    $script:MaxQueue = $MaxQueue
                }

                Write-Verbose "Throttle: '$throttle' SleepTimer '$sleepTimer' runSpaceTimeout '$runspaceTimeout' maxQueue '$maxQueue' logFile '$logFile'"

                #If they want to import variables or modules, create a clean runspace, get loaded items, use those to exclude items
                if ($ImportVariables -or $ImportModules)
                {
                    $StandardUserEnv = [powershell]::Create().addscript({

                        #Get modules and snapins in this clean runspace
                        $Modules = Get-Module | Select -ExpandProperty Name
                        $Snapins = Get-PSSnapin | Select -ExpandProperty Name

                        #Get variables in this clean runspace
                        #Called last to get vars like $? into session
                        $Variables = Get-Variable | Select -ExpandProperty Name
                
                        #Return a hashtable where we can access each.
                        @{
                            Variables = $Variables
                            Modules = $Modules
                            Snapins = $Snapins
                        }
                    }).invoke()[0]
            
                    if ($ImportVariables) {
                        #Exclude common parameters, bound parameters, and automatic variables
                        Function _temp {[cmdletbinding()] param() }
                        $VariablesToExclude = @( (Get-Command _temp | Select -ExpandProperty parameters).Keys + $PSBoundParameters.Keys + $StandardUserEnv.Variables )
                        Write-Verbose "Excluding variables $( ($VariablesToExclude | sort ) -join ", ")"

                        # we don't use 'Get-Variable -Exclude', because it uses regexps. 
                        # One of the veriables that we pass is '$?'. 
                        # There could be other variables with such problems.
                        # Scope 2 required if we move to a real module
                        $UserVariables = @( Get-Variable | Where { -not ($VariablesToExclude -contains $_.Name) } ) 
                        Write-Verbose "Found variables to import: $( ($UserVariables | Select -expandproperty Name | Sort ) -join ", " | Out-String).`n"

                    }

                    if ($ImportModules) 
                    {
                        $UserModules = @( Get-Module | Where {$StandardUserEnv.Modules -notcontains $_.Name -and (Test-Path $_.Path -ErrorAction SilentlyContinue)} | Select -ExpandProperty Path )
                        $UserSnapins = @( Get-PSSnapin | Select -ExpandProperty Name | Where {$StandardUserEnv.Snapins -notcontains $_ } ) 
                    }
                }

                #region functions
            
                Function Get-RunspaceData {
                    [cmdletbinding()]
                    param( [switch]$Wait )

                    #loop through runspaces
                    #if $wait is specified, keep looping until all complete
                    Do {

                        #set more to false for tracking completion
                        $more = $false

                        #run through each runspace.           
                        Foreach($runspace in $runspaces) {
                
                            #get the duration - inaccurate
                            $currentdate = Get-Date
                            $runtime = $currentdate - $runspace.startTime
                            $runMin = [math]::Round( $runtime.totalminutes ,2 )

                            #set up log object
                            $log = "" | select Date, Action, Runtime, Status, Details
                            $log.Action = "Removing:'$($runspace.object)'"
                            $log.Date = $currentdate
                            $log.Runtime = "$runMin minutes"

                            #If runspace completed, end invoke, dispose, recycle, counter++
                            If ($runspace.Runspace.isCompleted) {
                        
                                $script:completedCount++
                    
                                #check if there were errors
                                if($runspace.powershell.Streams.Error.Count -gt 0) {
                            
                                    #set the logging info and move the file to completed
                                    $log.status = "CompletedWithErrors"
                                    Write-Verbose ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1]
                                    foreach($ErrorRecord in $runspace.powershell.Streams.Error) {
                                        Write-Error -ErrorRecord $ErrorRecord
                                    }
                                }
                                else {
                            
                                    #add logging details and cleanup
                                    $log.status = "Completed"
                                    Write-Verbose ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1]
                                }

                                #everything is logged, clean up the runspace
                                $runspace.powershell.EndInvoke($runspace.Runspace)
                                $runspace.powershell.dispose()
                                $runspace.Runspace = $null
                                $runspace.powershell = $null

                            }

                            #If runtime exceeds max, dispose the runspace
                            ElseIf ( $runspaceTimeout -ne 0 -and $runtime.totalseconds -gt $runspaceTimeout) {
                        
                                $script:completedCount++
                                $timedOutTasks = $true
                        
                                #add logging details and cleanup
                                $log.status = "TimedOut"
                                Write-Verbose ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1]
                                Write-Error "Runspace timed out at $($runtime.totalseconds) seconds for the object:`n$($runspace.object | out-string)"

                                #Depending on how it hangs, we could still get stuck here as dispose calls a synchronous method on the powershell instance
                                if (!$noCloseOnTimeout) { $runspace.powershell.dispose() }
                                $runspace.Runspace = $null
                                $runspace.powershell = $null
                                $completedCount++

                            }
               
                            #If runspace isn't null set more to true  
                            ElseIf ($runspace.Runspace -ne $null ) {
                                $log = $null
                                $more = $true
                            }

                            #log the results if a log file was indicated
                            if($logFile -and $log){
                                ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1] | out-file $LogFile -append
                            }
                        }

                        #Clean out unused runspace jobs
                        $temphash = $runspaces.clone()
                        $temphash | Where { $_.runspace -eq $Null } | ForEach {
                            $Runspaces.remove($_)
                        }

                        #sleep for a bit if we will loop again
                        if($PSBoundParameters['Wait']){ Start-Sleep -milliseconds $SleepTimer }

                    #Loop again only if -wait parameter and there are more runspaces to process
                    } while ($more -and $PSBoundParameters['Wait'])
            
                #End of runspace function
                }

                #endregion functions
        
                #region Init

                if($PSCmdlet.ParameterSetName -eq 'ScriptFile')
                {
                    $ScriptBlock = [scriptblock]::Create( $(Get-Content $ScriptFile | out-string) )
                }
                elseif($PSCmdlet.ParameterSetName -eq 'ScriptBlock')
                {
                    #Start building parameter names for the param block
                    [string[]]$ParamsToAdd = '$_'
                    if( $PSBoundParameters.ContainsKey('Parameter') )
                    {
                        $ParamsToAdd += '$Parameter'
                    }

                    $UsingVariableData = $Null
            
                    # This code enables $Using support through the AST.
                    # This is entirely from  Boe Prox, and his https://github.com/proxb/PoshRSJob module; all credit to Boe!
            
                    if($PSVersionTable.PSVersion.Major -gt 2)
                    {
                        #Extract using references
                        $UsingVariables = $ScriptBlock.ast.FindAll({$args[0] -is [System.Management.Automation.Language.UsingExpressionAst]},$True)    

                        If ($UsingVariables)
                        {
                            $List = New-Object 'System.Collections.Generic.List`1[System.Management.Automation.Language.VariableExpressionAst]'
                            ForEach ($Ast in $UsingVariables)
                            {
                                [void]$list.Add($Ast.SubExpression)
                            }

                            $UsingVar = $UsingVariables | Group Parent | ForEach {$_.Group | Select -First 1}
    
                            #Extract the name, value, and create replacements for each
                            $UsingVariableData = ForEach ($Var in $UsingVar) {
                                Try
                                {
                                    $Value = Get-Variable -Name $Var.SubExpression.VariablePath.UserPath -ErrorAction Stop
                                    $NewName = ('$__using_{0}' -f $Var.SubExpression.VariablePath.UserPath)
                                    [pscustomobject]@{
                                        Name = $Var.SubExpression.Extent.Text
                                        Value = $Value.Value
                                        NewName = $NewName
                                        NewVarName = ('__using_{0}' -f $Var.SubExpression.VariablePath.UserPath)
                                    }
                                    $ParamsToAdd += $NewName
                                }
                                Catch
                                {
                                    Write-Error "$($Var.SubExpression.Extent.Text) is not a valid Using: variable!"
                                }
                            }

                            $NewParams = $UsingVariableData.NewName -join ', '
                            $Tuple = [Tuple]::Create($list, $NewParams)
                            $bindingFlags = [Reflection.BindingFlags]"Default,NonPublic,Instance"
                            $GetWithInputHandlingForInvokeCommandImpl = ($ScriptBlock.ast.gettype().GetMethod('GetWithInputHandlingForInvokeCommandImpl',$bindingFlags))
    
                            $StringScriptBlock = $GetWithInputHandlingForInvokeCommandImpl.Invoke($ScriptBlock.ast,@($Tuple))

                            $ScriptBlock = [scriptblock]::Create($StringScriptBlock)

                            Write-Verbose $StringScriptBlock
                        }
                    }
            
                    $ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock("param($($ParamsToAdd -Join ", "))`r`n" + $Scriptblock.ToString())
                }
                else
                {
                    Throw "Must provide ScriptBlock or ScriptFile"; Break
                }

                Write-Debug "`$ScriptBlock: $($ScriptBlock | Out-String)"
                Write-Verbose "Creating runspace pool and session states"

                #If specified, add variables and modules/snapins to session state
                $sessionstate = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
                if ($ImportVariables)
                {
                    if($UserVariables.count -gt 0)
                    {
                        foreach($Variable in $UserVariables)
                        {
                            $sessionstate.Variables.Add( (New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $Variable.Name, $Variable.Value, $null) )
                        }
                    }
                }
                if ($ImportModules)
                {
                    if($UserModules.count -gt 0)
                    {
                        foreach($ModulePath in $UserModules)
                        {
                            $sessionstate.ImportPSModule($ModulePath)
                        }
                    }
                    if($UserSnapins.count -gt 0)
                    {
                        foreach($PSSnapin in $UserSnapins)
                        {
                            [void]$sessionstate.ImportPSSnapIn($PSSnapin, [ref]$null)
                        }
                    }
                }

                #Create runspace pool
                $runspacepool = [runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionstate, $Host)
                $runspacepool.Open() 

                Write-Verbose "Creating empty collection to hold runspace jobs"
                $Script:runspaces = New-Object System.Collections.ArrayList        
    
                #If inputObject is bound get a total count and set bound to true
                $global:__bound = $false
                $allObjects = @()
                if( $PSBoundParameters.ContainsKey("inputObject") ){
                    $global:__bound = $true
                }

                #Set up log file if specified
                if( $LogFile ){
                    New-Item -ItemType file -path $logFile -force | Out-Null
                    ("" | Select Date, Action, Runtime, Status, Details | ConvertTo-Csv -NoTypeInformation -Delimiter ";")[0] | Out-File $LogFile
                }

                #write initial log entry
                $log = "" | Select Date, Action, Runtime, Status, Details
                    $log.Date = Get-Date
                    $log.Action = "Batch processing started"
                    $log.Runtime = $null
                    $log.Status = "Started"
                    $log.Details = $null
                    if($logFile) {
                        ($log | convertto-csv -Delimiter ";" -NoTypeInformation)[1] | Out-File $LogFile -Append
                    }

                $timedOutTasks = $false

                #endregion INIT
            }

            Process {
                #add piped objects to all objects or set all objects to bound input object parameter
                if( -not $global:__bound ){
                    $allObjects += $inputObject
                }
                else{
                    $allObjects = $InputObject
                }
            }

            End {
        
                #Use Try/Finally to catch Ctrl+C and clean up.
                Try
                {
                    #counts for progress
                    $totalCount = $allObjects.count
                    $script:completedCount = 0
                    $startedCount = 0

                    foreach($object in $allObjects){
        
                        #region add scripts to runspace pool
                    
                            #Create the powershell instance, set verbose if needed, supply the scriptblock and parameters
                            $powershell = [powershell]::Create()
                    
                            if ($VerbosePreference -eq 'Continue')
                            {
                                [void]$PowerShell.AddScript({$VerbosePreference = 'Continue'})
                            }

                            [void]$PowerShell.AddScript($ScriptBlock).AddArgument($object)

                            if ($parameter)
                            {
                                [void]$PowerShell.AddArgument($parameter)
                            }

                            # $Using support from Boe Prox
                            if ($UsingVariableData)
                            {
                                Foreach($UsingVariable in $UsingVariableData) {
                                    Write-Verbose "Adding $($UsingVariable.Name) with value: $($UsingVariable.Value)"
                                    [void]$PowerShell.AddArgument($UsingVariable.Value)
                                }
                            }

                            #Add the runspace into the powershell instance
                            $powershell.RunspacePool = $runspacepool
    
                            #Create a temporary collection for each runspace
                            $temp = "" | Select-Object PowerShell, StartTime, object, Runspace
                            $temp.PowerShell = $powershell
                            $temp.StartTime = Get-Date
                            $temp.object = $object
    
                            #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
                            $temp.Runspace = $powershell.BeginInvoke()
                            $startedCount++

                            #Add the temp tracking info to $runspaces collection
                            Write-Verbose ( "Adding {0} to collection at {1}" -f $temp.object, $temp.starttime.tostring() )
                            $runspaces.Add($temp) | Out-Null
            
                            #loop through existing runspaces one time
                            Get-RunspaceData

                            #If we have more running than max queue (used to control timeout accuracy)
                            #Script scope resolves odd PowerShell 2 issue
                            $firstRun = $true
                            while ($runspaces.count -ge $Script:MaxQueue) {

                                #give verbose output
                                if($firstRun){
                                    Write-Verbose "$($runspaces.count) items running - exceeded $Script:MaxQueue limit."
                                }
                                $firstRun = $false
                    
                                #run get-runspace data and sleep for a short while
                                Get-RunspaceData
                                Start-Sleep -Milliseconds $sleepTimer
                            }
                        #endregion add scripts to runspace pool
                    }
                     
                    Write-Verbose ( "Finish processing the remaining runspace jobs: {0}" -f ( @($runspaces | Where {$_.Runspace -ne $Null}).Count) )
                    Get-RunspaceData -wait
                }
                Finally
                {
                    #Close the runspace pool, unless we specified no close on timeout and something timed out
                    if ( ($timedOutTasks -eq $false) -or ( ($timedOutTasks -eq $true) -and ($noCloseOnTimeout -eq $false) ) ) {
                        Write-Verbose "Closing the runspace pool"
                        $runspacepool.close()
                    }
                    #collect garbage
                    [gc]::Collect()
                }       
            }
        }

        Write-Verbose "PSBoundParameters = $($PSBoundParameters | Out-String)"
        
        $bound = $PSBoundParameters.keys -contains "ComputerName"
        if(-not $bound)
        {
            [System.Collections.ArrayList]$AllComputers = @()
        }
    }
    Process
    {
        #Handle both pipeline and bound parameter.  We don't want to stream objects, defeats purpose of parallelizing work
        if($bound)
        {
            $AllComputers = $ComputerName
        }
        Else
        {
            foreach($Computer in $ComputerName)
            {
                $AllComputers.add($Computer) | Out-Null
            }
        }
    }
    End
    {
        #Built up the parameters and run everything in parallel
        $params = @()
        $splat = @{
            Throttle = $Throttle
            RunspaceTimeout = $Timeout
            InputObject = $AllComputers
        }
        if($NoCloseOnTimeout)
        {
            $splat.add('NoCloseOnTimeout',$True)
        }

        Invoke-Parallel @splat -ScriptBlock {
            $computer = $_.trim()
            Try
            {
                #Pick out a few properties, add a status label.  If quiet output, just return the address
                $result = $null
                if( $result = @( Test-Connection -ComputerName $computer -Count 1 -erroraction Stop ) )
                {
                    $Output = $result | Select -first 1 -Property Address, IPV4Address, IPV6Address, ResponseTime, @{ label = "STATUS"; expression = {"Responding"} }
                    $Output.address
                }
            }
            Catch
            {
            }
        }
    }
}
function Get-DomainSearcher {
<#
    .SYNOPSIS
        Helper used by various functions that takes an ADSpath and
        domain specifier and builds the correct ADSI searcher object.
    .PARAMETER Domain
        The domain to use for the query, defaults to the current domain.
    .PARAMETER DomainController
        Domain controller to reflect LDAP queries through.
    .PARAMETER ADSpath
        The LDAP source to search through, e.g. "LDAP://OU=secret,DC=testlab,DC=local"
        Useful for OU queries.
    .PARAMETER ADSprefix
        Prefix to set for the searcher (like "CN=Sites,CN=Configuration")
    .PARAMETER PageSize
        The PageSize to set for the LDAP searcher object.
    .EXAMPLE
        PS C:\> Get-DomainSearcher -Domain testlab.local
    .EXAMPLE
        PS C:\> Get-DomainSearcher -Domain testlab.local -DomainController SECONDARY.dev.testlab.local
#>

    [CmdletBinding()]
    param(
        [String]
        $Domain,

        [String]
        $DomainController,

        [String]
        $ADSpath,

        [String]
        $ADSprefix,

        [ValidateRange(1,10000)] 
        [Int]
        $PageSize = 200
    )

    if(!$Domain) {
        $Domain = (Get-NetDomain).name
    }
    else {
        if(!$DomainController) {
            try {
                # if there's no -DomainController specified, try to pull the primary DC
                #   to reflect queries through
                $DomainController = ((Get-NetDomain).PdcRoleOwner).Name
            }
            catch {
                throw "Get-DomainSearcher: Error in retrieving PDC for current domain"
            }
        }
    }

    $SearchString = "LDAP://"

    if($DomainController) {
        $SearchString += $DomainController + "/"
    }
    if($ADSprefix) {
        $SearchString += $ADSprefix + ","
    }

    if($ADSpath) {
        if($ADSpath -like "GC://*") {
            # if we're searching the global catalog
            $DistinguishedName = $AdsPath
            $SearchString = ""
        }
        else {
            if($ADSpath -like "LDAP://*") {
                $ADSpath = $ADSpath.Substring(7)
            }
            $DistinguishedName = $ADSpath
        }
    }
    else {
        $DistinguishedName = "DC=$($Domain.Replace('.', ',DC='))"
    }

    $SearchString += $DistinguishedName
    Write-Verbose "Get-DomainSearcher search string: $SearchString"

    $Searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$SearchString)
    $Searcher.PageSize = $PageSize
    $Searcher
}
function Get-NetComputer {
<#
    .SYNOPSIS
        This function utilizes adsisearcher to query the current AD context
        for current computer objects. Based off of Carlos Perez's Audit.psm1
        script in Posh-SecMod (link below).
    .PARAMETER ComputerName
        Return computers with a specific name, wildcards accepted.
    .PARAMETER SPN
        Return computers with a specific service principal name, wildcards accepted.
    .PARAMETER OperatingSystem
        Return computers with a specific operating system, wildcards accepted.
    .PARAMETER ServicePack
        Return computers with a specific service pack, wildcards accepted.
    .PARAMETER Filter
        A customized ldap filter string to use, e.g. "(description=*admin*)"
    .PARAMETER Printers
        Switch. Return only printers.
    .PARAMETER Ping
        Switch. Ping each host to ensure it's up before enumerating.
    .PARAMETER FullData
        Switch. Return full computer objects instead of just system names (the default).
    .PARAMETER Domain
        The domain to query for computers, defaults to the current domain.
    .PARAMETER DomainController
        Domain controller to reflect LDAP queries through.
    .PARAMETER ADSpath
        The LDAP source to search through, e.g. "LDAP://OU=secret,DC=testlab,DC=local"
        Useful for OU queries.
    .PARAMETER Unconstrained
        Switch. Return computer objects that have unconstrained delegation.
    .PARAMETER PageSize
        The PageSize to set for the LDAP searcher object.
    .EXAMPLE
        PS C:\> Get-NetComputer
        
        Returns the current computers in current domain.
    .EXAMPLE
        PS C:\> Get-NetComputer -SPN mssql*
        
        Returns all MS SQL servers on the domain.
    .EXAMPLE
        PS C:\> Get-NetComputer -Domain testing
        
        Returns the current computers in 'testing' domain.
    .EXAMPLE
        PS C:\> Get-NetComputer -Domain testing -FullData
        
        Returns full computer objects in the 'testing' domain.
    .LINK
        https://github.com/darkoperator/Posh-SecMod/blob/master/Audit/Audit.psm1
#>

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True)]
        [Alias('HostName')]
        [String]
        $ComputerName = '*',

        [String]
        $SPN,

        [String]
        $OperatingSystem,

        [String]
        $ServicePack,

        [String]
        $Filter,

        [Switch]
        $Printers,

        [Switch]
        $Ping,

        [Switch]
        $FullData,

        [String]
        $Domain,

        [String]
        $DomainController,

        [String]
        $ADSpath,

        [Switch]
        $Unconstrained,

        [ValidateRange(1,10000)] 
        [Int]
        $PageSize = 200
    )

    begin {
        # so this isn't repeated if users are passed on the pipeline
        $CompSearcher = Get-DomainSearcher -Domain $Domain -DomainController $DomainController -ADSpath $ADSpath -PageSize $PageSize
    }

    process {

        if ($CompSearcher) {

            # if we're checking for unconstrained delegation
            if($Unconstrained) {
                Write-Verbose "Searching for computers with for unconstrained delegation"
                $Filter += "(userAccountControl:1.2.840.113556.1.4.803:=524288)"
            }
            # set the filters for the seracher if it exists
            if($Printers) {
                Write-Verbose "Searching for printers"
                # $CompSearcher.filter="(&(objectCategory=printQueue)$Filter)"
                $Filter += "(objectCategory=printQueue)"
            }
            if($SPN) {
                Write-Verbose "Searching for computers with SPN: $SPN"
                $Filter += "(servicePrincipalName=$SPN)"
            }
            if($OperatingSystem) {
                $Filter += "(operatingsystem=$OperatingSystem)"
            }
            if($ServicePack) {
                $Filter += "(operatingsystemservicepack=$ServicePack)"
            }

            $CompSearcher.filter = "(&(sAMAccountType=805306369)(dnshostname=$ComputerName)$Filter)"

            try {

                $CompSearcher.FindAll() | Where-Object {$_} | ForEach-Object {
                    $Up = $True
                    if($Ping) {
                        # TODO: how can these results be piped to ping for a speedup?
                        $Up = Test-Connection -Count 1 -Quiet -ComputerName $_.properties.dnshostname
                    }
                    if($Up) {
                        # return full data objects
                        if ($FullData) {
                            # convert/process the LDAP fields for each result
                            Convert-LDAPProperty -Properties $_.Properties
                        }
                        else {
                            # otherwise we're just returning the DNS host name
                            $_.properties.dnshostname
                        }
                    }
                }
            }
            catch {
                Write-Warning "Error: $_"
            }
        }
    }
}
function Convert-LDAPProperty {
    # helper to convert specific LDAP property result fields
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [ValidateNotNullOrEmpty()]
        $Properties
    )

    $ObjectProperties = @{}

    $Properties.PropertyNames | ForEach-Object {
        if (($_ -eq "objectsid") -or ($_ -eq "sidhistory")) {
            # convert the SID to a string
            $ObjectProperties[$_] = (New-Object System.Security.Principal.SecurityIdentifier($Properties[$_][0],0)).Value
        }
        elseif($_ -eq "objectguid") {
            # convert the GUID to a string
            $ObjectProperties[$_] = (New-Object Guid (,$Properties[$_][0])).Guid
        }
        elseif( ($_ -eq "lastlogon") -or ($_ -eq "lastlogontimestamp") -or ($_ -eq "pwdlastset") -or ($_ -eq "lastlogoff") -or ($_ -eq "badPasswordTime") ) {
            # convert timestamps
            if ($Properties[$_][0] -is [System.MarshalByRefObject]) {
                # if we have a System.__ComObject
                $Temp = $Properties[$_][0]
                [Int32]$High = $Temp.GetType().InvokeMember("HighPart", [System.Reflection.BindingFlags]::GetProperty, $null, $Temp, $null)
                [Int32]$Low  = $Temp.GetType().InvokeMember("LowPart",  [System.Reflection.BindingFlags]::GetProperty, $null, $Temp, $null)
                $ObjectProperties[$_] = ([datetime]::FromFileTime([Int64]("0x{0:x8}{1:x8}" -f $High, $Low)))
            }
            else {
                $ObjectProperties[$_] = ([datetime]::FromFileTime(($Properties[$_][0])))
            }
        }
        elseif($Properties[$_][0] -is [System.MarshalByRefObject]) {
            # convert misc com objects
            $Prop = $Properties[$_]
            try {
                $Temp = $Prop[$_][0]
                Write-Verbose $_
                [Int32]$High = $Temp.GetType().InvokeMember("HighPart", [System.Reflection.BindingFlags]::GetProperty, $null, $Temp, $null)
                [Int32]$Low  = $Temp.GetType().InvokeMember("LowPart",  [System.Reflection.BindingFlags]::GetProperty, $null, $Temp, $null)
                $ObjectProperties[$_] = [Int64]("0x{0:x8}{1:x8}" -f $High, $Low)
            }
            catch {
                $ObjectProperties[$_] = $Prop[$_]
            }
        }
        elseif($Properties[$_].count -eq 1) {
            $ObjectProperties[$_] = $Properties[$_][0]
        }
        else {
            $ObjectProperties[$_] = $Properties[$_]
        }
    }

    New-Object -TypeName PSObject -Property $ObjectProperties
}
function Get-NetDomain {
<#
    .SYNOPSIS
        Returns a given domain object.
    .PARAMETER Domain
        The domain name to query for, defaults to the current domain.
    .EXAMPLE
        PS C:\> Get-NetDomain -Domain testlab.local
    .LINK
        http://social.technet.microsoft.com/Forums/scriptcenter/en-US/0c5b3f83-e528-4d49-92a4-dee31f4b481c/finding-the-dn-of-the-the-domain-without-admodule-in-powershell?forum=ITCG
#>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        [String]
        $Domain
    )

    process {
        if($Domain) {
            $DomainContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Domain', $Domain)
            try {
                [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($DomainContext)
            }
            catch {
                Write-Warning "The specified domain $Domain does not exist, could not be contacted, or there isn't an existing trust."
                $Null
            }
        }
        else {
            [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
        }
    }
}



