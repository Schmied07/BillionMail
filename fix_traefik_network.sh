#!/bin/bash
# Fix réseau Docker pour TetrisNews Emailing avec Traefik
# Corrige l'erreur "numerical result out of range"

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
CYAN='\033[0;96m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   TetrisNews Emailing - Fix Réseau Docker + Traefik           ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "docker-compose.traefik.yml" ]; then
    echo -e "${RED}❌ Erreur: docker-compose.traefik.yml introuvable!${NC}"
    echo "Veuillez exécuter ce script depuis ~/TetrisNewsEmailing"
    exit 1
fi

if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Erreur: fichier .env introuvable!${NC}"
    exit 1
fi

echo -e "${BLUE}📊 Étape 1: Diagnostic de la configuration actuelle${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Backup du .env
BACKUP_FILE=".env.backup.$(date +%Y%m%d_%H%M%S)"
cp .env "$BACKUP_FILE"
echo -e "${GREEN}✓${NC} Backup créé: ${BACKUP_FILE}"

# Lire la configuration actuelle
CURRENT_NETWORK=$(grep "^IPV4_NETWORK=" .env 2>/dev/null | cut -d'=' -f2 || echo "NON DÉFINI")
CURRENT_HOSTNAME=$(grep "^TETRISNEWSEMAILING_HOSTNAME=" .env 2>/dev/null | cut -d'=' -f2 || echo "NON DÉFINI")
CURRENT_DOMAIN=$(grep "^DOMAIN=" .env 2>/dev/null | cut -d'=' -f2 || echo "NON DÉFINI")

echo -e "  IPV4_NETWORK actuel: ${YELLOW}${CURRENT_NETWORK}${NC}"
echo -e "  TETRISNEWSEMAILING_HOSTNAME: ${YELLOW}${CURRENT_HOSTNAME}${NC}"
echo -e "  DOMAIN: ${YELLOW}${CURRENT_DOMAIN}${NC}"
echo ""

echo -e "${BLUE}🔍 Étape 2: Analyse des réseaux Docker existants${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Lister les réseaux Docker existants
echo "Réseaux Docker actuels:"
docker network ls 2>/dev/null | grep -v "NETWORK ID" || echo "  Aucun réseau Docker"
echo ""

