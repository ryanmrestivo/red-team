# Shields Up!
# This simple script disables ALL radios - be they wireless, wired, Bluetooth, etc.
# This is handy for instances where you think a machine might be compromised and you want to
# ensure it doesn't talk to anything else on any other networks.

Disable-NetAdapter -Name * -Confirm:$false
Write-Output ""
Write-Output "The interfaces - such as wired/wireless/Bluetooth - are now all disabled."
Write-Output "This script will halt now."
Write-Output "Press Enter to re-enable all interfaces, or exit this script to keep interfaces disabled."
Write-Output ""
pause
Enable-NetAdapter -Name * -Confirm:$false
Write-Output "All interfaces are now enabled."
