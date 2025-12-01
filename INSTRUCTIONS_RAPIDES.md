# 🚀 Instructions Rapides - Correction Problème TetrisNews Emailing

## 🔴 Problèmes Détectés

1. **Variable manquante** : `TETRISNEWSEMAILING_HOSTNAME` n'est pas définie dans votre `.env`
2. **Images Docker manquantes** : Certaines images doivent être construites localement (pas disponibles sur Docker Hub)
3. **Ancien réseau** : Conflit potentiel avec `172.66.1.0/24`

---

## ✅ Solution en 2 Commandes

### Option 1 : Script Automatique (Recommandé) 🎯

```bash
cd ~/BillionMail
sudo bash /app/fix_env_and_build.sh
```

Ce script va :
- ✅ Sauvegarder votre `.env` actuel
- ✅ Ajouter la variable `TETRISNEWSEMAILING_HOSTNAME`
- ✅ Nettoyer les anciens conteneurs et réseaux
- ✅ Construire toutes les images Docker nécessaires
- ✅ Démarrer tous les services

---

### Option 2 : Manuelle (Pas à Pas) 📝

#### Étape 1 : Copier le fichier .env corrigé

```bash
cd ~/BillionMail
cp /app/env_corrected .env
```

**OU** ajouter manuellement cette ligne dans votre `.env` actuel :

```bash
echo "TETRISNEWSEMAILING_HOSTNAME=emailing.tetrisnews.fr" >> .env
```

#### Étape 2 : Nettoyer les anciens conteneurs

```bash
cd ~/BillionMail
docker compose down
docker network prune -f
```

#### Étape 3 : Construire les images Docker

```bash
cd ~/BillionMail
docker compose build
```

⏱️ **Note** : Cette étape peut prendre 5-10 minutes

#### Étape 4 : Démarrer les services

```bash
cd ~/BillionMail
docker compose up -d
```

---

## 📊 Vérification

```bash
# Voir l'état des conteneurs
docker compose ps

# Voir les logs en temps réel
docker compose logs -f

# Vérifier un service spécifique
docker compose logs postfix-tetrisnewsemailing
```

---

## 🌐 Accès

Une fois démarré, vous pouvez accéder à :

- **Interface Web** : http://emailing.tetrisnews.fr
- **WebMail** : http://emailing.tetrisnews.fr/roundcube/
- **Admin** : billion / billion

---

## ❓ En Cas de Problème

### Les services ne démarrent pas

```bash
# Voir les logs d'erreur
docker compose logs

# Redémarrer un service spécifique
docker compose restart postfix-tetrisnewsemailing
```

### Conflit de réseau persistant

```bash
# Lister tous les réseaux
docker network ls

# Supprimer un réseau spécifique
docker network rm tetrisnews-emailing_billionmail-network

# Nettoyer tous les réseaux inutilisés
docker network prune -f
```

### Images pas construites

```bash
# Forcer la reconstruction
docker compose build --no-cache
```

---

## 📋 Comparaison .env

### ❌ Ancien (problématique)
```
BILLIONMAIL_HOSTNAME=emailing.tetrisnews.fr
IPV4_NETWORK=172.66.1
# Manque TETRISNEWSEMAILING_HOSTNAME
```

### ✅ Nouveau (corrigé)
```
BILLIONMAIL_HOSTNAME=emailing.tetrisnews.fr
TETRISNEWSEMAILING_HOSTNAME=emailing.tetrisnews.fr
IPV4_NETWORK=172.67.1
```

---

## 🎯 Commandes Utiles

```bash
# Arrêter tous les services
docker compose down

# Redémarrer tous les services
docker compose restart

# Voir les ressources utilisées
docker stats

# Nettoyer tout (⚠️ supprime les données)
docker compose down -v

# Rebuild et redémarrer
docker compose up -d --build
```

---

## ✅ Succès !

Quand vous verrez tous les services "Up" :

```bash
docker compose ps
```

Résultat attendu :
```
NAME                                          STATUS
tetrisnewsemailing-core-tetrisnewsemailing-1   Up
tetrisnewsemailing-dovecot-tetrisnewsemailing-1 Up
tetrisnewsemailing-postfix-tetrisnewsemailing-1 Up
tetrisnewsemailing-pgsql-tetrisnewsemailing-1   Up
tetrisnewsemailing-redis-tetrisnewsemailing-1   Up
tetrisnewsemailing-rspamd-tetrisnewsemailing-1  Up
tetrisnewsemailing-webmail-tetrisnewsemailing-1 Up
```

Votre serveur mail est prêt ! 🎉
