#!/bin/bash

echo "================================"
echo "BillionMail RoundCube Diagnostics"
echo "================================"
echo ""

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found!"
    exit 1
fi

echo "1. Checking Docker Services Status..."
echo "-------------------------------------"
docker-compose ps 2>/dev/null || docker compose ps 2>/dev/null

echo ""
echo "2. Checking RoundCube Container Logs (last 30 lines)..."
echo "-------------------------------------"
docker-compose logs --tail=30 webmail-billionmail 2>/dev/null || docker compose logs --tail=30 webmail-billionmail 2>/dev/null

echo ""
echo "3. Checking Dovecot Container Logs (last 30 lines)..."
echo "-------------------------------------"
docker-compose logs --tail=30 dovecot-billionmail 2>/dev/null || docker compose logs --tail=30 dovecot-billionmail 2>/dev/null

echo ""
echo "4. Checking PostgreSQL Database for Mail Accounts..."
echo "-------------------------------------"
docker-compose exec -T pgsql-billionmail psql -U billionmail -d billionmail -c "SELECT username, domain, active FROM mailbox LIMIT 10;" 2>/dev/null || \
docker compose exec -T pgsql-billionmail psql -U billionmail -d billionmail -c "SELECT username, domain, active FROM mailbox LIMIT 10;" 2>/dev/null

echo ""
echo "5. Checking RoundCube Configuration..."
echo "-------------------------------------"
if [ -f "conf/webmail/custom.inc.php" ]; then
    cat conf/webmail/custom.inc.php
else
    echo "Configuration file not found!"
fi

echo ""
echo "6. Testing IMAP Connection to Dovecot..."
echo "-------------------------------------"
docker-compose exec -T dovecot-billionmail nc -zv localhost 143 2>&1 || \
docker compose exec -T dovecot-billionmail nc -zv localhost 143 2>&1

echo ""
echo "================================"
echo "Diagnostics Complete"
echo "================================"
