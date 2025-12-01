# 🚀 Déploiement Tetrisnews Emailing sur GCP avec Traefik

## Prérequis

- VPS GCP avec Docker et Docker Compose installés
- Traefik déjà configuré avec le réseau `web`
- Un domaine pointant vers votre VPS (ex: `mail.votredomaine.com`)
- Ports ouverts: 25, 465, 587, 143, 993, 110, 995

## 📁 Fichiers de déploiement

| Fichier | Description |
|---------|-------------|
| `docker-compose.traefik.yml` | Configuration Docker avec Traefik |
| `.env.example` | Template de configuration |
| `deploy-traefik.sh` | Script de déploiement automatisé |

---

## 🛠 Installation Rapide

### 1. Cloner le projet sur votre VPS

```bash
# Sur votre VPS GCP
cd /opt
git clone <votre-repo> tetrisnews-emailing
cd tetrisnews-emailing
```

### 2. Configurer l'environnement

```bash
# Copier le template
cp .env.example .env

# Éditer avec vos paramètres
nano .env
```

**Paramètres obligatoires à modifier:**

```env
# Votre domaine
DOMAIN=mail.votredomaine.com
BILLIONMAIL_HOSTNAME=mail.votredomaine.com

# Identifiants admin
ADMIN_USERNAME=admin
ADMIN_PASSWORD=VotreMotDePasseSecurise123!

# Mots de passe base de données (générez-les!)
DBPASS=MotDePassePostgreSQL_Securise
REDISPASS=MotDePasseRedis_Securise
```

💡 **Générer des mots de passe sécurisés:**
```bash
openssl rand -base64 32
```

### 3. Lancer le déploiement

```bash
chmod +x deploy-traefik.sh
./deploy-traefik.sh
```

---

## 🔧 Installation Manuelle

Si vous préférez ne pas utiliser le script:

```bash
# 1. Créer le fichier .env
cp .env.example .env
nano .env

# 2. Créer les répertoires
mkdir -p postgresql-data postgresql-socket redis-data rspamd-data \
         vmail-data postfix-data webmail-data core-data php-sock ssl \
         logs/{postfix,dovecot,rspamd,fail2ban,core}

# 3. Vérifier que le réseau Traefik existe
docker network ls | grep web || docker network create web

# 4. Démarrer les services
docker compose -f docker-compose.traefik.yml up -d

# 5. Vérifier le statut
docker compose -f docker-compose.traefik.yml ps
```

---

## 🌐 Configuration DNS

Ajoutez ces enregistrements DNS chez votre registrar:

| Type | Nom | Valeur | Priorité |
|------|-----|--------|----------|
| A | mail | `IP_DE_VOTRE_VPS` | - |
| MX | @ | mail.votredomaine.com | 10 |
| TXT | @ | `v=spf1 mx a ip4:IP_VPS ~all` | - |
| TXT | _dmarc | `v=DMARC1; p=quarantine; rua=mailto:admin@votredomaine.com` | - |

> ⚠️ Le DKIM sera généré automatiquement dans l'interface admin.

---

## 🔒 Configuration Traefik

Si votre Traefik n'est pas encore configuré, voici un exemple de `traefik.yml`:

```yaml
# /etc/traefik/traefik.yml
api:
  dashboard: true

entryPoints:
  http:
    address: ":80"
  https:
    address: ":443"

certificatesResolvers:
  letsencrypt:
    acme:
      email: votre@email.com
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: http

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: web
```

---

## 📊 Accès à l'application

Une fois déployé:

| Service | URL |
|---------|-----|
| **Interface Admin** | `https://mail.votredomaine.com/tetrisnews` |
| **Webmail** | `https://mail.votredomaine.com/roundcube` |

---

## 🛡 Commandes utiles

```bash
# Voir les logs en temps réel
docker compose -f docker-compose.traefik.yml logs -f

# Logs d'un service spécifique
docker compose -f docker-compose.traefik.yml logs -f core-tetrisnewsemailing

# Redémarrer tous les services
docker compose -f docker-compose.traefik.yml restart

# Redémarrer un service spécifique
docker compose -f docker-compose.traefik.yml restart core-tetrisnewsemailing

# Arrêter l'application
docker compose -f docker-compose.traefik.yml down

# Mise à jour
docker compose -f docker-compose.traefik.yml pull
docker compose -f docker-compose.traefik.yml up -d
```

---

## 🔥 Firewall GCP

Assurez-vous que ces ports sont ouverts dans les règles de pare-feu GCP:

```
TCP 25   - SMTP
TCP 465  - SMTPS
TCP 587  - Submission
TCP 143  - IMAP
TCP 993  - IMAPS
TCP 110  - POP3
TCP 995  - POP3S
TCP 80   - HTTP (Traefik)
TCP 443  - HTTPS (Traefik)
```

---

## 🐛 Dépannage

### Les conteneurs ne démarrent pas
```bash
# Vérifier les logs
docker compose -f docker-compose.traefik.yml logs

# Vérifier l'espace disque
df -h

# Vérifier les permissions
ls -la postgresql-data/
```

### Traefik ne route pas le trafic
```bash
# Vérifier que le conteneur est sur le bon réseau
docker network inspect web

# Vérifier les labels Traefik
docker inspect core-tetrisnewsemailing | grep -A 50 Labels
```

### Problème de certificat SSL
```bash
# Vérifier les logs Traefik
docker logs traefik

# Vérifier que le domaine pointe bien vers le VPS
dig mail.votredomaine.com
```

---

## 📞 Support

Pour toute question, consultez:
- [Documentation TetrisNewsEmailing](https://www.tetrisnewsemailing.com/)
- [Issues GitHub](https://github.com/aaPanel/TetrisNewsEmailing/issues)
