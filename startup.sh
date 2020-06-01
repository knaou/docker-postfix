#!/bin/sh

set -e

if [ -z "${MYHOSTNAME}" -o -z "${MYDOMAIN}" ]; then
  echo "MYHOSTNAME and MYDOAIN are required" >&2
  exit 1
fi
# RELAY_TO
if "${USE_AUTH:-false}"; then
  export USE_AUTH_FLAG="on"
else
  export USE_AUTH_FLAG=
fi
if "${USE_TLS:-false}"; then
  export USE_TLS_FLAG="on"
else
  export USE_TLS_FLAG=
fi

echo "Create data directory" >&2
mkdir -p /var/postfix/spool /var/postfix/lib
chown postfix:postfix /var/postfix/lib

echo "Create Postfix settings /etc/postfix/main.cf" >&2
mo /usr/share/templates/postfix-main.cf > /etc/postfix/main.cf

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

