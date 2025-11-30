#!/bin/bash

# Script de déploiement pour appliquer les modifications locales
# Ce script compile le code Go, reconstruit l'image Docker et redémarre le service.

set -e # Arrêter en cas d'erreur

echo "========================================"
echo "1. Compilation du binaire Go (Backend)..."
echo "========================================"

cd core

# Utilisation du script de build existant pour compiler pour toutes les architectures
# Assurez-vous que Go est installé ou que ce script peut s'exécuter
if [ -f "go-build.sh" ]; then
    bash go-build.sh all
else
    echo "Erreur : go-build.sh introuvable dans core/"
    exit 1
fi

cd ..

echo ""
echo "========================================"
echo "2. Construction de l'image Docker locale..."
echo "========================================"

# On reconstruit l'image en utilisant le tag défini dans docker-compose.traefik-fixed.yml (billionmail/core:4.8.3)
# Cela permet d'utiliser l'image locale fraîchement construite au lieu de celle du registre
docker build -f Dockerfiles/core/Dockerfile -t billionmail/core:4.8.3 .

echo ""
echo "========================================"
echo "3. Redémarrage du service core-billionmail..."
echo "========================================"

# On utilise 'up -d' pour recréer le conteneur avec la nouvelle image
# 'restart' ne suffit pas car il réutiliserait l'ancienne image si elle n'est pas recréée
docker compose -f docker-compose.traefik-fixed.yml up -d core-billionmail

echo ""
echo "✅ Déploiement terminé avec succès ! La nouvelle version devrait être active."
