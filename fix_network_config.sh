#!/bin/bash
# Fix network configuration issue

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Fixing Network Configuration Issue          ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please run this script from your BillionMail directory"
    exit 1
fi

echo -e "${YELLOW}Step 1: Checking current network configuration...${NC}"

# Show current IPV4_NETWORK value
CURRENT_NETWORK=$(grep "^IPV4_NETWORK=" .env | cut -d'=' -f2 || echo "NOT SET")
echo "Current IPV4_NETWORK: $CURRENT_NETWORK"

# Backup .env
BACKUP_FILE=".env.backup.$(date +%Y%m%d_%H%M%S)"
cp .env "$BACKUP_FILE"
echo -e "${GREEN}✓${NC} Backup created: $BACKUP_FILE"

echo ""
echo -e "${YELLOW}Step 2: Setting a safe network range...${NC}"

# List existing Docker networks to avoid conflicts
echo "Checking existing Docker networks..."
docker network ls

# Try different network ranges
POSSIBLE_NETWORKS=("172.22.1" "172.23.1" "172.24.1" "172.25.1" "10.10.1" "10.11.1")
CHOSEN_NETWORK=""

for net in "${POSSIBLE_NETWORKS[@]}"; do
    # Check if this network range is free
    if ! docker network ls --format "{{.Name}}" | xargs -I {} docker network inspect {} 2>/dev/null | grep -q "$net"; then
        CHOSEN_NETWORK=$net
        break
    fi
done

if [ -z "$CHOSEN_NETWORK" ]; then
    # Default to a random high range if all are taken
    CHOSEN_NETWORK="172.$((RANDOM % 50 + 30)).1"
fi

echo -e "${GREEN}✓${NC} Chosen network: ${CHOSEN_NETWORK}.0/24"

# Update .env file
sed -i "s/^IPV4_NETWORK=.*/IPV4_NETWORK=${CHOSEN_NETWORK}/" .env

echo -e "${GREEN}✓${NC} Updated .env with IPV4_NETWORK=${CHOSEN_NETWORK}"

echo ""
echo -e "${YELLOW}Step 3: Verifying .env configuration...${NC}"

# Check for other potential issues
if ! grep -q "^TETRISNEWSEMAILING_HOSTNAME=" .env; then
    echo -e "${YELLOW}⚠${NC} TETRISNEWSEMAILING_HOSTNAME not found"
    
    # Try to get from BILLIONMAIL_HOSTNAME
    if grep -q "^BILLIONMAIL_HOSTNAME=" .env; then
        HOSTNAME_VALUE=$(grep "^BILLIONMAIL_HOSTNAME=" .env | cut -d'=' -f2)
        echo "TETRISNEWSEMAILING_HOSTNAME=${HOSTNAME_VALUE}" >> .env
        echo -e "${GREEN}✓${NC} Added TETRISNEWSEMAILING_HOSTNAME=${HOSTNAME_VALUE}"
    else
        echo "TETRISNEWSEMAILING_HOSTNAME=mail.example.com" >> .env
        echo -e "${YELLOW}⚠${NC} Added default TETRISNEWSEMAILING_HOSTNAME"
    fi
fi

echo ""
echo -e "${BLUE}Current .env configuration:${NC}"
grep "^IPV4_NETWORK=" .env
grep "^TETRISNEWSEMAILING_HOSTNAME=" .env
grep "^DBNAME=" .env

echo ""
echo -e "${YELLOW}Step 4: Cleaning up Docker resources...${NC}"

# Remove any leftover networks
docker network prune -f
echo -e "${GREEN}✓${NC} Networks cleaned"

echo ""
echo -e "${YELLOW}Step 5: Starting services with new configuration...${NC}"

# Start services
docker compose up -d

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓✓✓ SUCCESS! ✓✓✓${NC}"
    echo ""
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}   TetrisNews Emailing is now running!        ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    # Wait for services to start
    sleep 3
    
    # Show status
    docker compose ps
    
    echo ""
    echo -e "${GREEN}All services started successfully!${NC}"
    echo ""
    HOSTNAME=$(grep "^TETRISNEWSEMAILING_HOSTNAME=" .env | cut -d'=' -f2)
    echo "Access your mail server:"
    echo "  • Web Interface: http://${HOSTNAME}"
    echo "  • WebMail:       http://${HOSTNAME}/roundcube/"
    echo ""
    echo "View logs:"
    echo "  docker compose logs -f"
else
    echo ""
    echo -e "${RED}✗${NC} Error starting services"
    echo "Checking logs..."
    docker compose logs --tail=50
    exit 1
fi