# Analyser les plages IP utilisées
echo "Plages IP utilisées:"
USED_NETWORKS=$(docker network ls --format "{{.Name}}" 2>/dev/null | grep -v "bridge\|host\|none" | xargs -I {} docker network inspect {} --format '{{.Name}}: {{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null | grep -v "^$" || true)

if [ ! -z "$USED_NETWORKS" ]; then
    echo "$USED_NETWORKS"
else
    echo "  Aucune plage IP détectée"
fi
echo ""

echo -e "${BLUE}🧹 Étape 3: Nettoyage des anciens conteneurs${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Arrêter les services avec docker-compose.traefik.yml
echo "Arrêt des services TetrisNews Emailing..."
docker compose -f docker-compose.traefik.yml down 2>/dev/null || true
echo -e "${GREEN}✓${NC} Services arrêtés"

# Supprimer les anciens conteneurs
OLD_CONTAINERS=$(docker ps -a --filter "name=tetrisnews" --filter "name=tetrisnewsemailing" --format "{{.Names}}" 2>/dev/null || true)
if [ ! -z "$OLD_CONTAINERS" ]; then
    echo "Suppression des anciens conteneurs:"
    echo "$OLD_CONTAINERS" | while read container; do
        echo "  - Suppression: $container"
        docker rm -f "$container" 2>/dev/null || true
    done
    echo -e "${GREEN}✓${NC} Anciens conteneurs supprimés"
else
    echo -e "${GREEN}✓${NC} Aucun ancien conteneur à supprimer"
fi
echo ""

echo -e "${BLUE}🌐 Étape 4: Nettoyage et configuration des réseaux${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Supprimer les anciens réseaux tetrisnews
OLD_NETWORKS=$(docker network ls --filter name=tetrisnews --format "{{.Name}}" 2>/dev/null | grep -v "bridge\|host\|none" || true)
if [ ! -z "$OLD_NETWORKS" ]; then
    echo "Suppression des anciens réseaux:"
    echo "$OLD_NETWORKS" | while read network; do
        echo "  - Suppression: $network"
        docker network rm "$network" 2>/dev/null || true
    done
    echo -e "${GREEN}✓${NC} Anciens réseaux supprimés"
else
    echo -e "${GREEN}✓${NC} Aucun ancien réseau à supprimer"
fi

# Vérifier/créer le réseau Traefik "web"
echo ""
echo "Vérification du réseau Traefik 'web'..."
if docker network inspect web >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Le réseau Traefik 'web' existe déjà"
else
    echo "Création du réseau Traefik 'web'..."
    docker network create web 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Réseau Traefik 'web' créé"
fi

# Nettoyer les réseaux inutilisés
docker network prune -f >/dev/null 2>&1
echo -e "${GREEN}✓${NC} Réseaux inutilisés nettoyés"
echo ""

echo -e "${BLUE}⚙️  Étape 5: Configuration du fichier .env${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Trouver une plage réseau disponible
POSSIBLE_NETWORKS=("172.22.1" "172.23.1" "172.24.1" "172.25.1" "172.26.1" "10.10.1" "10.11.1" "10.12.1")
CHOSEN_NETWORK=""

echo "Recherche d'une plage réseau disponible..."
for net in "${POSSIBLE_NETWORKS[@]}"; do
    # Vérifier si cette plage est libre
    if ! docker network ls --format "{{.Name}}" 2>/dev/null | xargs -I {} docker network inspect {} 2>/dev/null | grep -q "${net}"; then
        CHOSEN_NETWORK=$net
        break
    fi
done

if [ -z "$CHOSEN_NETWORK" ]; then
    # Générer une plage aléatoire si toutes sont prises
    CHOSEN_NETWORK="172.$((RANDOM % 50 + 30)).1"
fi

echo -e "${GREEN}✓${NC} Plage réseau sélectionnée: ${CYAN}${CHOSEN_NETWORK}.0/24${NC}"

# Mettre à jour IPV4_NETWORK
if grep -q "^IPV4_NETWORK=" .env; then
    sed -i "s|^IPV4_NETWORK=.*|IPV4_NETWORK=${CHOSEN_NETWORK}|" .env
    echo -e "${GREEN}✓${NC} IPV4_NETWORK mis à jour: ${CHOSEN_NETWORK}"
else
    echo "IPV4_NETWORK=${CHOSEN_NETWORK}" >> .env
    echo -e "${GREEN}✓${NC} IPV4_NETWORK ajouté: ${CHOSEN_NETWORK}"
fi

# Mettre à jour TETRISNEWSEMAILING_HOSTNAME
if ! grep -q "^TETRISNEWSEMAILING_HOSTNAME=" .env; then
    echo "TETRISNEWSEMAILING_HOSTNAME=emailing.tetrisnews.fr" >> .env
    echo -e "${GREEN}✓${NC} TETRISNEWSEMAILING_HOSTNAME ajouté"
elif [ "$CURRENT_HOSTNAME" = "NON DÉFINI" ] || [ -z "$CURRENT_HOSTNAME" ]; then
    sed -i "s|^TETRISNEWSEMAILING_HOSTNAME=.*|TETRISNEWSEMAILING_HOSTNAME=emailing.tetrisnews.fr|" .env
    echo -e "${GREEN}✓${NC} TETRISNEWSEMAILING_HOSTNAME corrigé"
else
    echo -e "${GREEN}✓${NC} TETRISNEWSEMAILING_HOSTNAME déjà défini: ${CURRENT_HOSTNAME}"
fi

# Mettre à jour DOMAIN (pour Traefik)
if ! grep -q "^DOMAIN=" .env; then
    echo "DOMAIN=emailing.tetrisnews.fr" >> .env
    echo -e "${GREEN}✓${NC} DOMAIN ajouté pour Traefik"
elif [ "$CURRENT_DOMAIN" = "NON DÉFINI" ] || [ -z "$CURRENT_DOMAIN" ]; then
    sed -i "s|^DOMAIN=.*|DOMAIN=emailing.tetrisnews.fr|" .env
    echo -e "${GREEN}✓${NC} DOMAIN corrigé pour Traefik"
else
    echo -e "${GREEN}✓${NC} DOMAIN déjà défini: ${CURRENT_DOMAIN}"
fi

echo ""
echo -e "${CYAN}📋 Configuration finale du .env:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
grep "^IPV4_NETWORK=" .env
grep "^TETRISNEWSEMAILING_HOSTNAME=" .env
grep "^DOMAIN=" .env
echo ""

echo -e "${BLUE}🚀 Étape 6: Démarrage des services${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Démarrer les services avec docker-compose.traefik.yml
echo "Démarrage de TetrisNews Emailing avec Traefik..."
docker compose -f docker-compose.traefik.yml up -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Services démarrés avec succès!"
    echo ""
    
    # Attendre que les conteneurs démarrent
    echo "⏳ Attente du démarrage complet des services (5 secondes)..."
    sleep 5
    
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                ✅ SUCCÈS! Services en ligne                    ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Afficher l'état des services
    echo -e "${BLUE}📊 État des services:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    docker compose -f docker-compose.traefik.yml ps
    echo ""
    
    echo -e "${BLUE}🌐 Accès à l'application:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    DOMAIN_VALUE=$(grep "^DOMAIN=" .env | cut -d'=' -f2)
    echo -e "  • Interface Admin:  ${CYAN}https://${DOMAIN_VALUE}${NC}"
    echo -e "  • WebMail:          ${CYAN}https://${DOMAIN_VALUE}/roundcube/${NC}"
    echo -e "  • Login Admin:      ${YELLOW}tetrisnews / tetrisnews${NC}"
    echo ""
    
    echo -e "${BLUE}📝 Commandes utiles:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  • Voir les logs:           docker compose -f docker-compose.traefik.yml logs -f"
    echo "  • État des services:       docker compose -f docker-compose.traefik.yml ps"
    echo "  • Redémarrer un service:   docker compose -f docker-compose.traefik.yml restart <service>"
    echo "  • Arrêter tous services:   docker compose -f docker-compose.traefik.yml down"
    echo ""
    
    echo -e "${GREEN}🎉 Installation terminée avec succès!${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Note importante:${NC}"
    echo "  Le certificat SSL Let's Encrypt peut prendre 1-2 minutes pour être généré."
    echo "  Si vous obtenez une erreur SSL, attendez quelques instants et réessayez."
    echo ""
    
else
    echo ""
    echo -e "${RED}❌ Erreur lors du démarrage des services${NC}"
    echo ""
    echo "Vérifiez les logs avec:"
    echo "  docker compose -f docker-compose.traefik.yml logs"
    echo ""
    echo "Pour restaurer la configuration précédente:"
    echo "  cp ${BACKUP_FILE} .env"
    exit 1
fi
