#!/bin/bash
# Diagnose network configuration issues

echo "=== Docker Network Diagnosis ==="
echo ""

echo "1. Current Docker Networks:"
docker network ls
echo ""

echo "2. Network IP Ranges in Use:"
docker network ls --format "{{.Name}}" | xargs -I {} sh -c 'docker network inspect {} --format "{{.Name}}: {{range .IPAM.Config}}{{.Subnet}} {{end}}" 2>/dev/null'
echo ""

echo "3. Checking .env file (if in BillionMail directory):"
if [ -f ".env" ]; then
    echo "IPV4_NETWORK setting:"
    grep "^IPV4_NETWORK=" .env || echo "NOT FOUND"
    echo ""
    echo "TETRISNEWSEMAILING_HOSTNAME setting:"
    grep "^TETRISNEWSEMAILING_HOSTNAME=" .env || echo "NOT FOUND"
else
    echo ".env file not found in current directory"
fi
echo ""

echo "4. Available Network Ranges (suggestions):"
echo "   - 172.22.1.0/24 (recommended)"
echo "   - 172.23.1.0/24"
echo "   - 172.24.1.0/24"
echo "   - 10.10.1.0/24"
echo ""

echo "5. Quick Fix Commands:"
echo "   sed -i 's/^IPV4_NETWORK=.*/IPV4_NETWORK=172.22.1/' .env"
echo "   docker compose up -d"
