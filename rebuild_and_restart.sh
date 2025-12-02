#!/bin/bash

echo "🔄 Reconstruction de l'image Docker et redémarrage des conteneurs..."
echo ""

# Change to app directory
cd /app

# Stop containers
echo "1️⃣ Arrêt des conteneurs..."
docker-compose -f docker-compose.traefik.yml down

# Rebuild core image with no cache
echo ""
echo "2️⃣ Reconstruction de l'image core (sans cache)..."
docker-compose -f docker-compose.traefik.yml build --no-cache core-tetrisnewsemailing

# Start all containers
echo ""
echo "3️⃣ Démarrage de tous les conteneurs..."
docker-compose -f docker-compose.traefik.yml up -d

# Wait a bit for containers to start
echo ""
echo "4️⃣ Attente du démarrage des conteneurs..."
sleep 5

# Check status
echo ""
echo "5️⃣ Vérification de l'état des conteneurs..."
docker-compose -f docker-compose.traefik.yml ps

echo ""
echo "✅ Terminé ! Vos modifications devraient maintenant être visibles."
echo ""
echo "⚠️  Si vous ne voyez toujours pas les changements:"
echo "   1. Effacez le cache de votre navigateur (Ctrl+Shift+R ou Cmd+Shift+R)"
echo "   2. Ouvrez une fenêtre de navigation privée"
echo "   3. Attendez quelques secondes pour que Traefik mette à jour son cache"
