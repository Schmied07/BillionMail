#!/bin/bash
# Script to fix .env file and build Docker images

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   TetrisNews Emailing - Fix & Build Script    ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env file not found in current directory!${NC}"
    echo "Please run this script from your TetrisNews/TetrisNewsEmailing directory"
    exit 1
fi

echo -e "${YELLOW}Step 1: Fixing .env file...${NC}"

# Backup original .env
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
echo -e "${GREEN}✓${NC} Backup created: .env.backup.$(date +%Y%m%d_%H%M%S)"

# Get current BILLIONMAIL_HOSTNAME value
CURRENT_HOSTNAME=$(grep "BILLIONMAIL_HOSTNAME=" .env | cut -d'=' -f2)

# Add TETRISNEWSEMAILING_HOSTNAME if it doesn't exist
if ! grep -q "TETRISNEWSEMAILING_HOSTNAME=" .env; then
    echo "TETRISNEWSEMAILING_HOSTNAME=${CURRENT_HOSTNAME}" >> .env
    echo -e "${GREEN}✓${NC} Added TETRISNEWSEMAILING_HOSTNAME=${CURRENT_HOSTNAME}"
else
    # Update existing TETRISNEWSEMAILING_HOSTNAME with BILLIONMAIL_HOSTNAME value
    sed -i "s/^TETRISNEWSEMAILING_HOSTNAME=.*/TETRISNEWSEMAILING_HOSTNAME=${CURRENT_HOSTNAME}/" .env
    echo -e "${GREEN}✓${NC} Updated TETRISNEWSEMAILING_HOSTNAME=${CURRENT_HOSTNAME}"
fi

# Change network to avoid conflicts (optional but recommended)
CURRENT_NETWORK=$(grep "IPV4_NETWORK=" .env | cut -d'=' -f2)
if [ "$CURRENT_NETWORK" == "172.66.1" ]; then
    read -p "Current network is 172.66.1 (may cause conflicts). Change to 172.67.1? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sed -i 's/IPV4_NETWORK=172.66.1/IPV4_NETWORK=172.67.1/' .env
        echo -e "${GREEN}✓${NC} Network changed to 172.67.1"
    else
        echo -e "${YELLOW}⚠${NC} Keeping network as 172.66.1 - you may need to remove conflicting networks"
    fi
fi

echo ""
echo -e "${YELLOW}Step 2: Cleaning up old containers and networks...${NC}"

# Stop and remove old containers
docker compose down 2>/dev/null || true
echo -e "${GREEN}✓${NC} Old containers stopped"

# Remove old network if it exists
OLD_NETWORKS=$(docker network ls --filter name=tetrisnewsemailing --format "{{.Name}}" 2>/dev/null || true)
if [ ! -z "$OLD_NETWORKS" ]; then
    echo "$OLD_NETWORKS" | while read network; do
        docker network rm "$network" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Removed old network: $network"
    done
fi

echo ""
echo -e "${YELLOW}Step 3: Building Docker images (this may take a few minutes)...${NC}"

# Build the required images
echo "Building custom images..."
docker compose build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Docker images built successfully"
else
    echo -e "${RED}✗${NC} Error building Docker images"
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 4: Starting services...${NC}"

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
    echo "Configuration:"
    echo "  • Hostname: ${CURRENT_HOSTNAME}"
    echo "  • Network: $(grep IPV4_NETWORK= .env | cut -d'=' -f2).0/24"
    echo "  • Admin: $(grep ADMIN_USERNAME= .env | cut -d'=' -f2)"
    echo ""
    echo "Useful commands:"
    echo "  • Check status:  docker compose ps"
    echo "  • View logs:     docker compose logs -f"
    echo "  • Stop services: docker compose down"
    echo "  • Restart:       docker compose restart"
    echo ""
    echo "Access your mail server at: http://${CURRENT_HOSTNAME}"
    echo "WebMail access: http://${CURRENT_HOSTNAME}/roundcube/"
    echo ""
else
    echo -e "${RED}✗${NC} Error starting services"
    echo "Check logs with: docker compose logs"
    exit 1
fi
