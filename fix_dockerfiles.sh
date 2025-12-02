#!/bin/bash
# Fix Dockerfiles to use correct paths

set -e

echo "🔧 Fixing Dockerfiles to use correct context paths..."

# Fix dovecot Dockerfile
echo "Fixing Dockerfiles/dovecot/Dockerfile..."
cat > /app/Dockerfiles/dovecot/Dockerfile << 'EOF'
FROM debian:bookworm-slim

LABEL maintainer="https://github.com/aaPanel/TetrisNewsEmailing"

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
EOF

# Fix postfix Dockerfile
echo "Fixing Dockerfiles/postfix/Dockerfile..."
sed -i 's|^COPY stop-supervisor.sh|COPY Dockerfiles/postfix/stop-supervisor.sh|g' /app/Dockerfiles/postfix/Dockerfile
sed -i 's|^COPY postfix.sh|COPY Dockerfiles/postfix/postfix.sh|g' /app/Dockerfiles/postfix/Dockerfile
sed -i 's|^COPY rotate_log.sh|COPY Dockerfiles/postfix/rotate_log.sh|g' /app/Dockerfiles/postfix/Dockerfile
sed -i 's|^COPY supervisord.conf|COPY Dockerfiles/postfix/supervisord.conf|g' /app/Dockerfiles/postfix/Dockerfile

# Fix rspamd Dockerfile
echo "Fixing Dockerfiles/rspamd/Dockerfile..."
sed -i 's|^COPY stop-supervisor.sh|COPY Dockerfiles/rspamd/stop-supervisor.sh|g' /app/Dockerfiles/rspamd/Dockerfile
sed -i 's|^COPY rspamd.sh|COPY Dockerfiles/rspamd/rspamd.sh|g' /app/Dockerfiles/rspamd/Dockerfile
sed -i 's|^COPY rotate_log.sh|COPY Dockerfiles/rspamd/rotate_log.sh|g' /app/Dockerfiles/rspamd/Dockerfile
sed -i 's|^COPY supervisord.conf|COPY Dockerfiles/rspamd/supervisord.conf|g' /app/Dockerfiles/rspamd/Dockerfile

echo "✅ Dockerfiles fixed!"
echo ""
echo "Now you can run: docker compose build"
EOF

chmod +x /app/fix_dockerfiles.sh
bash /app/fix_dockerfiles.sh
