#!/bin/bash

# ============================================
# Script de déploiement Tetrisnews Emailing
# Pour VPS GCP avec Traefik
# ============================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          Tetrisnews Emailing - Déploiement                 ║"
echo "║              avec Traefik sur GCP                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Vérification des prérequis
echo -e "${YELLOW}[1/6] Vérification des prérequis...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas installé${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker et Docker Compose sont installés${NC}"

# Vérification du réseau Traefik
echo -e "${YELLOW}[2/6] Vérification du réseau Traefik...${NC}"

if ! docker network ls | grep -q "web"; then
    echo -e "${YELLOW}⚠ Le réseau 'web' n'existe pas. Création...${NC}"
    docker network create web
fi
echo -e "${GREEN}✓ Réseau 'web' disponible${NC}"

# Configuration
echo -e "${YELLOW}[3/6] Configuration...${NC}"

if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${YELLOW}⚠ Fichier .env créé depuis .env.example${NC}"
        echo -e "${RED}❗ IMPORTANT: Éditez le fichier .env avec vos paramètres avant de continuer${NC}"
        echo ""
        echo "Paramètres à configurer:"
        echo "  - DOMAIN: Votre domaine (ex: mail.votredomaine.com)"
        echo "  - ADMIN_USERNAME: Nom d'utilisateur admin"
        echo "  - ADMIN_PASSWORD: Mot de passe admin"
        echo "  - DBPASS: Mot de passe PostgreSQL"
        echo "  - REDISPASS: Mot de passe Redis"
        echo ""
        read -p "Appuyez sur Entrée après avoir édité .env, ou Ctrl+C pour annuler..."
    else
        echo -e "${RED}❌ Fichier .env.example non trouvé${NC}"
        exit 1
    fi
fi

# Validation du .env
source .env
if [ -z "$DOMAIN" ] || [ "$DOMAIN" = "mail.votredomaine.com" ]; then
    echo -e "${RED}❌ Veuillez configurer DOMAIN dans le fichier .env${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Configuration chargée pour: $DOMAIN${NC}"

# Création des répertoires
echo -e "${YELLOW}[4/6] Création des répertoires...${NC}"

directories=(
    "postgresql-data"
    "postgresql-socket"
    "redis-data"
    "rspamd-data"
    "vmail-data"
    "postfix-data"
    "webmail-data"
    "core-data"
    "php-sock"
    "ssl"
    "logs/postfix"
    "logs/dovecot"
    "logs/rspamd"
    "logs/fail2ban"
    "logs/core"
)

for dir in "${directories[@]}"; do
    mkdir -p "$dir"
done

echo -e "${GREEN}✓ Répertoires créés${NC}"

# Pull des images
echo -e "${YELLOW}[5/6] Téléchargement des images Docker...${NC}"
docker compose -f docker-compose.traefik.yml pull

echo -e "${GREEN}✓ Images téléchargées${NC}"

# Démarrage
echo -e "${YELLOW}[6/6] Démarrage des services...${NC}"
docker compose -f docker-compose.traefik.yml up -d

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            ✅ Déploiement terminé avec succès!             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📧 Tetrisnews Emailing est accessible à:${NC}"
echo -e "   🌐 Interface Admin: ${GREEN}https://$DOMAIN/$SafePath${NC}"
echo -e "   📬 Webmail:         ${GREEN}https://$DOMAIN/roundcube${NC}"
echo ""
echo -e "${BLUE}🔐 Identifiants par défaut:${NC}"
echo -e "   Utilisateur: ${GREEN}$ADMIN_USERNAME${NC}"
echo -e "   Mot de passe: ${GREEN}$ADMIN_PASSWORD${NC}"
echo ""
echo -e "${YELLOW}📋 Prochaines étapes:${NC}"
echo "   1. Configurez les enregistrements DNS (MX, SPF, DKIM, DMARC)"
echo "   2. Ajoutez votre premier domaine d'envoi"
echo "   3. Créez vos boîtes mail"
echo ""
echo -e "${BLUE}🛠 Commandes utiles:${NC}"
echo "   - Voir les logs:     docker compose -f docker-compose.traefik.yml logs -f"
echo "   - Redémarrer:        docker compose -f docker-compose.traefik.yml restart"
echo "   - Arrêter:           docker compose -f docker-compose.traefik.yml down"
echo "   - Statut:            docker compose -f docker-compose.traefik.yml ps"
echo ""
