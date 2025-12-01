#!/bin/bash
# Complete fix script for TetrisNews Emailing

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   TetrisNews Emailing - Complete Fix Script   ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}Error: docker-compose.yml not found!${NC}"
    echo "Please run this script from your TetrisNews/BillionMail directory"
    exit 1
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Creating .env from env_init..."
    if [ -f "env_init" ]; then
        cp env_init .env
        echo -e "${GREEN}✓${NC} .env created from env_init"
    else
        echo -e "${RED}Error: env_init not found either!${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}Step 1: Checking and fixing .env file...${NC}"

# Backup .env
BACKUP_FILE=".env.backup.$(date +%Y%m%d_%H%M%S)"
cp .env "$BACKUP_FILE"
echo -e "${GREEN}✓${NC} Backup created: $BACKUP_FILE"

# Check if TETRISNEWSEMAILING_HOSTNAME exists
if ! grep -q "^TETRISNEWSEMAILING_HOSTNAME=" .env; then
    # Try to get from BILLIONMAIL_HOSTNAME
    if grep -q "^BILLIONMAIL_HOSTNAME=" .env; then
        HOSTNAME_VALUE=$(grep "^BILLIONMAIL_HOSTNAME=" .env | cut -d'=' -f2)
        echo "TETRISNEWSEMAILING_HOSTNAME=${HOSTNAME_VALUE}" >> .env
        echo -e "${GREEN}✓${NC} Added TETRISNEWSEMAILING_HOSTNAME=${HOSTNAME_VALUE}"
    else
        # Use default
        echo "TETRISNEWSEMAILING_HOSTNAME=mail.example.com" >> .env
        echo -e "${YELLOW}⚠${NC} Added default TETRISNEWSEMAILING_HOSTNAME=mail.example.com"
        echo -e "${YELLOW}  Please edit .env to set your actual domain${NC}"
    fi
else
    echo -e "${GREEN}✓${NC} TETRISNEWSEMAILING_HOSTNAME is set"
fi

# Display current configuration
echo ""
echo -e "${BLUE}Current Configuration:${NC}"
echo "  Hostname: $(grep TETRISNEWSEMAILING_HOSTNAME= .env | cut -d'=' -f2 || echo 'NOT SET')"
echo "  Database: $(grep DBNAME= .env | head -1 | cut -d'=' -f2)"
echo "  Network: $(grep IPV4_NETWORK= .env | cut -d'=' -f2).0/24"
echo ""

echo -e "${YELLOW}Step 2: Cleaning up old Docker resources...${NC}"

# Stop containers
docker compose down 2>/dev/null || true
echo -e "${GREEN}✓${NC} Stopped containers"

# Remove old networks
OLD_NETWORKS=$(docker network ls --filter name=tetrisnews --filter name=billionmail --format "{{.Name}}" 2>/dev/null | grep -v "bridge\|host\|none" || true)
if [ ! -z "$OLD_NETWORKS" ]; then
    echo "$OLD_NETWORKS" | while read network; do
        docker network rm "$network" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Removed network: $network"
    done
else
    echo -e "${GREEN}✓${NC} No old networks to remove"
fi

echo ""
echo -e "${YELLOW}Step 3: Building Docker images...${NC}"
echo -e "${YELLOW}  This may take 5-10 minutes, please be patient...${NC}"
echo ""

# Build images
docker compose build --no-cache

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓${NC} Docker images built successfully"
else
    echo ""
    echo -e "${RED}✗${NC} Error building Docker images"
    echo "Please check the error messages above"
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
    
    # Wait a bit for containers to start
    sleep 3
    
    echo "Container Status:"
    docker compose ps
    
    echo ""
    echo "Useful commands:"
    echo "  • View logs:        docker compose logs -f"
    echo "  • Check status:     docker compose ps"
    echo "  • Stop services:    docker compose down"
    echo "  • Restart service:  docker compose restart [service-name]"
    echo ""
    HOSTNAME=$(grep TETRISNEWSEMAILING_HOSTNAME= .env | cut -d'=' -f2)
    echo "Access your mail server:"
    echo "  • Web Interface: http://${HOSTNAME}"
    echo "  • WebMail:       http://${HOSTNAME}/roundcube/"
    echo ""
    echo -e "${GREEN}Setup complete! 🎉${NC}"
else
    echo ""
    echo -e "${RED}✗${NC} Error starting services"
    echo "Check logs with: docker compose logs"
    exit 1
fi
