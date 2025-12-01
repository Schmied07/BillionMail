# Guide de Résolution - TetrisNews Emailing
## Solution aux erreurs Docker Compose

### Problèmes Identifiés ❌

1. **Variable d'environnement manquante** : `TETRISNEWSEMAILING_HOSTNAME` n'était pas définie
2. **Fichier .env manquant** : Le fichier de configuration principal était absent
3. **Conflit de réseau Docker** : Le réseau `172.66.1.0/24` était en conflit avec un réseau existant

---

## ✅ Corrections Appliquées

### 1. Création du fichier `.env`
- Fichier créé à partir du template `env_init`
- Toutes les variables nécessaires sont maintenant définies

### 2. Variables corrigées
- ✅ `BILLIONMAIL_HOSTNAME` → `TETRISNEWSEMAILING_HOSTNAME`
- ✅ `DBNAME=tetrisnewsemailing`
- ✅ `DBUSER=tetrisnewsemailing`
- ✅ Identifiants admin mis à jour

### 3. Réseau Docker modifié
- **Ancien** : `IPV4_NETWORK=172.66.1`
- **Nouveau** : `IPV4_NETWORK=172.67.1`
- Cela évite le conflit avec les réseaux Docker existants

---

## 🚀 Prochaines Étapes

### Option 1 : Nettoyer les anciens réseaux Docker (Recommandé)

Si vous avez des réseaux Docker en conflit, supprimez-les :

```bash
# Lister tous les réseaux Docker
docker network ls

# Supprimer le réseau en conflit (si présent)
docker network rm tetrisnews-emailing_tetrisnews-network

# Ou nettoyer tous les réseaux inutilisés
docker network prune -f
```

### Option 2 : Démarrer les services

Maintenant que le fichier `.env` est configuré correctement :

```bash
cd /app

# Arrêter les conteneurs existants (si présents)
docker compose down

# Démarrer les services
docker compose up -d
```

### Option 3 : Utiliser le script d'installation

Si vous préférez utiliser le script d'installation complet :

```bash
cd /app
bash install.sh
```

---

## 📋 Vérification

Après le démarrage, vérifiez que tous les services fonctionnent :

```bash
# Voir l'état des conteneurs
docker compose ps

# Voir les logs
docker compose logs -f

# Utiliser le script de gestion
./bm.sh default    # Voir les informations de connexion par défaut
./bm.sh help       # Voir l'aide
```

---

## 🔧 Configuration Personnalisée

Vous pouvez modifier le fichier `/app/.env` selon vos besoins :

- **TETRISNEWSEMAILING_HOSTNAME** : Votre nom de domaine mail (ex: mail.votredomaine.com)
- **ADMIN_USERNAME** / **ADMIN_PASSWORD** : Identifiants administrateur
- **Ports** : Modifier les ports si nécessaire (HTTP, HTTPS, SMTP, etc.)

---

## ✅ Récapitulatif des Changements

| Fichier | Changement | Raison |
|---------|-----------|--------|
| `/app/.env` | Créé avec les bonnes variables | Fichier manquant |
| `.env` → `TETRISNEWSEMAILING_HOSTNAME` | Variable renommée | Correspondance avec docker-compose.yml |
| `.env` → `IPV4_NETWORK` | `172.66.1` → `172.67.1` | Éviter conflit réseau Docker |
| `.env` → `DBNAME/DBUSER` | Mis à jour pour tetrisnewsemailing | Cohérence du projet |

---

## 📞 Support

Si vous rencontrez des problèmes :
- Vérifiez les logs : `docker compose logs`
- Consultez le README : `/app/README.md`
- Ouvrez une issue : https://github.com/aaPanel/TetrisNewsEmailing/issues

---

**Statut : ✅ Prêt à démarrer !**
