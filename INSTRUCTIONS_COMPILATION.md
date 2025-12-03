# Instructions de compilation et déploiement du correctif

## Problème
L'erreur SQL persiste car le conteneur Docker utilise un ancien binaire compilé qui ne contient pas le correctif.

## Solution

### Étape 1 : Sur votre serveur, compilez le nouveau binaire

```bash
# Se connecter à votre serveur
ssh contact_tetrisnews@n8nv2

# Aller dans le répertoire du projet
cd ~/BillionMail/core

# Compiler le binaire avec le nouveau code
# Pour ARM64 (si architecture aarch64/arm64)
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o tetrisnewsemailing-arm64 main.go

# OU pour AMD64 (si architecture x86_64)
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o tetrisnewsemailing-amd64 main.go

# Vérifier que le binaire a été créé
ls -lh tetrisnewsemailing-*
```

### Étape 2 : Rebuild du frontend

```bash
cd ~/BillionMail/core/frontend
yarn build

# Copier le dist
rm -rf ~/BillionMail/core/public/dist
cp -r ~/BillionMail/core/frontend/dist ~/BillionMail/core/public/
```

### Étape 3 : Rebuild et restart du conteneur Docker

```bash
cd ~/BillionMail

# Rebuild avec le nouveau binaire (sans cache)
docker-compose -f docker-compose.traefik.yml build --no-cache core-tetrisnewsemailing

# Redémarrer le conteneur
docker-compose -f docker-compose.traefik.yml up -d core-tetrisnewsemailing

# Vérifier les logs
docker-compose -f docker-compose.traefik.yml logs -f core-tetrisnewsemailing
```

### Étape 4 : Vérification

Ouvrez votre navigateur et testez la page Prospects. L'erreur SQL devrait être résolue.

## Alternative : Si Go n'est pas installé sur votre serveur

### Installer Go sur votre serveur :

```bash
# Pour ARM64
wget https://go.dev/dl/go1.21.5.linux-arm64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.5.linux-arm64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# Vérifier l'installation
go version
```

Puis recommencez l'Étape 1.

## Vérification du correctif dans le code

Le correctif se trouve dans `/app/core/internal/service/prospect/prospect.go` lignes 132-158 :

- Séparation de la requête COUNT (sans Fields) de la requête de données (avec Fields)
- Cela évite l'erreur : `COUNT(p.*, s.name as source_name)`

## En cas de problème persistant

Si l'erreur persiste après ces étapes, vérifiez que :
1. Le nouveau binaire a bien été compilé (taille ~70MB)
2. Le conteneur Docker a bien été reconstruit avec `--no-cache`
3. Le conteneur utilise bien le nouveau binaire (vérifier les logs au démarrage)
