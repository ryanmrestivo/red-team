Param
(
  #[Parameter (Mandatory= $true)]
  #[String] $publicip = "",
  
  #[Parameter (Mandatory= $false)]
  #[String] $action = "",

  #[Parameter (Mandatory= $false)]
  #[String] $direction = "",

  #[Parameter (Mandatory= $false)]
  #[String] $protocol = "",

  #[Parameter (Mandatory= $false)]
  #[String] $source = ""

)

$guid = New-Guid
$logfile = $guid.Guid + "csesqlfw.log"
Start-Transcript C:\temp\$logfile

New-NetFirewallRule -Name Allow_Ping -DisplayName “Allow Ping”`

  -Description “Packet Internet Groper ICMPv4” `

  -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow `

  -Debug
  
 Stop-Transcript
