#!/bin/bash

echo "========================================="
echo "Configuration de TetrisNewsEmailing avec Traefik"
echo "========================================="
echo ""

cd ~/TetrisNewsEmailing || cd /app

# Backup original docker-compose.yml
echo "1. Sauvegarde de la configuration actuelle..."
if [ ! -f "docker-compose.yml.backup" ]; then
    cp docker-compose.yml docker-compose.yml.backup
    echo "✅ Backup créé: docker-compose.yml.backup"
else
    echo "ℹ️  Backup existe déjà"
fi
echo ""

# Copy new configuration
echo "2. Application de la nouvelle configuration..."
if [ -f "docker-compose.traefik-fixed.yml" ]; then
    cp docker-compose.traefik-fixed.yml docker-compose.yml
    echo "✅ Nouvelle configuration appliquée"
else
    echo "❌ Erreur: docker-compose.traefik-fixed.yml introuvable!"
    exit 1
fi
echo ""

# Create web network if it doesn't exist
echo "3. Vérification du réseau Traefik 'web'..."
if ! docker network inspect web >/dev/null 2>&1; then
    echo "Création du réseau 'web'..."
    docker network create web
    echo "✅ Réseau 'web' créé"
else
    echo "✅ Réseau 'web' existe déjà"
fi
echo ""

# Stop services
echo "4. Arrêt des services TetrisNewsEmailing..."
docker compose down 2>/dev/null || docker-compose down 2>/dev/null
echo "✅ Services arrêtés"
echo ""

# Start services with new configuration
echo "5. Démarrage des services avec la nouvelle configuration..."
docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Services démarrés avec succès!"
else
    echo "❌ Erreur lors du démarrage des services"
    echo "Restauration de la configuration d'origine..."
    cp docker-compose.yml.backup docker-compose.yml
    docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null
    exit 1
fi
echo ""

# Wait for services to be ready
echo "6. Attente du démarrage complet des services (30 secondes)..."
sleep 30
echo ""

# Check service status
echo "7. Vérification de l'état des services..."
docker compose ps 2>/dev/null || docker-compose ps 2>/dev/null
echo ""

# Test connection
echo "8. Test de la connexion à TetrisNewsEmailing..."
echo "   Attendez quelques secondes pour que le certificat SSL soit généré..."
sleep 10
echo ""

echo "========================================="
echo "✅ CONFIGURATION TERMINÉE!"
echo "========================================="
echo ""
echo "🌐 Accédez à TetrisNewsEmailing:"
echo "   URL: https://emailing.tetrisnews.fr/"
echo ""
echo "📧 RoundCube (Webmail):"
echo "   URL: https://emailing.tetrisnews.fr/roundcube/"
echo ""
echo "⚠️  IMPORTANT:"
echo "   - Le certificat SSL peut prendre 1-2 minutes pour être généré"
echo "   - Patientez avant d'accéder au site"
echo "   - Si vous voyez une erreur SSL, attendez encore quelques instants"
echo ""
echo "📝 Identifiants par défaut TetrisNewsEmailing:"
echo "   Username: billion"
echo "   Password: billion"
echo ""
echo "========================================="
