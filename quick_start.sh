#!/bin/bash
# TetrisNews Emailing - Quick Start Script
# This script helps you quickly resolve common Docker Compose issues

set -e

echo "================================================"
echo "   TetrisNews Emailing - Quick Start Script    "
echo "================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ $(whoami) != "root" ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Please try: sudo bash $0"
    exit 1
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "The .env file should have been created automatically."
    exit 1
fi

echo -e "${GREEN}✓${NC} Found .env configuration file"

# Check for conflicting Docker networks
echo ""
echo "Checking for network conflicts..."

if command -v docker &> /dev/null; then
    # List existing networks with the tetrisnews pattern
    EXISTING_NETWORK=$(docker network ls --filter name=tetrisnews --format "{{.Name}}" | grep -E "tetrisnews|172.66" || true)
    
    if [ ! -z "$EXISTING_NETWORK" ]; then
        echo -e "${YELLOW}⚠${NC} Found existing TetrisNews network(s):"
        echo "$EXISTING_NETWORK"
        echo ""
        read -p "Do you want to remove these networks? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker compose down 2>/dev/null || true
            echo "$EXISTING_NETWORK" | while read network; do
                docker network rm "$network" 2>/dev/null || true
            done
            echo -e "${GREEN}✓${NC} Old networks removed"
        fi
    else
        echo -e "${GREEN}✓${NC} No network conflicts detected"
    fi
else
    echo -e "${YELLOW}⚠${NC} Docker command not found. Skipping network check."
fi

# Display current configuration
echo ""
echo "================================================"
echo "Current Configuration (.env):"
echo "================================================"
echo -e "Hostname: ${GREEN}$(grep TETRISNEWSEMAILING_HOSTNAME .env | cut -d'=' -f2)${NC}"
echo -e "Database: ${GREEN}$(grep DBNAME .env | cut -d'=' -f2)${NC}"
echo -e "Admin User: ${GREEN}$(grep ADMIN_USERNAME .env | cut -d'=' -f2)${NC}"
echo -e "Network: ${GREEN}$(grep IPV4_NETWORK .env | cut -d'=' -f2).0/24${NC}"
echo ""

# Ask if user wants to customize
read -p "Do you want to customize these settings? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    read -p "Enter your mail hostname (e.g., mail.yourdomain.com): " HOSTNAME
    if [ ! -z "$HOSTNAME" ]; then
        sed -i "s/TETRISNEWSEMAILING_HOSTNAME=.*/TETRISNEWSEMAILING_HOSTNAME=$HOSTNAME/" .env
        echo -e "${GREEN}✓${NC} Hostname updated to: $HOSTNAME"
    fi
fi

# Start services
echo ""
echo "================================================"
echo "Starting TetrisNews Emailing services..."
echo "================================================"

if command -v docker &> /dev/null; then
    # Pull latest images
    echo "Pulling Docker images..."
    docker compose pull
    
    # Start services
    echo "Starting containers..."
    docker compose up -d
    
    echo ""
    echo -e "${GREEN}✓✓✓ SUCCESS! ✓✓✓${NC}"
    echo ""
    echo "================================================"
    echo "TetrisNews Emailing is starting up!"
    echo "================================================"
    echo ""
    echo "Wait a few moments for all services to initialize, then:"
    echo ""
    echo "1. Check status:"
    echo "   docker compose ps"
    echo ""
    echo "2. View logs:"
    echo "   docker compose logs -f"
    echo ""
    echo "3. Access web interface:"
    echo "   http://$(grep TETRISNEWSEMAILING_HOSTNAME .env | cut -d'=' -f2)"
    echo "   or http://localhost (if running locally)"
    echo ""
    echo "4. Default admin credentials:"
    echo "   Username: $(grep ADMIN_USERNAME .env | cut -d'=' -f2)"
    echo "   Password: $(grep ADMIN_PASSWORD .env | cut -d'=' -f2)"
    echo ""
    echo "5. WebMail access:"
    echo "   http://your-hostname/roundcube/"
    echo ""
    echo "For management commands, use: ./bm.sh help"
    echo "================================================"
else
    echo -e "${YELLOW}⚠${NC} Docker not found. Please install Docker and Docker Compose first."
    echo "Visit: https://docs.docker.com/get-docker/"
fi

echo ""
echo "Configuration complete! 🎉"
