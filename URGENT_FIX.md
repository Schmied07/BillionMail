# 🚨 URGENT - Conflit Réseau Détecté

## ⚠️ Problème Identifié

Votre **ancien déploiement BillionMail** est encore en cours d'exécution et cause un conflit de réseau avec le nouveau déploiement.

**Conteneurs actifs détectés :**
- `tetrisnews-emailing-core-billionmail-1`
- `tetrisnews-emailing-dovecot-billionmail-1`
- `tetrisnews-emailing-postfix-billionmail-1`
- Et autres...

Ces conteneurs utilisent le même espace d'adressage IP que votre nouveau déploiement.

---

## ✅ Solution Rapide (30 secondes)

### Option 1 : Script Automatique (Recommandé)

```bash
cd ~/BillionMail
cp /app/stop_old_and_start_new.sh .
sudo bash stop_old_and_start_new.sh
```

Le script va :
- ✅ Arrêter tous les anciens conteneurs
- ✅ Supprimer les anciens conteneurs
- ✅ Supprimer les réseaux en conflit
- ✅ Démarrer les nouveaux services

---

### Option 2 : Commandes Manuelles

```bash
cd ~/BillionMail

# 1. Arrêter tous les anciens conteneurs
docker stop tetrisnews-emailing-core-billionmail-1 \
            tetrisnews-emailing-webmail-billionmail-1 \
            tetrisnews-emailing-dovecot-billionmail-1 \
            tetrisnews-emailing-postfix-billionmail-1 \
            tetrisnews-emailing-rspamd-billionmail-1 \
            tetrisnews-emailing-pgsql-billionmail-1 \
            tetrisnews-emailing-redis-billionmail-1

# 2. Supprimer les anciens conteneurs
docker rm tetrisnews-emailing-core-billionmail-1 \
          tetrisnews-emailing-webmail-billionmail-1 \
          tetrisnews-emailing-dovecot-billionmail-1 \
          tetrisnews-emailing-postfix-billionmail-1 \
          tetrisnews-emailing-rspamd-billionmail-1 \
          tetrisnews-emailing-pgsql-billionmail-1 \
          tetrisnews-emailing-redis-billionmail-1

# 3. Supprimer les réseaux en conflit
docker network rm tetrisnews-emailing_billionmail-network 2>/dev/null || true
docker network prune -f

# 4. Démarrer les nouveaux services
docker compose up -d
```

---

### Option 3 : Nettoyage Complet (⚠️ Plus Agressif)

Si les options ci-dessus ne fonctionnent pas :

```bash
cd ~/BillionMail

# Arrêter TOUS les conteneurs liés à billionmail/tetrisnews
docker ps -a | grep -E "billionmail|tetrisnews-emailing" | awk '{print $1}' | xargs docker stop
docker ps -a | grep -E "billionmail|tetrisnews-emailing" | awk '{print $1}' | xargs docker rm

# Supprimer tous les réseaux inutilisés
docker network prune -f

# Redémarrer
docker compose up -d
```

---

## 🔍 Vérification

Après avoir exécuté la solution, vérifiez :

```bash
# Voir les nouveaux conteneurs
docker compose ps

# Tous devraient afficher "Up"
```

### Résultat Attendu

```
NAME                                              STATUS
tetrisnewsemailing-core-tetrisnewsemailing-1      Up
tetrisnewsemailing-dovecot-tetrisnewsemailing-1   Up
tetrisnewsemailing-postfix-tetrisnewsemailing-1   Up
tetrisnewsemailing-pgsql-tetrisnewsemailing-1     Up
tetrisnewsemailing-redis-tetrisnewsemailing-1     Up
tetrisnewsemailing-rspamd-tetrisnewsemailing-1    Up
tetrisnewsemailing-webmail-tetrisnewsemailing-1   Up
```

**Notez le changement** : `billionmail` → `tetrisnewsemailing` dans les noms

---

## 🌐 Accès

Une fois les services démarrés :

```bash
# Vérifier que tout fonctionne
docker compose logs -f
```

**Accès Web :**
- Interface : http://emailing.tetrisnews.fr
- WebMail : http://emailing.tetrisnews.fr/roundcube/

---

## 💾 Données Préservées ?

**OUI !** Les données sont stockées dans des volumes locaux :

```
~/BillionMail/postgresql-data/
~/BillionMail/vmail-data/
~/BillionMail/redis-data/
~/BillionMail/rspamd-data/
```

Ces répertoires sont **préservés** lors du remplacement des conteneurs. Vos emails et configurations existantes sont **sûrs**.

---

## ❓ FAQ

### Q: Pourquoi ce conflit ?
**R:** L'ancien déploiement utilisait `billionmail` dans les noms. Le nouveau utilise `tetrisnewsemailing`. Les deux essaient d'utiliser le même réseau IP.

### Q: Vais-je perdre mes données ?
**R:** Non, les données sont dans des volumes montés sur le disque local, pas dans les conteneurs.

### Q: Et mes emails existants ?
**R:** Ils sont préservés dans `~/BillionMail/vmail-data/` et seront accessibles avec les nouveaux conteneurs.

### Q: Dois-je reconfigurer quelque chose ?
**R:** Non, le nouveau déploiement utilise le même fichier `.env` et les mêmes volumes de données.

---

## 🚀 Commande Unique

**Pour résoudre tout en une commande :**

```bash
cd ~/BillionMail && cp /app/stop_old_and_start_new.sh . && sudo bash stop_old_and_start_new.sh
```

**C'est tout !** 🎉

---

## 📞 Logs de Dépannage

Si un service ne démarre pas :

```bash
# Voir tous les logs
docker compose logs

# Log d'un service spécifique
docker compose logs postfix-tetrisnewsemailing

# Logs en temps réel
docker compose logs -f
```

---

## ✅ Validation Finale

```bash
# État des services
docker compose ps

# Test de connexion
telnet localhost 25
telnet localhost 143

# Vérifier l'interface web
curl http://localhost/
```

**Votre nouveau déploiement devrait maintenant fonctionner parfaitement !** 🚀
