#!/bin/sh

set -e

if [ -z "${MYHOSTNAME}" -o -z "${MYDOMAIN}" ]; then
  echo "MYHOSTNAME and MYDOAIN are required" >&2
  exit 1
fi
echo "Create data directory" >&2
mkdir -p /var/postfix/spool /var/postfix/lib
chown postfix:postfix /var/postfix/lib

echo "Create Postfix settings /etc/postfix/main.cf" >&2
cat <<-EOF > /etc/postfix/main.cf
myhostname = $MYHOSTNAME
mydomain = $MYDOMAIN
myorigin = \$mydomain
smtpd_relay_restrictions = permit_mynetworks defer_unauth_destination
mynetworks = 127.0.0.1/32 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8
queue_directory = /var/postfix/spool
data_directory = /var/postfix/lib
# --- original main.cf
compatibility_level = 2
command_directory = /usr/sbin
daemon_directory = /usr/libexec/postfix
mail_owner = postfix
unknown_local_recipient_reject_code = 550
debug_peer_level = 2
debugger_command =
	 PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin
	 ddd $daemon_directory/$process_name $process_id & sleep 5
sendmail_path = /usr/sbin/sendmail
newaliases_path = /usr/bin/newaliases
mailq_path = /usr/bin/mailq
setgid_group = postdrop
html_directory = no
manpage_directory = /usr/share/man
sample_directory = /etc/postfix
readme_directory = /usr/share/doc/postfix/readme
inet_protocols = ipv4
meta_directory = /etc/postfix
shlib_directory = /usr/lib/postfix
EOF

if [ -n "$RELAY_TO" ]; then
  echo "Create Postfix relay settings /etc/postfix/main.cf" >&2
  cat <<-EOF >> /etc/postfix/main.cf
# Relay settings with sasl
relayhost = ${RELAY_TO}
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/smtp_pass
smtp_sasl_mechanism_filter = plain,login
smtp_sasl_security_options = noanonymous
smtp_tls_security_level = encrypt
smtp_tls_wrappermode = yes
smtp_tls_loglevel = 1
smtp_tls_CApath = /etc/pki/tls/certs/ca-bundle.crt
EOF
fi

if [ -n "$RELAY_TO" -a -n "$RELAY_USERNAME" -a -n "$RELAY_PASSWORD" ]; then
  echo "Create Postfix relay sasl settings /etc/postfix/main.cf" >&2
  cat <<-EOF > /etc/postfix/smtp_pass
${RELAY_TO} ${RELAY_USERNAME}:${RELAY_PASSWORD}
EOF
  postmap hash:/etc/postfix/smtp_pass
fi

echo "Call newaliases" >&2
newaliases
echo "Up rsyslogd" >&2
rsyslogd
trap_TERM() {
  kill `cat /var/run/rsyslogd.pid`
  exit 0
}
echo "Set trap" >&2
trap 'trap_TERM' TERM

echo "Up postfix" >&2
/usr/sbin/postfix start

echo "Tail postfix log" >&2
tail -f /var/log/mail.log

