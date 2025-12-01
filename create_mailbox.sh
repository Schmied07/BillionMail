#!/bin/bash

# Configuration
DOMAIN="tetrisnews.fr"
EMAIL="contact@tetrisnews.fr"
PASSWORD="@Schmied0629"
CONTAINER_NAME="tetrisnews-emailing-pgsql-tetrisnewsemailing-1"
DOVECOT_CONTAINER="tetrisnews-emailing-dovecot-tetrisnewsemailing-1"

echo "================================"
echo "Création de la mailbox BillionMail"
echo "================================"
echo ""
echo "Domaine: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# Generate password hash using doveadm (MD5-CRYPT format for Dovecot)
echo "1. Génération du hash du mot de passe..."
PASSWORD_HASH=$(docker exec -i $DOVECOT_CONTAINER doveadm pw -s MD5-CRYPT -p "$PASSWORD" 2>/dev/null | tr -d '\r')

if [ -z "$PASSWORD_HASH" ]; then
    echo "❌ Erreur: Impossible de générer le hash du mot de passe"
    exit 1
fi

echo "✅ Hash généré: $PASSWORD_HASH"
echo ""

# Create domain
echo "2. Création du domaine '$DOMAIN'..."
docker exec -i $CONTAINER_NAME psql -U tetrisnewsemailing -d tetrisnewsemailing << EOF
INSERT INTO domain (domain, a_record, mailboxes, mailbox_quota, quota, rate_limit, create_time, active)
VALUES ('$DOMAIN', '', 50, 5368709120, 10737418240, 12, EXTRACT(EPOCH FROM NOW())::INT, 1)
ON CONFLICT (domain) DO NOTHING;
EOF

if [ $? -eq 0 ]; then
    echo "✅ Domaine créé ou existe déjà"
else
    echo "❌ Erreur lors de la création du domaine"
    exit 1
fi
echo ""

# Create mailbox
echo "3. Création de la mailbox '$EMAIL'..."
MAILDIR="$DOMAIN/contact/"

docker exec -i $CONTAINER_NAME psql -U tetrisnewsemailing -d tetrisnewsemailing << EOF
INSERT INTO mailbox (username, password, password_encode, full_name, is_admin, maildir, quota, local_part, domain, create_time, update_time, active)
VALUES ('$EMAIL', '$PASSWORD_HASH', 'md5-crypt', 'Contact', 0, '$MAILDIR', 5368709120, 'contact', '$DOMAIN', EXTRACT(EPOCH FROM NOW())::INT, EXTRACT(EPOCH FROM NOW())::INT, 1)
ON CONFLICT (username) DO UPDATE SET password = EXCLUDED.password;
EOF

if [ $? -eq 0 ]; then
    echo "✅ Mailbox créée avec succès!"
else
    echo "❌ Erreur lors de la création de la mailbox"
    exit 1
fi
echo ""

# Verify creation
echo "4. Vérification de la création..."
docker exec -i $CONTAINER_NAME psql -U tetrisnewsemailing -d tetrisnewsemailing -c "SELECT username, domain, active FROM mailbox WHERE username = '$EMAIL';"
echo ""

echo "================================"
echo "✅ SUCCÈS!"
echo "================================"
echo ""
echo "📧 Vous pouvez maintenant vous connecter à RoundCube:"
echo "   URL: https://emailing.tetrisnews.fr/roundcube/"
echo "   Username: $EMAIL"
echo "   Password: $PASSWORD"
echo ""
echo "================================"
