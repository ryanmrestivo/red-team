## Futures

# Create as a Function to run
# Remove Interactive GUI Prompts \ replace with prompts or params to pass
# Allow Selection of Subscription to check against

Login-AzureRmAccount

$deployloc = (Get-AzureRmLocation | Where-Object Providers -contains 'Microsoft.Compute').Location | Out-GridView -PassThru
##Manual Select Var
#$deployloc = "East US"

$vmSize = Get-AzureRmVMSize -Location $deployloc | Out-GridView -PassThru | Select Name,NumberofCores
##Manual Select Var
#$vmSize = "Standard_A8"

do {
  write-host -nonewline "Enter number of VMs - " $vmSize "__:"
  $inputString = read-host
  $value = $inputString -as [Double]
  $ok = $value -ne $NULL
  if ( -not $ok ) { write-host "You must enter a numeric value" }
}
until ( $ok )
##Manual Select Var
#$value = "4"


$vmFamSize = ($vmSize).Name

$vmFamSizeCount = ($vmSize).NumberofCores

$totalvmFamSizeCount = $vmFamSizeCount * $value


# Define Hashtables for switch lookup rather than IF
$vmFamSize = switch ($vmFamSize) 
    { 
	Basic_A0 {"Basic A Family Cores"}
    Basic_A1 {"Basic A Family Cores"}
    Basic_A2 {"Basic A Family Cores"}
    Basic_A3 {"Basic A Family Cores"}
    Basic_A4 {"Basic A Family Cores"}
    Standard_A0 {"Standard A0-A7 Family Cores"}
    Standard_A1 {"Standard A0-A7 Family Cores"}
    Standard_A2 {"Standard A0-A7 Family Cores"}
    Standard_A3 {"Standard A0-A7 Family Cores"}
    Standard_A4 {"Standard A0-A7 Family Cores"}
    Standard_A5 {"Standard A0-A7 Family Cores"}
    Standard_A6 {"Standard A0-A7 Family Cores"}
    Standard_A7 {"Standard A0-A7 Family Cores"}
    Standard_A8 {"Standard A8-A11 Family Cores"}
    Standard_A9 {"Standard A8-A11 Family Cores"}
    Standard_A10 {"Standard A8-A11 Family Cores"}
    Standard_A11 {"Standard A8-A11 Family Cores"}
    Standard_A1_v2 {"Standard Av2 Family Cores"}
    Standard_A2_v2 {"Standard Av2 Family Cores"}
    Standard_A4_v2 {"Standard Av2 Family Cores"}
    Standard_A8_v2 {"Standard Av2 Family Cores"}
    Standard_A2m_v2 {"Standard Av2 Family Cores"}
    Standard_A4m_v2 {"Standard Av2 Family Cores"} 
    Standard_A8m_v2 {"Standard Av2 Family Cores"} 
    Standard_D1 {"Standard D Family Cores"}
    Standard_D2 {"Standard D Family Cores"}
    Standard_D3 {"Standard D Family Cores"}
    Standard_D4 {"Standard D Family Cores"}
    Standard_D11 {"Standard D Family Cores"}
    Standard_D12 {"Standard D Family Cores"}
    Standard_D13 {"Standard D Family Cores"}
    Standard_D14 {"Standard D Family Cores"}
    Standard_D1_v2 {"Standard Dv2 Family Cores"}
    Standard_D2_v2 {"Standard Dv2 Family Cores"}
    Standard_D3_v2 {"Standard Dv2 Family Cores"}
    Standard_D4_v2 {"Standard Dv2 Family Cores"}
    Standard_D5_v2 {"Standard Dv2 Family Cores"}
    Standard_D11_v2 {"Standard Dv2 Family Cores"}
    Standard_D12_v2 {"Standard Dv2 Family Cores"}
    Standard_D13_v2 {"Standard Dv2 Family Cores"}
    Standard_D14_v2 {"Standard Dv2 Family Cores"}
    Standard_D15_v2 {"Standard Dv2 Family Cores"}
    Standard_DS1 {"Standard DS Family Cores"}
    Standard_DS2 {"Standard DS Family Cores"}
    Standard_DS3 {"Standard DS Family Cores"}
    Standard_DS4 {"Standard DS Family Cores"}
    Standard_DS11 {"Standard DS Family Cores"}
    Standard_DS12 {"Standard DS Family Cores"}
    Standard_DS13 {"Standard DS Family Cores"}
    Standard_DS14 {"Standard DS Family Cores"}
    Standard_DS2_v2 {"Standard DSv2 Family Cores"}
    Standard_DS3_v2 {"Standard DSv2 Family Cores"}
    Standard_DS4_v2 {"Standard DSv2 Family Cores"}
    Standard_DS5_v2 {"Standard DSv2 Family Cores"} 
    Standard_DS11_v2 {"Standard DSv2 Family Cores"} 
    Standard_DS12_v2 {"Standard DSv2 Family Cores"} 
    Standard_DS13_v2 {"Standard DSv2 Family Cores"} 
    Standard_DS14_v2 {"Standard DSv2 Family Cores"} 
    Standard_DS15_v2 {"Standard DSv2 Family Cores"}
    Standard_F1 {"Standard F Family Cores"}
    Standard_F2 {"Standard F Family Cores"}
    Standard_F4 {"Standard F Family Cores"} 
    Standard_F8 {"Standard F Family Cores"} 
    Standard_F16 {"Standard F Family Cores"}
    Standard_F1s {"Standard FS Family Cores"}
    Standard_F2s {"Standard FS Family Cores"}
    Standard_F4s {"Standard FS Family Cores"} 
    Standard_F8s {"Standard FS Family Cores"} 
    Standard_F16s {"Standard FS Family Cores"}
    Standard_G1 {"Standard G Family Cores"} 
    Standard_G2 {"Standard G Family Cores"}
    Standard_G3 {"Standard G Family Cores"} 
    Standard_G4 {"Standard G Family Cores"} 
    Standard_G5 {"Standard G Family Cores"}
    Standard_GS1 {"Standard GS Family Cores"} 
    Standard_GS2 {"Standard GS Family Cores"}
    Standard_GS3 {"Standard GS Family Cores"} 
    Standard_GS4 {"Standard GS Family Cores"} 
    Standard_GS5 {"Standard GS Family Cores"}
    Standard_H8 {"Standard H Family Cores"}
    Standard_H16 {"Standard H Family Cores"} 
    Standard_H8m {"Standard H Family Cores"}
    Standard_H16m {"Standard H Family Cores"} 
    Standard_H16r {"Standard H Family Cores"}
    Standard_H16mr {"Standard H Family Cores"}
    Standard_L4s {"Standard LS Family Cores"}
    Standard_L8s {"Standard LS Family Cores"} 
    Standard_L16s {"Standard LS Family Cores"} 
    Standard_L32s {"Standard LS Family Cores"}
    Standard_NC6 {"Standard NC Family Cores"} 
    Standard_NC12 {"Standard NC Family Cores"} 
    Standard_NC24 {"Standard NC Family Cores"} 
    Standard_NC24r {"Standard NC Family Cores"}
    Standard_NV6 {"Standard NV Family Cores"}
    Standard_NV12 {"Standard NV Family Cores"} 
    Standard_NV24 {"Standard NV Family Cores"}
    default {"Unknown Please Investigate"}
}


$currentusage = Get-AzureRmVMUsage -Location $deployloc

$currentusage = $currentusage | where-object {$vmFamSize -Like $_.Name.LocalizedValue}

$currentusagecount = $currentusage.Limit - $currentusage.CurrentValue

if ($totalvmFamSizeCount -le $currentusagecount){
    Write-Host -ForegroundColor Green "We will use" $totalvmFamSizeCount "out of avaliable" $currentusagecount "Cores"
    $newtotal = $currentusagecount - $totalvmFamSizeCount
    Write-Host " "
    Write-Host -ForegroundColor Green "We are good to go after deployment" $newtotal $currentusage.Name.LocalizedValue "remain"
}
Else {
    $newtotal = $currentusagecount - $totalvmFamSizeCount
    Write-Host -ForegroundColor Red $currentusage.Name.LocalizedValue "required exceeds cores avaliable, submit a ticket to increase cores at a minimium of" $newtotal
}