#!/bin/bash
# Script de diagnostic rapide pour TetrisNews Emailing

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
CYAN='\033[0;96m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         Diagnostic Rapide - TetrisNews Emailing               ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Fonction pour vérifier une condition
check_condition() {
    local condition=$1
    local success_msg=$2
    local error_msg=$3
    
    if eval "$condition"; then
        echo -e "${GREEN}✓${NC} $success_msg"
        return 0
    else
        echo -e "${RED}✗${NC} $error_msg"
        return 1
    fi
}

# 1. Vérifier qu'on est dans le bon répertoire
echo -e "${BLUE}📁 Vérification du répertoire${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_condition "[ -f 'docker-compose.traefik.yml' ]" \
    "Fichier docker-compose.traefik.yml trouvé" \
    "Fichier docker-compose.traefik.yml introuvable! Êtes-vous dans ~/BillionMail ?"

check_condition "[ -f '.env' ]" \
    "Fichier .env trouvé" \
    "Fichier .env introuvable!"
echo ""

# 2. Vérifier les variables .env
echo -e "${BLUE}⚙️  Vérification des variables .env${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f ".env" ]; then
    IPV4_NETWORK=$(grep "^IPV4_NETWORK=" .env 2>/dev/null | cut -d'=' -f2)
    HOSTNAME=$(grep "^TETRISNEWSEMAILING_HOSTNAME=" .env 2>/dev/null | cut -d'=' -f2)
    DOMAIN=$(grep "^DOMAIN=" .env 2>/dev/null | cut -d'=' -f2)
    
    if [ ! -z "$IPV4_NETWORK" ]; then
        echo -e "${GREEN}✓${NC} IPV4_NETWORK défini: ${CYAN}${IPV4_NETWORK}${NC}"
    else
        echo -e "${RED}✗${NC} IPV4_NETWORK non défini ou vide!"
    fi
    
    if [ ! -z "$HOSTNAME" ]; then
        echo -e "${GREEN}✓${NC} TETRISNEWSEMAILING_HOSTNAME défini: ${CYAN}${HOSTNAME}${NC}"
    else
        echo -e "${RED}✗${NC} TETRISNEWSEMAILING_HOSTNAME non défini!"
    fi
    
    if [ ! -z "$DOMAIN" ]; then
        echo -e "${GREEN}✓${NC} DOMAIN défini: ${CYAN}${DOMAIN}${NC}"
    else
        echo -e "${YELLOW}⚠${NC}  DOMAIN non défini (nécessaire pour Traefik)"
    fi
fi
echo ""

# 3. Vérifier Docker
echo -e "${BLUE}🐳 Vérification de Docker${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓${NC} Docker installé: ${CYAN}${DOCKER_VERSION}${NC}"
    
    # Vérifier si Docker est en cours d'exécution
    if docker ps >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Docker est en cours d'exécution"
    else
        echo -e "${RED}✗${NC} Docker ne répond pas! Vérifiez le service Docker."
    fi
else
    echo -e "${RED}✗${NC} Docker n'est pas installé!"
fi
echo ""

# 4. Vérifier les réseaux Docker
echo -e "${BLUE}🌐 Vérification des réseaux Docker${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Réseau Traefik 'web'
if docker network inspect web >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Réseau Traefik 'web' existe"
else
    echo -e "${RED}✗${NC} Réseau Traefik 'web' introuvable! (Créez-le avec: docker network create web)"
fi

# Réseau TetrisNews
if docker network inspect tetrisnews-emailing_tetrisnews-network >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Réseau tetrisnews-emailing_tetrisnews-network existe"
    
    # Vérifier la plage IP
    SUBNET=$(docker network inspect tetrisnews-emailing_tetrisnews-network --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null)
    if [ ! -z "$SUBNET" ]; then
        echo -e "  └─ Subnet: ${CYAN}${SUBNET}${NC}"
    fi
else
    echo -e "${YELLOW}⚠${NC}  Réseau tetrisnews-emailing_tetrisnews-network n'existe pas (normal si pas encore démarré)"
fi

# Lister tous les réseaux
echo ""
echo "Tous les réseaux Docker:"
docker network ls 2>/dev/null | grep -v "NETWORK ID" || echo "  Impossible de lister les réseaux"
echo ""

# 5. Vérifier les conflits de réseaux
echo -e "${BLUE}🔍 Détection des conflits réseau${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ! -z "$IPV4_NETWORK" ]; then
    echo "Recherche de conflits pour la plage ${CYAN}${IPV4_NETWORK}.0/24${NC}..."
    
    CONFLICTS=$(docker network ls --format "{{.Name}}" 2>/dev/null | grep -v "bridge\|host\|none" | xargs -I {} docker network inspect {} 2>/dev/null | grep -c "${IPV4_NETWORK}" || echo "0")
    
    if [ "$CONFLICTS" -gt 1 ]; then
        echo -e "${RED}✗${NC} Conflit détecté! La plage ${IPV4_NETWORK}.0/24 est utilisée par plusieurs réseaux:"
        docker network ls --format "{{.Name}}" 2>/dev/null | xargs -I {} sh -c "docker network inspect {} 2>/dev/null | grep -q '${IPV4_NETWORK}' && echo '  - {}'" || true
    else
        echo -e "${GREEN}✓${NC} Aucun conflit détecté pour cette plage"
    fi
