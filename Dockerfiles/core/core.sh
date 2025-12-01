#!/bin/bash

if [ -f "/opt/tetrisnewsemailing/.env" ]; then
    if ! grep -q "ADMIN_USERNAME" /opt/tetrisnewsemailing/.env; then
        ADMIN_USERNAME=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 8)

        # Default administrator account password 
        echo "ADMIN_USERNAME=${ADMIN_USERNAME}" >> /opt/tetrisnewsemailing/.env
    fi

    if ! grep -q "ADMIN_PASSWORD" /opt/tetrisnewsemailing/.env; then
        ADMIN_PASSWORD=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 8)
        # Default administrator account password 
        echo "ADMIN_PASSWORD=${ADMIN_PASSWORD}" >> /opt/tetrisnewsemailing/.env
    fi
fi

# Generate DH params
if [ ! -f "/etc/ssl/mail/dh.pem" ]; then
    cp -d -n /etc/ssl/ssl-self-signed/* /etc/ssl/mail/
fi

# # Generate DH params
# if [ ! -f "/etc/ssl/mail/dh.pem" ]; then
#     openssl dhparam -out /etc/ssl/mail/dh.pem 2048
# fi

# Remove defaults-debian.conf
if [ -f "/etc/fail2ban/jail.d/defaults-debian.conf" ]; then
    rm -f /etc/fail2ban/jail.d/defaults-debian.conf
fi


## Initialize fail2ban when y, otherwise delete the rule
# Enable fail2ban Access restrictions, specify that the IP exceeds the access limit
if [[ ${FAIL2BAN_INIT} == "y" ]]; then
    ## Copy fail2ban Jail
    cp -rf /opt/tetrisnewsemailing/conf/core/fail2ban_init/jail.d/*-accesslimit.conf /etc/fail2ban/jail.d/

    if ! grep -q "restart_fail2ban.sh" /var/spool/cron/crontabs/root; then
        chmod +x /restart_fail2ban.sh
        echo "02 0,12 * * * bash /restart_fail2ban.sh" >> /var/spool/cron/crontabs/root
        chmod 600 /var/spool/cron/crontabs/root
        chown root:crontab /var/spool/cron/crontabs/root    
        pkill -9 crond
    fi
    bash /restart_fail2ban.sh

else
    rm -f /etc/fail2ban/jail.d/*-accesslimit.conf
    echo -e "fail2ban: delete the rule"
fi

## Copy fail2ban Filter
# if [ ! -f "/etc/fail2ban/filter.d/core-limit-filter.conf" ]; then
#     cp -f /opt/tetrisnewsemailing/conf/core/fail2ban_init/filter.d/core-limit-filter.conf /etc/fail2ban/filter.d/core-limit-filter.conf
# fi
cp -rf /opt/tetrisnewsemailing/conf/core/fail2ban_init/filter.d/*.conf /etc/fail2ban/filter.d/

if [ ! -d "/opt/tetrisnewsemailing/core/template/" ]; then
    mkdir /opt/tetrisnewsemailing/core/template
fi

if [ ! -d "/opt/tetrisnewsemailing/core/logs/" ]; then
    mkdir /opt/tetrisnewsemailing/core/logs
fi

if [ ! -f "/opt/tetrisnewsemailing/core/logs/access-$(date -u +"%Y%m%d").log" ]; then
    touch /opt/tetrisnewsemailing/core/logs/access-$(date -u +"%Y%m%d").log
fi

cd /opt/tetrisnewsemailing/core/
chmod +x tetrisnewsemailing


exec "$@"