#!/bin/bash
set -e

echo "========================================"
echo "1. Compilation du binaire Go (Backend)..."
echo "========================================"

# On détecte si on est sur le système hôte sans 'apk' (Debian/Ubuntu)
# Si c'est le cas, on lance la compilation dans un conteneur Docker Alpine pour garantir la compatibilité
if ! command -v apk &> /dev/null; then
    echo "⚠️ Environnement non-Alpine détecté. Lancement du build via Docker (Alpine)..."
    
    # On utilise une image alpine pour compiler, en montant le dossier core
    # On installe go, file et bash (requis par go-build.sh)
    docker run --rm -v "$(pwd)/core:/opt/core" -w /opt/core alpine:3.20 sh -c "apk update && apk add --no-cache go file bash && ./go-build.sh all"
    
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

# Reconstruction de l'image avec le nouveau binaire
docker build -f Dockerfiles/core/Dockerfile -t billionmail/core:4.8.3 .

echo ""
echo "========================================"
echo "3. Redémarrage du service core-billionmail..."
echo "========================================"

# Redémarrage du conteneur spécifique
docker compose -f docker-compose.traefik-fixed.yml up -d core-billionmail

echo ""
echo "✅ Déploiement terminé avec succès !"