else
    echo -e "${YELLOW}⚠${NC}  IPV4_NETWORK non défini, impossible de vérifier les conflits"
fi
echo ""

# 6. Vérifier les conteneurs
echo -e "${BLUE}📦 Vérification des conteneurs${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

RUNNING_CONTAINERS=$(docker ps --filter "name=tetrisnews" --format "{{.Names}}" 2>/dev/null | wc -l)
ALL_CONTAINERS=$(docker ps -a --filter "name=tetrisnews" --format "{{.Names}}" 2>/dev/null | wc -l)

if [ "$RUNNING_CONTAINERS" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} ${RUNNING_CONTAINERS} conteneur(s) TetrisNews en cours d'exécution"
    docker ps --filter "name=tetrisnews" --format "  - {{.Names}}: {{.Status}}" 2>/dev/null
else
    echo -e "${YELLOW}⚠${NC}  Aucun conteneur TetrisNews en cours d'exécution"
fi

if [ "$ALL_CONTAINERS" -gt "$RUNNING_CONTAINERS" ]; then
    STOPPED=$((ALL_CONTAINERS - RUNNING_CONTAINERS))
    echo -e "${YELLOW}⚠${NC}  ${STOPPED} conteneur(s) arrêté(s):"
    docker ps -a --filter "name=tetrisnews" --format "  - {{.Names}}: {{.Status}}" 2>/dev/null | grep -v "Up"
fi

# Vérifier les anciens conteneurs BillionMail
OLD_CONTAINERS=$(docker ps -a --filter "name=billionmail" --format "{{.Names}}" 2>/dev/null | wc -l)
if [ "$OLD_CONTAINERS" -gt 0 ]; then
    echo -e "${YELLOW}⚠${NC}  ${OLD_CONTAINERS} ancien(s) conteneur(s) BillionMail détecté(s):"
    docker ps -a --filter "name=billionmail" --format "  - {{.Names}}: {{.Status}}" 2>/dev/null
fi
echo ""

# 7. Vérifier Traefik
echo -e "${BLUE}🚪 Vérification de Traefik${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if docker ps --filter "name=traefik" --format "{{.Names}}" 2>/dev/null | grep -q traefik; then
    echo -e "${GREEN}✓${NC} Traefik est en cours d'exécution"
    TRAEFIK_STATUS=$(docker ps --filter "name=traefik" --format "{{.Status}}" 2>/dev/null | head -1)
    echo -e "  └─ Status: ${CYAN}${TRAEFIK_STATUS}${NC}"
else
    echo -e "${RED}✗${NC} Traefik n'est pas en cours d'exécution!"
fi
echo ""

# 8. Résumé et recommandations
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                        📊 RÉSUMÉ                               ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Compter les problèmes
[ -z "$IPV4_NETWORK" ] && ((ERRORS++))
[ -z "$HOSTNAME" ] && ((ERRORS++))
[ -z "$DOMAIN" ] && ((WARNINGS++))
! docker network inspect web >/dev/null 2>&1 && ((ERRORS++))
! docker ps --filter "name=traefik" --format "{{.Names}}" 2>/dev/null | grep -q traefik && ((WARNINGS++))
[ "$OLD_CONTAINERS" -gt 0 ] && ((WARNINGS++))

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Aucun problème détecté!${NC}"
    echo ""
    echo "Votre configuration semble correcte. Si vous rencontrez toujours"
    echo "l'erreur 'numerical result out of range', exécutez:"
    echo ""
    echo -e "  ${CYAN}sudo bash fix_traefik_network.sh${NC}"
    echo ""
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  ${WARNINGS} avertissement(s) détecté(s)${NC}"
    echo ""
    echo "Votre configuration fonctionne probablement, mais quelques"
    echo "améliorations sont recommandées. Exécutez:"
    echo ""
    echo -e "  ${CYAN}sudo bash fix_traefik_network.sh${NC}"
    echo ""
else
    echo -e "${RED}❌ ${ERRORS} erreur(s) critique(s) détectée(s)${NC}"
    echo ""
    echo "Des problèmes de configuration ont été détectés."
    echo "Exécutez le script de correction pour les résoudre:"
    echo ""
    echo -e "  ${CYAN}sudo bash fix_traefik_network.sh${NC}"
    echo ""
fi

echo -e "${BLUE}📝 Commandes utiles:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  • Corriger automatiquement:  sudo bash fix_traefik_network.sh"
echo "  • Voir ce diagnostic:        bash diagnostic_rapide.sh"
echo "  • Voir les logs:             docker compose -f docker-compose.traefik.yml logs"
echo "  • Lire la doc complète:      cat SOLUTION_RESEAU_TRAEFIK.md"
echo ""
