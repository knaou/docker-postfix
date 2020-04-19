FROM alpine

RUN apk add --no-cache postfix rsyslog cyrus-sasl cyrus-sasl-plain cyrus-sasl-login
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

COPY startup.sh /startup.sh
EXPOSE 25
CMD ["/startup.sh"]
