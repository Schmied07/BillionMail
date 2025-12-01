# 🔧 Fix Rapide - Erreur Réseau "numerical result out of range"

## 🔍 Problème

L'erreur `numerical result out of range` signifie que la valeur `IPV4_NETWORK` dans votre `.env` est invalide ou cause un conflit.

---

## ✅ Solution Ultra-Rapide

### Copier et exécuter ce script depuis votre dépôt Git

Vous avez déjà `stop_old_and_start_new.sh` dans votre dépôt. Exécutez-le :

```bash
cd ~/BillionMail
sudo bash stop_old_and_start_new.sh
```

**OU**

### Solution Manuelle (3 commandes)

```bash
cd ~/BillionMail

# 1. Changer le réseau à une valeur sûre
sed -i 's/^IPV4_NETWORK=.*/IPV4_NETWORK=172.22.1/' .env

# 2. Ajouter TETRISNEWSEMAILING_HOSTNAME si manquant
grep -q "^TETRISNEWSEMAILING_HOSTNAME=" .env || echo "TETRISNEWSEMAILING_HOSTNAME=emailing.tetrisnews.fr" >> .env

# 3. Démarrer les services
docker compose up -d
```

---

## 🔧 Solution Alternative avec Script

```bash
cd ~/BillionMail

# Copier le script de fix réseau depuis /app (si disponible)
# Si pas disponible, utilisez la solution manuelle ci-dessus

# Télécharger depuis votre repo Git
git pull

# Exécuter le script de réparation
sudo bash stop_old_and_start_new.sh
```

---

## 📝 Vérification du .env

Votre `.env` doit contenir ces variables :

```bash
# Vérifier
cat ~/BillionMail/.env | grep -E "IPV4_NETWORK|TETRISNEWSEMAILING_HOSTNAME"
```

**Valeurs attendues :**
```
IPV4_NETWORK=172.22.1
TETRISNEWSEMAILING_HOSTNAME=emailing.tetrisnews.fr
```

---

## 🚀 Si Toujours des Erreurs

### Essayer des plages réseau alternatives

```bash
cd ~/BillionMail

# Essayer 172.23.1
sed -i 's/^IPV4_NETWORK=.*/IPV4_NETWORK=172.23.1/' .env
docker compose up -d

# Si erreur, essayer 172.24.1
sed -i 's/^IPV4_NETWORK=.*/IPV4_NETWORK=172.24.1/' .env
docker compose up -d

# Si erreur, essayer 10.10.1
sed -i 's/^IPV4_NETWORK=.*/IPV4_NETWORK=10.10.1/' .env
docker compose up -d
```

---

## 🔍 Diagnostiquer les Réseaux Existants

```bash
# Voir tous les réseaux Docker
docker network ls

# Inspecter un réseau spécifique
docker network inspect <network-name>

# Voir les plages IP utilisées
docker network ls --format "{{.Name}}" | xargs -I {} docker network inspect {} --format '{{.Name}}: {{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null
```

---

## ✅ Vérification Finale

Une fois les services démarrés :

```bash
# Voir l'état
docker compose ps

# Vérifier les logs
docker compose logs --tail=50

# Tester la connectivité
docker exec tetrisnewsemailing-postfix-tetrisnewsemailing-1 ping -c 1 pgsql
```

---

## 📋 Résumé des Étapes Essentielles

1. **Modifier IPV4_NETWORK** dans `.env` à `172.22.1`
2. **Ajouter TETRISNEWSEMAILING_HOSTNAME** si absent
3. **Nettoyer les réseaux** : `docker network prune -f`
4. **Démarrer** : `docker compose up -d`

---

## 🎯 Commande Tout-en-Un

```bash
cd ~/BillionMail && \
sed -i 's/^IPV4_NETWORK=.*/IPV4_NETWORK=172.22.1/' .env && \
grep -q "^TETRISNEWSEMAILING_HOSTNAME=" .env || echo "TETRISNEWSEMAILING_HOSTNAME=emailing.tetrisnews.fr" >> .env && \
docker network prune -f && \
docker compose up -d
```

**Copiez-collez cette commande et c'est réglé !** 🚀
