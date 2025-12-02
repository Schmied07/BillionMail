# 🔧 Solution Complète - Erreur Réseau Docker avec Traefik

## 🔍 Diagnostic du Problème

L'erreur `numerical result out of range` lors du redémarrage de `core-tetrisnewsemailing` indique un **conflit de configuration réseau Docker**.

### Causes possibles:
1. ❌ Variable `IPV4_NETWORK` invalide dans le fichier `.env`
2. ❌ Plage de sous-réseau déjà utilisée par un autre réseau Docker
3. ❌ Anciens conteneurs ou réseaux en conflit
4. ❌ Variables manquantes pour Traefik (`DOMAIN`, `TETRISNEWSEMAILING_HOSTNAME`)

---

## ✅ Solution Automatique (Recommandée)

### 🚀 Exécution en 2 étapes

**1. Copiez le script de correction dans votre dossier:**
```bash
cp /app/fix_traefik_network.sh ~/TetrisNewsEmailing/
cd ~/TetrisNewsEmailing
```

**2. Exécutez le script:**
```bash
chmod +x fix_traefik_network.sh
sudo bash fix_traefik_network.sh
```

### Ce que fait le script automatiquement:

✅ **Diagnostic complet** de votre configuration actuelle  
✅ **Backup automatique** de votre fichier `.env`  
✅ **Nettoyage des anciens conteneurs** et réseaux en conflit  
✅ **Détection automatique** d'une plage réseau disponible  
✅ **Création du réseau Traefik** `web` si nécessaire  
✅ **Correction des variables** `.env` (IPV4_NETWORK, DOMAIN, TETRISNEWSEMAILING_HOSTNAME)  
✅ **Démarrage des services** avec `docker-compose.traefik.yml`  
✅ **Vérification finale** de l'état des services

---

## 🛠️ Solution Manuelle (Si vous préférez)

Si vous souhaitez effectuer les corrections manuellement:

### Étape 1: Backup du .env
```bash
cd ~/TetrisNewsEmailing
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
```

### Étape 2: Arrêter les services
```bash
docker compose -f docker-compose.traefik.yml down
```

### Étape 3: Nettoyer les anciens réseaux
```bash
# Supprimer les anciens conteneurs
docker ps -a | grep -E "tetrisnews|tetrisnewsemailing" | awk '{print $1}' | xargs docker rm -f 2>/dev/null

# Supprimer les anciens réseaux
docker network rm tetrisnews-emailing_tetrisnews-network 2>/dev/null || true
docker network prune -f
```

### Étape 4: Créer le réseau Traefik
```bash
# Vérifier si le réseau 'web' existe
docker network inspect web >/dev/null 2>&1

# Si non, le créer
docker network create web
```

### Étape 5: Corriger le fichier .env
```bash
nano .env
```

Assurez-vous que ces variables sont présentes et correctes:
```env
# Réseau Docker interne (choisir une plage disponible)
IPV4_NETWORK=172.22.1

# Domaine pour l'application
TETRISNEWSEMAILING_HOSTNAME=emailing.tetrisnews.fr

# Domaine pour Traefik (même valeur)
DOMAIN=emailing.tetrisnews.fr
```

💡 **Astuce**: Si `172.22.1` ne fonctionne pas, essayez:
- `172.23.1`
- `172.24.1`
- `10.10.1`

### Étape 6: Démarrer les services
```bash
docker compose -f docker-compose.traefik.yml up -d
```

### Étape 7: Vérifier l'état
```bash
docker compose -f docker-compose.traefik.yml ps
```

---

## 🔍 Diagnostic Avancé

### Voir les réseaux Docker existants
```bash
docker network ls
```

### Voir les plages IP utilisées
```bash
docker network ls --format "{{.Name}}" | xargs -I {} docker network inspect {} --format '{{.Name}}: {{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null
```

### Identifier les conflits
```bash
# Voir quels conteneurs utilisent quels réseaux
docker ps --format "{{.Names}}" | xargs -I {} sh -c 'echo "Container: {}"; docker inspect {} --format "{{range .NetworkSettings.Networks}}  - {{.NetworkID}} ({{.IPAddress}}){{end}}"'
```

---

## 📋 Vérification Post-Installation

### 1. Vérifier que tous les services sont "Up"
```bash
docker compose -f docker-compose.traefik.yml ps
```

**Résultat attendu:**
```
NAME                                              STATUS
tetrisnews-emailing-core-tetrisnewsemailing-1     Up
tetrisnews-emailing-dovecot-tetrisnewsemailing-1  Up
tetrisnews-emailing-postfix-tetrisnewsemailing-1  Up
tetrisnews-emailing-pgsql-tetrisnewsemailing-1    Up
tetrisnews-emailing-redis-tetrisnewsemailing-1    Up
tetrisnews-emailing-rspamd-tetrisnewsemailing-1   Up
tetrisnews-emailing-webmail-tetrisnewsemailing-1  Up
```

### 2. Vérifier les réseaux
```bash
docker network inspect tetrisnews-emailing_tetrisnews-network
docker network inspect web
```

### 3. Vérifier les logs
```bash
# Tous les logs
docker compose -f docker-compose.traefik.yml logs --tail=50

# Log d'un service spécifique
docker compose -f docker-compose.traefik.yml logs core-tetrisnewsemailing
```

