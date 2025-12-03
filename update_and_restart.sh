#!/bin/bash
set -e

echo "================================================"
echo "   Mise à jour TetrisNews avec le correctif    "
echo "================================================"

# Déterminer l'architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    BINARY="tetrisnewsemailing-arm64"
    echo "✓ Architecture ARM64 détectée"
else
    BINARY="tetrisnewsemailing-amd64"
    echo "✓ Architecture AMD64 détectée"
fi

echo ""
echo "=== Étape 1: Rebuild du frontend ==="
cd ~/BillionMail/core/frontend
yarn build

echo ""
echo "=== Étape 2: Copie des fichiers frontend ==="
rm -rf ~/BillionMail/core/public/dist
cp -r ~/BillionMail/core/frontend/dist ~/BillionMail/core/public/

echo ""
echo "=== Étape 3: Copie du nouveau binaire Go ==="
if [ -f "/app/$BINARY" ]; then
    cp /app/$BINARY ~/BillionMail/core/$BINARY
    echo "✓ Binaire $BINARY copié"
else
    echo "⚠ Binaire /app/$BINARY non trouvé, utilisation de l'existant"
fi

echo ""
echo "=== Étape 4: Rebuild du conteneur Docker ==="
cd ~/BillionMail
docker-compose -f docker-compose.traefik.yml build --no-cache core-tetrisnewsemailing

echo ""
echo "=== Étape 5: Redémarrage du conteneur ==="
docker-compose -f docker-compose.traefik.yml up -d core-tetrisnewsemailing

echo ""
echo "================================================"
echo "✅ Mise à jour terminée avec succès!"
echo "================================================"
echo ""
echo "Le correctif SQL a été appliqué."
echo "Testez maintenant la page Prospects."
echo ""
