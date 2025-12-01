# 🚀 Guide de Configuration BillionMail avec Traefik

## 📋 Ce qui a été modifié

### Problème initial:
- BillionMail exposait directement les ports 80 et 443
- Conflit avec Traefik qui écoute déjà sur ces ports
- Aucun label Traefik configuré
- ➡️ Résultat: Application inaccessible (404 Not Found)

### Solution appliquée:
✅ Ajout des labels Traefik au service `core-tetrisnewsemailing`  
✅ Connexion au réseau `web` de Traefik  
✅ Suppression de l'exposition directe des ports 80/443  
✅ Configuration du certificat SSL automatique (Let's Encrypt)  
✅ Routage HTTPS pour `emailing.tetrisnews.fr`

---

## 🔧 Instructions d'installation

### 1. Copier les fichiers de configuration

Les fichiers suivants ont été créés:
- `docker-compose.traefik-fixed.yml` - Nouvelle configuration
- `fix_traefik_config.sh` - Script d'installation automatique

### 2. Exécuter le script d'installation

```bash
cd ~/BillionMail
chmod +x fix_traefik_config.sh
bash fix_traefik_config.sh
```

Le script va:
1. Sauvegarder votre configuration actuelle
2. Appliquer la nouvelle configuration
3. Créer le réseau `web` si nécessaire
4. Redémarrer les services BillionMail
5. Vérifier que tout fonctionne

### 3. Attendre la génération du certificat SSL

⏱️ **Patience!** Le certificat SSL Let's Encrypt peut prendre 1-2 minutes pour être généré.

---

## 🌐 Accès aux applications

### BillionMail (Application principale)
- **URL:** https://emailing.tetrisnews.fr/
- **Username:** billion
- **Password:** billion

### RoundCube (Webmail)
- **URL:** https://emailing.tetrisnews.fr/roundcube/
- **Username:** contact@tetrisnews.fr (après création)
- **Password:** @Schmied0629 (après création)

---

## 📧 Création d'une mailbox

Deux méthodes sont disponibles:

### Méthode 1: Via l'interface BillionMail (Recommandé)
1. Connectez-vous à https://emailing.tetrisnews.fr/
2. Allez dans "Domains" → Ajoutez `tetrisnews.fr`
3. Allez dans "Mailboxes" → Créez `contact@tetrisnews.fr`
4. Définissez le mot de passe: `@Schmied0629`

### Méthode 2: Via script (si l'interface ne fonctionne pas)
```bash
cd ~/BillionMail
chmod +x create_mailbox.sh
bash create_mailbox.sh
```

---

## 🔍 Vérification et Dépannage

### Vérifier que les services tournent:
```bash
cd ~/BillionMail
docker compose ps
```

Tous les services doivent être "Up":
- ✅ pgsql-tetrisnewsemailing
- ✅ redis-tetrisnewsemailing
- ✅ rspamd-tetrisnewsemailing
- ✅ dovecot-tetrisnewsemailing
- ✅ postfix-tetrisnewsemailing
- ✅ webmail-tetrisnewsemailing
- ✅ core-tetrisnewsemailing

### Vérifier les logs du service core:
```bash
docker logs tetrisnews-emailing-core-tetrisnewsemailing-1 --tail 50
```

### Vérifier que Traefik voit BillionMail:
```bash
docker logs traefik 2>&1 | grep tetrisnewsemailing
```

### Tester la connexion:
```bash
curl -I https://emailing.tetrisnews.fr/
```

Vous devriez voir un code HTTP 200 ou 301/302.

---

## 🔄 Restauration de la configuration originale

Si quelque chose ne va pas, restaurez l'ancienne configuration:

```bash
cd ~/BillionMail
cp docker-compose.yml.backup docker-compose.yml
docker compose down
docker compose up -d
```

---

## 📝 Configuration technique

### Labels Traefik ajoutés:
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.tetrisnewsemailing.rule=Host(`emailing.tetrisnews.fr`)"
  - "traefik.http.routers.tetrisnewsemailing.entrypoints=websecure"
  - "traefik.http.routers.tetrisnewsemailing.tls.certresolver=myresolver"
  - "traefik.http.services.tetrisnewsemailing.loadbalancer.server.port=80"
  - "traefik.docker.network=web"
```

### Réseaux:
- `tetrisnewsemailing-network` - Réseau interne pour la communication entre services
- `web` - Réseau Traefik pour l'exposition externe

---

## ❓ Questions Fréquentes

### Q: Pourquoi https://emailing.tetrisnews.fr/ ne fonctionne pas immédiatement?
**R:** Le certificat SSL Let's Encrypt prend 1-2 minutes pour être généré. Attendez un peu!

### Q: J'obtiens une erreur SSL
**R:** Normal! Le certificat est en cours de génération. Attendez 2 minutes et réessayez.

### Q: RoundCube donne une erreur 401
**R:** Vous devez d'abord créer une mailbox. Suivez les instructions dans la section "Création d'une mailbox".

### Q: L'interface BillionMail est en anglais
**R:** Vous pouvez changer la langue dans les paramètres après connexion.

### Q: Je n'arrive pas à me connecter avec billion/billion
**R:** Vérifiez les logs du service core et assurez-vous que tous les services sont démarrés.

---

## 📞 Support

Si vous rencontrez des problèmes:

1. Vérifiez les logs: `docker compose logs`
2. Vérifiez l'état des services: `docker compose ps`
3. Vérifiez la configuration Traefik: `docker logs traefik`
4. Consultez la documentation officielle: https://www.tetrisnewsemailing.com/

---

**Fait avec ❤️ pour TetrisNews**
