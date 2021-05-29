# $ASRPIP = '10.11.12.13'

#Obtain Azure MetaData Instance
$ASRPIP = Invoke-RestMethod -Method GET -Uri http://169.254.169.254/metadata/instance?api-version=2017-04-02 -Headers @{"Metadata"="True"}

#Opbtain Public IP Address assigned
$ASRPIP = $ASRPIP.network.interface.ipv4.ipaddress.publicipaddress

#Create a backup file
Copy-Item -Path "C:\Program Files (x86)\FileZilla Server\fileZilla Server.xml" -Destination "C:\Program Files (x86)\FileZilla Server\FileZilla Server.xml.bkp" -Force

#Restore from backup
## Copy-Item -Path "C:\Program Files (x86)\FileZilla Server\fileZilla Server.xml.bkp" -Destination "C:\Program Files (x86)\FileZilla Server\FileZilla Server.xml" -Force

# path of XML config for FileZilla Server
$path = 'C:\Program Files (x86)\FileZilla Server\fileZilla Server.xml'

# Obtain XML config as a object 
[xml]$xml = (Get-Content $path)

# Specific public ip setting is on line 12 
## $xml.FileZillaServer.Settings.Item[12].InnerText

# Create a variable to replace the public ip address from the parameter passed into script     
$node = $xml.FileZillaServer.Settings.Item[12]

# replace
$node.'#text' = $ASRPIP

# Save update changes
$xml.Save($path)

# Restart Service
Restart-Service "FileZilla Server"