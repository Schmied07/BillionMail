#!/bin/bash
# Stop old TetrisNewsEmailing deployment and start new TetrisNews Emailing

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Stopping Old & Starting New Deployment       ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${YELLOW}Step 1: Stopping old TetrisNewsEmailing containers...${NC}"

# Stop specific old containers
OLD_CONTAINERS=$(docker ps -a --filter "name=tetrisnews-emailing-" --filter "name=tetrisnewsemailing" --format "{{.Names}}" 2>/dev/null || true)

if [ ! -z "$OLD_CONTAINERS" ]; then
    echo "Found old containers:"
    echo "$OLD_CONTAINERS"
    echo ""
    
    # Stop them
    echo "$OLD_CONTAINERS" | while read container; do
        echo "Stopping: $container"
        docker stop "$container" 2>/dev/null || true
    done
    
    # Remove them
    echo ""
    echo "Removing old containers..."
    echo "$OLD_CONTAINERS" | while read container; do
        echo "Removing: $container"
        docker rm "$container" 2>/dev/null || true
    done
    
    echo -e "${GREEN}✓${NC} Old containers stopped and removed"
else
    echo -e "${GREEN}✓${NC} No old containers found"
fi

echo ""
echo -e "${YELLOW}Step 2: Removing conflicting networks...${NC}"

# Remove old networks
OLD_NETWORKS=$(docker network ls --filter name=tetrisnewsemailing --filter name=tetrisnews-emailing --format "{{.Name}}" 2>/dev/null | grep -v "bridge\|host\|none" || true)

if [ ! -z "$OLD_NETWORKS" ]; then
    echo "Found old networks:"
    echo "$OLD_NETWORKS"
    echo ""
    
    echo "$OLD_NETWORKS" | while read network; do
        echo "Removing: $network"
        docker network rm "$network" 2>/dev/null || true
    done
    
    echo -e "${GREEN}✓${NC} Old networks removed"
else
    echo -e "${GREEN}✓${NC} No old networks found"
fi

echo ""
echo -e "${YELLOW}Step 3: Starting new TetrisNews Emailing services...${NC}"

# Make sure we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}Error: docker-compose.yml not found in current directory!${NC}"
    echo "Please run this script from your TetrisNews/TetrisNewsEmailing directory"
    exit 1
fi

# Start new services
docker compose up -d

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓✓✓ SUCCESS! ✓✓✓${NC}"
    echo ""
    
    # Wait for containers to initialize
    echo "Waiting for services to initialize..."
    sleep 5
    
    echo ""
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}   New TetrisNews Emailing Deployment          ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    # Show container status
    docker compose ps
    
    echo ""
    echo -e "${GREEN}All services are now running with the new configuration!${NC}"
    echo ""
    echo "Useful commands:"
    echo "  • View logs:     docker compose logs -f"
    echo "  • Check status:  docker compose ps"
    echo "  • Stop all:      docker compose down"
    echo "  • Restart:       docker compose restart"
    echo ""
    
    HOSTNAME=$(grep TETRISNEWSEMAILING_HOSTNAME .env | cut -d'=' -f2 2>/dev/null || echo "emailing.tetrisnews.fr")
    echo "Access your mail server:"
    echo "  • Web Interface: http://${HOSTNAME}"
    echo "  • WebMail:       http://${HOSTNAME}/roundcube/"
    echo ""
    echo -e "${GREEN}Setup complete! 🎉${NC}"
else
    echo ""
    echo -e "${RED}✗${NC} Error starting new services"
    echo "Check logs with: docker compose logs"
    exit 1
fi
