#!/bin/bash
set -e

# Détection de la commande Docker Compose
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    DOCKER_COMPOSE="docker compose"
fi

echo "========================================"
echo "1. Compilation du binaire Go (Backend)..."
echo "========================================"

# S'assurer que le script de build est exécutable
if [ -f "core/go-build.sh" ]; then
    chmod +x core/go-build.sh
fi

# On détecte si on est sur le système hôte sans 'apk' (Debian/Ubuntu)
if ! command -v apk &> /dev/null; then
    echo "⚠️ Environnement non-Alpine détecté. Lancement du build via Docker (Alpine)..."
    
    # Utilisation de bash pour exécuter le script pour éviter les erreurs de permission "./"
    docker run --rm -v "$(pwd)/core:/opt/core" -w /opt/core alpine:3.20 sh -c "apk update && apk add --no-cache go file bash && bash go-build.sh all"
    
else
    # Si on est déjà sur Alpine ou si on veut forcer le local
    cd core
    bash go-build.sh all
    cd ..
fi

echo ""
echo "========================================"
echo "2. Construction de l'image Docker locale..."
echo "========================================"

# Reconstruction de l'image avec un tag personnalisé pour éviter les conflits
docker build -f Dockerfiles/core/Dockerfile -t billionmail/core:custom .

echo ""
echo "========================================"
echo "3. Redémarrage du service core-billionmail..."
echo "========================================"

# Redémarrage du conteneur spécifique avec la nouvelle image
$DOCKER_COMPOSE -f docker-compose.traefik-fixed.yml up -d core-billionmail

echo ""
echo "========================================"
echo "4. Nettoyage des anciennes versions..."
echo "========================================"

# Supprime les images "dangling" (l'ancienne version qui a été remplacée)
docker image prune -f

echo ""
echo "✅ Déploiement terminé ! Vous utilisez maintenant la version 'custom' unique."
