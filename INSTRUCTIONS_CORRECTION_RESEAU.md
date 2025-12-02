# 🚀 Instructions Rapides - Correction Erreur Réseau

## ❌ Problème
Vous obtenez l'erreur suivante lors du redémarrage de `core-tetrisnewsemailing`:
```
failed to create network tetrisnews-emailing_tetrisnewsemailing-network: 
Error response from daemon: numerical result out of range
```

## ✅ Solution en 3 Commandes

### Sur votre serveur, exécutez:

```bash
# 1. Copier les scripts de correction
cp /app/fix_traefik_network.sh ~/TetrisNewsEmailing/
cp /app/diagnostic_rapide.sh ~/TetrisNewsEmailing/

# 2. Se placer dans le dossier
cd ~/TetrisNewsEmailing

# 3. Exécuter le script de correction
chmod +x fix_traefik_network.sh
sudo bash fix_traefik_network.sh
```

**C'est tout! 🎉** Le script va automatiquement:
- ✅ Diagnostiquer votre configuration
- ✅ Nettoyer les anciens conteneurs/réseaux
- ✅ Corriger les variables `.env`
- ✅ Créer le réseau Traefik `web`
- ✅ Démarrer tous les services

---

## 🔍 Diagnostic Avant Correction (Optionnel)

Si vous voulez d'abord voir quel est le problème:

```bash
cd ~/TetrisNewsEmailing
chmod +x diagnostic_rapide.sh
bash diagnostic_rapide.sh
```

---

## 📋 Vérification Après Correction

```bash
# Voir l'état des services
docker compose -f docker-compose.traefik.yml ps
```

Tous les services doivent afficher **"Up"**:
- ✅ core-tetrisnewsemailing
- ✅ dovecot-tetrisnewsemailing
- ✅ postfix-tetrisnewsemailing
- ✅ pgsql-tetrisnewsemailing
- ✅ redis-tetrisnewsemailing
- ✅ rspamd-tetrisnewsemailing
- ✅ webmail-tetrisnewsemailing

---

## 🌐 Accès à l'Application

Une fois les services démarrés:

| Service | URL | Login |
|---------|-----|-------|
| **Interface Admin** | https://emailing.tetrisnews.fr | billion / billion |
| **WebMail** | https://emailing.tetrisnews.fr/roundcube/ | (après création) |

⚠️ **Note SSL**: Le certificat Let's Encrypt peut prendre 1-2 minutes pour être généré.

---

## 🛠️ Commandes Utiles

```bash
# Voir les logs en temps réel
docker compose -f docker-compose.traefik.yml logs -f

# Redémarrer un service
docker compose -f docker-compose.traefik.yml restart core-tetrisnewsemailing

# Arrêter tous les services
docker compose -f docker-compose.traefik.yml down

# Démarrer tous les services
docker compose -f docker-compose.traefik.yml up -d
```

---

## 📖 Documentation Complète

Pour plus de détails, consultez:
- **Guide complet**: `cat /app/SOLUTION_RESEAU_TRAEFIK.md`
- **Configuration Traefik**: `cat /app/GUIDE_CONFIGURATION_TRAEFIK.md`

---

## ❓ Besoin d'Aide ?

Si le problème persiste après avoir exécuté le script:

1. Vérifiez les logs:
   ```bash
   docker compose -f docker-compose.traefik.yml logs
   ```

2. Vérifiez votre fichier `.env`:
   ```bash
   cat .env | grep -E "IPV4_NETWORK|DOMAIN|TETRISNEWSEMAILING_HOSTNAME"
   ```

3. Assurez-vous que Traefik fonctionne:
   ```bash
   docker ps | grep traefik
   ```

---

## 🎯 Résumé

| Étape | Commande |
|-------|----------|
| 1. Copier les scripts | `cp /app/fix_traefik_network.sh ~/TetrisNewsEmailing/` |
| 2. Aller dans le dossier | `cd ~/TetrisNewsEmailing` |
| 3. Rendre exécutable | `chmod +x fix_traefik_network.sh` |
| 4. Exécuter | `sudo bash fix_traefik_network.sh` |
| 5. Vérifier | `docker compose -f docker-compose.traefik.yml ps` |

**Temps estimé**: 2-3 minutes ⏱️

---

**🎉 Votre serveur mail devrait fonctionner parfaitement après ces étapes!**