### 4. Tester l'accès HTTPS
```bash
# Via curl
curl -I https://emailing.tetrisnews.fr/

# Ou dans votre navigateur
# https://emailing.tetrisnews.fr
```

---

## 🌐 Accès à l'Application

Une fois les services démarrés:

| Service | URL | Identifiants |
|---------|-----|--------------|
| **Interface Admin** | https://emailing.tetrisnews.fr | billion / billion |
| **WebMail (RoundCube)** | https://emailing.tetrisnews.fr/roundcube/ | (après création mailbox) |

⚠️ **Note importante sur SSL:**
Le certificat SSL Let's Encrypt peut prendre **1-2 minutes** pour être généré par Traefik. Si vous obtenez une erreur SSL, attendez un peu et réessayez.

---

## 🐛 Dépannage

### Problème: Service ne démarre pas
```bash
# Voir les logs d'erreur
docker compose -f docker-compose.traefik.yml logs <nom-service>

# Exemple:
docker compose -f docker-compose.traefik.yml logs core-tetrisnewsemailing
```

### Problème: Erreur "network already exists"
```bash
# Supprimer le réseau problématique
docker network rm <nom-du-réseau>

# Puis redémarrer
docker compose -f docker-compose.traefik.yml up -d
```

### Problème: 404 Not Found via Traefik
```bash
# Vérifier que le conteneur est bien sur le réseau 'web'
docker network inspect web | grep tetrisnews

# Vérifier les labels Traefik
docker inspect tetrisnews-emailing-core-tetrisnewsemailing-1 | grep -A 10 Labels

# Redémarrer Traefik (si nécessaire)
docker restart traefik
```

### Problème: Certificat SSL non généré
```bash
# Vérifier les logs Traefik
docker logs traefik 2>&1 | grep -i "emailing.tetrisnews.fr"

# Vérifier que le domaine pointe bien vers votre serveur
dig emailing.tetrisnews.fr

# Forcer la régénération (redémarrer Traefik)
docker restart traefik
```

### Problème: "Port already allocated"
```bash
# Voir quel processus utilise le port
sudo lsof -i :80
sudo lsof -i :443

# Si c'est un ancien conteneur, le supprimer
docker ps -a | grep <nom-conteneur>
docker rm -f <nom-conteneur>
```

---

## 📝 Commandes Utiles

### Gestion des services
```bash
# Démarrer
docker compose -f docker-compose.traefik.yml up -d

# Arrêter
docker compose -f docker-compose.traefik.yml down

# Redémarrer tous les services
docker compose -f docker-compose.traefik.yml restart

# Redémarrer un service spécifique
docker compose -f docker-compose.traefik.yml restart core-tetrisnewsemailing

# Voir les logs en temps réel
docker compose -f docker-compose.traefik.yml logs -f

# Reconstruire et redémarrer
docker compose -f docker-compose.traefik.yml up -d --build
```

### Nettoyage
```bash
# Nettoyer les conteneurs arrêtés
docker container prune -f

# Nettoyer les réseaux inutilisés
docker network prune -f

# Nettoyer les images non utilisées
docker image prune -a -f

# Nettoyer tout (⚠️ attention!)
docker system prune -a --volumes -f
```

---

## 🔄 Restauration de Backup

Si quelque chose ne va pas, restaurez votre configuration:

```bash
cd ~/TetrisNewsEmailing

# Lister les backups disponibles
ls -la .env.backup.*

# Restaurer un backup
cp .env.backup.YYYYMMDD_HHMMSS .env

# Redémarrer
docker compose -f docker-compose.traefik.yml down
docker compose -f docker-compose.traefik.yml up -d
```

---

## 📞 Support

### Vérifications de base:
1. ✅ Tous les services sont "Up" → `docker compose -f docker-compose.traefik.yml ps`
2. ✅ Le réseau `web` existe → `docker network ls | grep web`
3. ✅ Les variables `.env` sont correctes → `cat .env | grep -E "IPV4_NETWORK|DOMAIN|TETRISNEWSEMAILING_HOSTNAME"`
4. ✅ Traefik fonctionne → `docker ps | grep traefik`

### Ressources:
- 📖 [Documentation TetrisNewsEmailing](https://www.tetrisnewsemailing.com/)
- 🐙 [GitHub Issues](https://github.com/aaPanel/TetrisNewsEmailing/issues)
- 📧 [Documentation Traefik](https://doc.traefik.io/traefik/)

---

## ✅ Résumé de la Solution

| Étape | Action | Commande |
|-------|--------|----------|
| 1️⃣ | Copier le script | `cp /app/fix_traefik_network.sh ~/TetrisNewsEmailing/` |
| 2️⃣ | Se placer dans le dossier | `cd ~/TetrisNewsEmailing` |
| 3️⃣ | Rendre exécutable | `chmod +x fix_traefik_network.sh` |
| 4️⃣ | Exécuter | `sudo bash fix_traefik_network.sh` |
| 5️⃣ | Vérifier | `docker compose -f docker-compose.traefik.yml ps` |
| 6️⃣ | Accéder | `https://emailing.tetrisnews.fr` |

---

**🎉 Votre serveur mail TetrisNews devrait maintenant fonctionner correctement avec Traefik!**
