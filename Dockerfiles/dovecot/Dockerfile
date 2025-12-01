FROM debian:bookworm-slim

LABEL maintainer="https://github.com/aaPanel/BillionMail"

ARG DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C

## Copy file
COPY Dockerfiles/dovecot/stop-supervisor.sh /stop-supervisor.sh
COPY Dockerfiles/dovecot/dovecot.sh /dovecot.sh
COPY Dockerfiles/dovecot/rotate_log.sh /rotate_log.sh

# COPY debian.sources /etc/apt/sources.list.d/debian.sources

# install dovecot
RUN apt-get update && apt-get install -y --no-install-recommends --allow-downgrades --allow-remove-essential --allow-change-held-packages \
        dovecot-core \
        dovecot-dev \
        dovecot-pop3d \
        dovecot-imapd \
        dovecot-lmtpd \
        dovecot-pgsql \
        dovecot-sieve \
        dovecot-ldap \
        sasl2-bin \
        libsasl2-modules \
        postgresql-client \
        ca-certificates \
        curl \
        sudo \
        supervisor \
        rsyslog \
        tzdata \
        telnet \
        cron \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        && mkdir -p /usr/lib/dovecot/sieve \
        && chmod +x /stop-supervisor.sh /dovecot.sh /rotate_log.sh


## Copy the supervisord configuration file
COPY Dockerfiles/dovecot/supervisord.conf /etc/supervisor/supervisord.conf

COPY Dockerfiles/dovecot/spam-to-folder.sieve /usr/lib/dovecot/sieve/spam-to-folder.sieve
COPY Dockerfiles/dovecot/report-spam.sieve /usr/lib/dovecot/sieve/report-spam.sieve
COPY Dockerfiles/dovecot/report-ham.sieve /usr/lib/dovecot/sieve/report-ham.sieve
COPY Dockerfiles/dovecot/sa-learn-spam.sh /usr/lib/dovecot/sieve/sa-learn-spam.sh
COPY Dockerfiles/dovecot/sa-learn-ham.sh /usr/lib/dovecot/sieve/sa-learn-ham.sh

ENTRYPOINT ["/dovecot.sh"]
# EXPOSE 110 143 993 995

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
