FROM alpine

RUN apk add --no-cache bash postfix rsyslog cyrus-sasl cyrus-sasl-plain cyrus-sasl-login
ADD https://git.io/get-mo /usr/local/bin/mo
RUN chmod +x /usr/local/bin/mo

RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf
COPY postfix-main.cf /usr/share/templates/postfix-main.cf

COPY startup.sh /startup.sh
EXPOSE 25
VOLUME ["/var/postfix"]
VOLUME ["/var/log"]
CMD ["/startup.sh"]

