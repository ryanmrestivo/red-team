Function Invoke-Assembly {
<#
    .SYNOPSIS

        Loads the compiled .NET code stored in the $asm_data variable and executes the
        Main() method. Arguments can be passed to the loaded assembly.
        Powershell port of https://gitlab.com/KevinJClark/csharper

    .EXAMPLE

        This script is not meant to be run outside of Empire. Instead, use
        the standalone version found here:
        https://gitlab.com/KevinJClark/csharptoolbox/-/blob/master/Invoke-Assembly.ps1

    .LINK

        https://www.mike-gualtieri.com/posts/red-team-tradecraft-loading-encrypted-c-sharp-assemblies-in-memory
#>
	[CmdletBinding()]
		Param (		
			[Parameter()]
			[String[]]$Arguments = ""
	)
	$foundMain = $false
	$asm_data = "~~ASSEMBLY~~"
	try {
		$assembly = [Reflection.Assembly]::Load([Convert]::FromBase64String($asm_data))
	}
	catch {
		Write-Output "[!] Could not load assembly. Is it in COFF/MSIL/.NET format?"
		throw
	}
	foreach($type in $assembly.GetExportedTypes()) {
		foreach($method in $type.GetMethods()) {
			if($method.Name -eq "Main") {
				$foundMain = $true
				if($Arguments[0] -eq "") {
					Write-Output "Attempting to load assembly with no arguments"
				}
				else {
					Write-Output "Attempting to load assembly with arguments: $Arguments"
				}
				$a = (,[String[]]@($Arguments))

				$prevConOut = [Console]::Out
				$sw = [IO.StringWriter]::New()
				[Console]::SetOut($sw)

				try {
					$method.Invoke($null, $a)
				}
				catch {
					Write-Output "[!] Could not invoke assembly or program crashed during execution"
					throw
				}

				[Console]::SetOut($PrevConOut)
				$output = $sw.ToString()
				Write-Output $output
			}
		}
	}
	if(!$foundMain) {
		Write-Output "[!] Could not find public Main() function. Did you set the namespace as public?"
		throw
	}
}
