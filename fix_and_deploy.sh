#!/bin/bash
# Script de correction et déploiement pour TetrisNews
# Ce script doit être exécuté sur le serveur n8nv2

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "   Correction SQL Prospects - TetrisNews        "
echo "================================================"
echo ""

# Détecter l'architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    BINARY="tetrisnewsemailing-arm64"
    GOARCH="arm64"
    echo -e "${GREEN}✓${NC} Architecture ARM64 détectée"
elif [[ "$ARCH" == "x86_64" ]]; then
    BINARY="tetrisnewsemailing-amd64"
    GOARCH="amd64"
    echo -e "${GREEN}✓${NC} Architecture AMD64 détectée"
else
    echo -e "${RED}✗${NC} Architecture non supportée: $ARCH"
    exit 1
fi

# Vérifier que Go est installé
if ! command -v go &> /dev/null; then
    echo -e "${RED}✗${NC} Go n'est pas installé"
    echo ""
    echo "Pour installer Go, exécutez :"
    if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        echo "  wget https://go.dev/dl/go1.21.5.linux-arm64.tar.gz"
    else
        echo "  wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz"
    fi
    echo "  sudo rm -rf /usr/local/go"
    echo "  sudo tar -C /usr/local -xzf go1.21.*.tar.gz"
    echo "  export PATH=\$PATH:/usr/local/go/bin"
    exit 1
fi

echo -e "${GREEN}✓${NC} Go est installé: $(go version)"
echo ""

# Vérifier qu'on est dans le bon répertoire
if [ ! -d "core" ]; then
    echo -e "${RED}✗${NC} Répertoire 'core' non trouvé"
    echo "Veuillez exécuter ce script depuis ~/BillionMail/"
    exit 1
fi

echo "=== Étape 1/5 : Compilation du binaire Go avec le correctif ==="
cd core

# Mettre à jour go.mod si nécessaire
go mod tidy

# Compiler
echo "Compilation en cours (cela peut prendre quelques minutes)..."
GOOS=linux GOARCH=$GOARCH CGO_ENABLED=0 go build -o $BINARY main.go

if [ ! -f "$BINARY" ]; then
    echo -e "${RED}✗${NC} La compilation a échoué"
    exit 1
fi

BINARY_SIZE=$(ls -lh $BINARY | awk '{print $5}')
echo -e "${GREEN}✓${NC} Binaire compilé avec succès : $BINARY ($BINARY_SIZE)"
echo ""

echo "=== Étape 2/5 : Build du frontend ==="
cd frontend

if [ ! -d "node_modules" ]; then
    echo "Installation des dépendances npm..."
    yarn install
fi

echo "Build du frontend en cours..."
yarn build

if [ ! -d "dist" ]; then
    echo -e "${RED}✗${NC} Le build du frontend a échoué"
    exit 1
fi

echo -e "${GREEN}✓${NC} Frontend compilé avec succès"
echo ""

echo "=== Étape 3/5 : Copie des fichiers ==="
cd ..

# Copier le frontend
rm -rf public/dist
cp -r frontend/dist public/
echo -e "${GREEN}✓${NC} Frontend copié dans public/dist"
echo ""

echo "=== Étape 4/5 : Rebuild du conteneur Docker ==="
cd ..

echo "Arrêt du conteneur existant..."
docker-compose -f docker-compose.traefik.yml stop core-tetrisnewsemailing

echo "Rebuild du conteneur (sans cache)..."
docker-compose -f docker-compose.traefik.yml build --no-cache core-tetrisnewsemailing

echo -e "${GREEN}✓${NC} Conteneur Docker reconstruit"
echo ""

echo "=== Étape 5/5 : Démarrage du conteneur ==="
docker-compose -f docker-compose.traefik.yml up -d core-tetrisnewsemailing

echo ""
echo "Attente du démarrage du service (10 secondes)..."
sleep 10

echo ""
echo "=== Vérification des logs ==="
docker-compose -f docker-compose.traefik.yml logs --tail=30 core-tetrisnewsemailing

echo ""
echo "================================================"
echo -e "${GREEN}✅ Déploiement terminé avec succès !${NC}"
echo "================================================"
echo ""
echo "Le correctif SQL a été appliqué et déployé."
echo ""
echo -e "${YELLOW}Prochaines étapes :${NC}"
echo "1. Ouvrez votre navigateur"
echo "2. Allez sur la page Prospects"
echo "3. Vérifiez que l'erreur SQL n'apparaît plus"
echo ""
echo "Pour voir les logs en temps réel :"
echo "  docker-compose -f docker-compose.traefik.yml logs -f core-tetrisnewsemailing"
echo ""
