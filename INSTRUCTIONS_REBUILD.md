# Instructions pour appliquer les modifications du frontend

## 📋 Ce qui a été fait

1. ✅ Ancien dossier `/app/core/public/dist` supprimé
2. ✅ Dépendances frontend installées avec `yarn install`
3. ✅ Frontend reconstruit avec `yarn build` (build réussi)
4. ✅ Nouveau dist copié vers `/app/core/public/dist`
5. ✅ Volume mount décommenté dans `docker-compose.traefik.yml` (ligne 193)
6. ✅ Script de rebuild créé

## 🚀 Commandes à exécuter sur votre serveur

Connectez-vous en SSH à votre serveur et exécutez :

```bash
cd ~/BillionMail
./rebuild_and_restart.sh
```

**OU** exécutez les commandes manuellement :

```bash
cd ~/BillionMail

# Arrêter les conteneurs
docker-compose -f docker-compose.traefik.yml down

# Reconstruire l'image core (avec le nouveau dist)
docker-compose -f docker-compose.traefik.yml build --no-cache core-tetrisnewsemailing

# Redémarrer tous les conteneurs
docker-compose -f docker-compose.traefik.yml up -d

# Vérifier l'état
docker-compose -f docker-compose.traefik.yml ps
```

## 🔍 Vérification

Après le redémarrage, vérifiez que les modifications sont visibles :

1. **Effacez le cache du navigateur** : `Ctrl+Shift+R` (Windows/Linux) ou `Cmd+Shift+R` (Mac)
2. **OU** Ouvrez une fenêtre de navigation privée
3. Allez sur votre page des prospects
4. Vous devriez voir la nouvelle colonne "Info Entreprise" entre "Entreprise" et "Email"

## 🐛 En cas de problème

Si les modifications ne sont toujours pas visibles après 1-2 minutes :

### 1. Vérifiez que le nouveau dist est bien monté dans le conteneur :

```bash
docker exec tetrisnews-emailing-core-tetrisnewsemailing-1 ls -la /opt/tetrisnewsemailing/core/public/dist/
```

Le timestamp doit être récent (Dec 2 17:11).

### 2. Vérifiez les logs du conteneur core :

```bash
docker logs tetrisnews-emailing-core-tetrisnewsemailing-1 --tail 50
```

### 3. Redémarrez uniquement le conteneur core :

```bash
docker-compose -f docker-compose.traefik.yml restart core-tetrisnewsemailing
```

### 4. Attendez que Traefik rafraîchisse son cache :

Traefik peut mettre quelques secondes à mettre à jour son cache. Attendez 30-60 secondes puis réessayez.

## 📝 Modifications apportées au fichier

Le fichier modifié : `/app/core/frontend/src/views/prospects/list/index.vue`

**Nouvelle colonne ajoutée :**
- Titre : "Info Entreprise"
- Position : Entre "Entreprise" et "Email"
- Largeur : 160px
- Contenu : 
  - Secteur d'activité (avec icône domain)
  - Taille d'entreprise (avec icône account-group)
  - Affiche "-" si pas d'info disponible

**Mappings ajoutés :**
- `companySizeLabels` : TPE, PME, ETI, GE
- `industryLabels` : Tech/IT, Finance, Industrie, Commerce, Santé, Services, Immobilier, Éducation, Transport, Énergie, Autre
