# 🎯 Solution : Modifications Frontend Non Visibles

## ❌ Le Problème

Vous aviez ajouté la colonne "Info Entreprise" dans le fichier Vue, copié le dist, et reconstruit Docker, mais les changements n'apparaissaient pas.

### Cause Racine

1. Le `Dockerfile` copie le dossier `core/public` **pendant la construction de l'image**
2. Même si vous copiez un nouveau dist sur l'hôte, le conteneur Docker utilise toujours l'**ancienne version** intégrée dans l'image
3. Le volume mount (ligne 193 du docker-compose) était **commenté**, donc le nouveau dist n'était pas utilisé

## ✅ La Solution Appliquée

### Étape 1 : Nettoyage et Rebuild Complet ✅
```bash
# Suppression de l'ancien dist
rm -rf /app/core/public/dist

# Installation des dépendances
cd /app/core/frontend
yarn install

# Build du frontend avec vos modifications
yarn build

# Copie du nouveau dist
cp -r /app/core/frontend/dist /app/core/public/
```

### Étape 2 : Configuration Docker ✅

**Fichier modifié :** `docker-compose.traefik.yml` (ligne 193)

**Avant :**
```yaml
# - ./core/public/dist:/opt/tetrisnewsemailing/core/public/dist
```

**Après :**
```yaml
- ./core/public/dist:/opt/tetrisnewsemailing/core/public/dist
```

Cette ligne monte maintenant le dossier dist de l'hôte dans le conteneur.

## 🚀 Action Requise

**Vous devez maintenant exécuter sur votre serveur :**

```bash
cd ~/BillionMail
./rebuild_and_restart.sh
```

Ce script va :
1. Arrêter les conteneurs
2. Reconstruire l'image core avec le nouveau dist
3. Redémarrer tous les conteneurs
4. Vérifier l'état

## 🔄 Workflow Futur pour les Modifications Frontend

Pour vos prochaines modifications du frontend :

```bash
# 1. Modifier les fichiers Vue dans /app/core/frontend/src/

# 2. Rebuild le frontend
cd /app/core/frontend
yarn build

# 3. Copier le nouveau dist
rm -rf /app/core/public/dist
cp -r /app/core/frontend/dist /app/core/public/

# 4. Redémarrer le conteneur (le volume mount est maintenant actif)
cd ~/BillionMail
docker-compose -f docker-compose.traefik.yml restart core-tetrisnewsemailing

# 5. Vider le cache du navigateur (Ctrl+Shift+R)
```

## 📊 Nouvelle Colonne Ajoutée

**Colonne "Info Entreprise"**
- Position : Entre "Entreprise" et "Email"
- Largeur : 160px
- Affichage :
  - 🏢 Secteur : Tech/IT, Finance, Industrie, Commerce, Santé, etc.
  - 👥 Taille : TPE, PME, ETI, GE
  - Affiche "-" si pas de données

## 🎨 Code Ajouté

**Mappings (lignes 125-144) :**
```javascript
const companySizeLabels: Record<string, string> = {
    tpe: 'TPE',
    pme: 'PME',
    eti: 'ETI',
    ge: 'GE',
}

const industryLabels: Record<string, string> = {
    tech: 'Tech / IT',
    finance: 'Finance',
    industrie: 'Industrie',
    retail: 'Commerce',
    sante: 'Santé',
    services: 'Services',
    immobilier: 'Immobilier',
    education: 'Éducation',
    transport: 'Transport',
    energie: 'Énergie',
    autre: 'Autre',
}
```

**Colonne dans le tableau (lignes 163-174) :**
```javascript
{
    title: 'Info Entreprise',
    key: 'company_info',
    width: 160,
    render: (row: any) => (
        <div class="text-12px">
            {row.industry && <div class="flex items-center gap-4px">
                <i class="i-mdi-domain text-gray-400"></i> 
                {industryLabels[row.industry] || row.industry}
            </div>}
            {row.company_size && <div class="flex items-center gap-4px">
                <i class="i-mdi-account-group text-gray-400"></i> 
                {companySizeLabels[row.company_size] || row.company_size}
            </div>}
            {!row.industry && !row.company_size && <span class="text-gray-400">-</span>}
        </div>
    ),
}
```

## 🔧 Dépannage

### Les modifications ne s'affichent toujours pas ?

**1. Vérifiez que le volume est bien monté :**
```bash
docker exec tetrisnews-emailing-core-tetrisnewsemailing-1 ls -la /opt/tetrisnewsemailing/core/public/dist/
```
Doit montrer des fichiers datés de Dec 2 17:11.

**2. Vérifiez le fichier index.html dans le conteneur :**
```bash
docker exec tetrisnews-emailing-core-tetrisnewsemailing-1 cat /opt/tetrisnewsemailing/core/public/dist/index.html
```

**3. Effacez complètement le cache du navigateur :**
- Chrome : Paramètres → Confidentialité → Effacer les données de navigation → Tout
- Firefox : Ctrl+Shift+Delete → Tout effacer
- Ou utilisez la navigation privée

**4. Vérifiez les logs Traefik :**
```bash
docker logs traefik --tail 50
```

**5. Redémarrez tout le stack :**
```bash
docker-compose -f docker-compose.traefik.yml restart
```

## 📚 Fichiers Importants

| Fichier | Description |
|---------|-------------|
| `/app/core/frontend/src/views/prospects/list/index.vue` | Code source Vue modifié |
| `/app/core/frontend/dist/` | Build frontend généré |
| `/app/core/public/dist/` | Dist copié pour Docker |
| `/app/docker-compose.traefik.yml` | Configuration Docker (ligne 193) |
| `/app/rebuild_and_restart.sh` | Script de rebuild automatique |
| `/app/INSTRUCTIONS_REBUILD.md` | Instructions détaillées |

## ✨ Résumé

- ✅ Code source modifié correctement
- ✅ Frontend rebuild avec succès
- ✅ Nouveau dist copié vers /app/core/public/dist
- ✅ Volume mount décommenté dans docker-compose
- ⏳ **À faire : Exécuter rebuild_and_restart.sh sur le serveur**
- ⏳ **À faire : Vider le cache du navigateur**
