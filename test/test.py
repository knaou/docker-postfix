from email.mime.text import MIMEText
from email.utils import formatdate
import smtplib

f = "piyo@example.com"
t = "hoge@example.com"

msg = MIMEText("Hoge")
msg['Subject'] = "Subject"
msg['From'] = f
msg['To'] = t
msg['Date'] = formatdate()

smtpobj = smtplib.SMTP('postfix', 25)
smtpobj.sendmail(f, [t], msg.as_string())
smtpobj.close()

