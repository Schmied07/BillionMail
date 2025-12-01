#!/bin/bash
# Menu interactif pour la correction de l'erreur réseau TetrisNews Emailing

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
CYAN='\033[0;96m'
MAGENTA='\033[0;35m'
NC='\033[0m'

clear

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                                       ║${NC}"
echo -e "${CYAN}║        🚀 TetrisNews Emailing - Menu de Correction Réseau 🚀         ║${NC}"
echo -e "${CYAN}║                                                                       ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Problème détecté:${NC}"
echo "  \"numerical result out of range\" lors de la création du réseau Docker"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Fonction pour afficher le menu
show_menu() {
    echo -e "${BLUE}Que souhaitez-vous faire ?${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) ${MAGENTA}🚀 Correction automatique${NC} (Recommandé - 2 minutes)"
    echo -e "     └─ Diagnostic + Nettoyage + Correction + Démarrage"
    echo ""
    echo -e "  ${GREEN}2${NC}) ${MAGENTA}🔍 Diagnostic uniquement${NC} (Sans modification)"
    echo -e "     └─ Voir l'état actuel et les problèmes détectés"
    echo ""
    echo -e "  ${GREEN}3${NC}) ${MAGENTA}📖 Afficher la documentation${NC}"
    echo -e "     └─ Voir les guides et explications"
    echo ""
    echo -e "  ${GREEN}4${NC}) ${MAGENTA}📋 Vérifier l'état des services${NC}"
    echo -e "     └─ Voir si les services sont démarrés"
    echo ""
    echo -e "  ${GREEN}5${NC}) ${MAGENTA}🔧 Commandes utiles${NC}"
    echo -e "     └─ Afficher les commandes de gestion"
    echo ""
    echo -e "  ${GREEN}6${NC}) ${MAGENTA}❌ Quitter${NC}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -n -e "${YELLOW}Votre choix [1-6]:${NC} "
}

# Fonction pour pause
pause() {
    echo ""
    echo -n -e "${YELLOW}Appuyez sur Entrée pour continuer...${NC}"
    read
    clear
    show_menu
}

# Fonction pour exécuter la correction automatique
run_auto_fix() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              🚀 Correction Automatique en cours...                   ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ -f "fix_traefik_network.sh" ]; then
        chmod +x fix_traefik_network.sh
        sudo bash fix_traefik_network.sh
    else
        echo -e "${YELLOW}Script non trouvé dans le dossier actuel.${NC}"
        echo ""
        echo "Copie du script depuis /app..."
        cp /app/fix_traefik_network.sh . 2>/dev/null
        
        if [ -f "fix_traefik_network.sh" ]; then
            chmod +x fix_traefik_network.sh
            sudo bash fix_traefik_network.sh
        else
            echo -e "${RED}Erreur: Impossible de trouver le script de correction.${NC}"
            echo "Assurez-vous d'être dans le bon dossier (~/BillionMail)"
        fi
    fi
    
    pause
}

# Fonction pour exécuter le diagnostic
run_diagnostic() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                  🔍 Diagnostic en cours...                           ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ -f "diagnostic_rapide.sh" ]; then
        bash diagnostic_rapide.sh
    else
        echo -e "${YELLOW}Script de diagnostic non trouvé.${NC}"
        echo ""
        echo "Copie du script depuis /app..."
        cp /app/diagnostic_rapide.sh . 2>/dev/null
        
        if [ -f "diagnostic_rapide.sh" ]; then
            chmod +x diagnostic_rapide.sh
            bash diagnostic_rapide.sh
        else
            echo -e "${RED}Erreur: Impossible de trouver le script de diagnostic.${NC}"
        fi
    fi
    
    pause
}

# Fonction pour afficher la documentation
show_documentation() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                     📖 Documentation Disponible                      ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Documentation disponible dans /app:${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) ${MAGENTA}QUICK_START.txt${NC}"
    echo -e "     └─ Vue d'ensemble rapide"
    echo ""
    echo -e "  ${GREEN}2${NC}) ${MAGENTA}README_CORRECTION_RESEAU.md${NC}"
    echo -e "     └─ README complet de la correction"
    echo ""
    echo -e "  ${GREEN}3${NC}) ${MAGENTA}INSTRUCTIONS_CORRECTION_RESEAU.md${NC}"
    echo -e "     └─ Instructions simples étape par étape"
    echo ""
    echo -e "  ${GREEN}4${NC}) ${MAGENTA}SOLUTION_RESEAU_TRAEFIK.md${NC}"
    echo -e "     └─ Guide complet avec solutions automatique et manuelle"
    echo ""
    echo -e "  ${GREEN}5${NC}) ${MAGENTA}EXPLICATION_TECHNIQUE.md${NC}"
    echo -e "     └─ Explications techniques détaillées"
    echo ""
    echo -e "  ${GREEN}6${NC}) ${MAGENTA}INDEX_SOLUTIONS.md${NC}"
    echo -e "     └─ Index complet de toutes les ressources"
    echo ""
    echo -e "  ${GREEN}0${NC}) Retour au menu principal"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -n -e "${YELLOW}Quel document voulez-vous lire ? [0-6]:${NC} "
    read doc_choice
    
    case $doc_choice in
        1)
            clear
            cat /app/QUICK_START.txt
            ;;
        2)
            clear
            cat /app/README_CORRECTION_RESEAU.md | less
            ;;
        3)
            clear
            cat /app/INSTRUCTIONS_CORRECTION_RESEAU.md | less
            ;;
        4)
            clear
            cat /app/SOLUTION_RESEAU_TRAEFIK.md | less
            ;;
        5)
            clear
            cat /app/EXPLICATION_TECHNIQUE.md | less
            ;;
        6)
            clear
            cat /app/INDEX_SOLUTIONS.md | less
            ;;
        0)
            clear
            show_menu
            return
            ;;
        *)
            echo -e "${RED}Choix invalide${NC}"
            ;;
    esac
    
    pause
}

# Fonction pour vérifier l'état des services
check_services() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                  📋 État des Services Docker                         ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ -f "docker-compose.traefik.yml" ]; then
        echo -e "${BLUE}Services TetrisNews Emailing:${NC}"
        echo ""
        docker compose -f docker-compose.traefik.yml ps
        
        echo ""
        echo -e "${BLUE}Réseaux Docker:${NC}"
        echo ""
        docker network ls | grep -E "NETWORK ID|web|tetrisnews"
        
    else
        echo -e "${RED}Erreur: docker-compose.traefik.yml non trouvé!${NC}"
        echo ""
        echo "Assurez-vous d'être dans le dossier ~/BillionMail"
    fi
    
    pause
}

# Fonction pour afficher les commandes utiles
show_useful_commands() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                      🔧 Commandes Utiles                             ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Gestion des services:${NC}"
    echo ""
    echo -e "  ${GREEN}# Démarrer les services${NC}"
    echo "  docker compose -f docker-compose.traefik.yml up -d"
    echo ""
    echo -e "  ${GREEN}# Arrêter les services${NC}"
    echo "  docker compose -f docker-compose.traefik.yml down"
    echo ""
    echo -e "  ${GREEN}# Redémarrer les services${NC}"
    echo "  docker compose -f docker-compose.traefik.yml restart"
    echo ""
    echo -e "  ${GREEN}# Voir les logs${NC}"
    echo "  docker compose -f docker-compose.traefik.yml logs -f"
    echo ""
    echo -e "  ${GREEN}# Voir l'état${NC}"
    echo "  docker compose -f docker-compose.traefik.yml ps"
    echo ""
    echo -e "${BLUE}Diagnostic:${NC}"
    echo ""
    echo -e "  ${GREEN}# Lister les réseaux Docker${NC}"
    echo "  docker network ls"
    echo ""
    echo -e "  ${GREEN}# Inspecter un réseau${NC}"
    echo "  docker network inspect <nom-reseau>"
    echo ""
    echo -e "  ${GREEN}# Vérifier les variables .env${NC}"
    echo "  cat .env | grep -E 'IPV4_NETWORK|DOMAIN|TETRISNEWSEMAILING_HOSTNAME'"
    echo ""
    echo -e "${BLUE}Accès à l'application:${NC}"
    echo ""
    echo -e "  ${GREEN}Interface Admin:${NC} https://emailing.tetrisnews.fr"
    echo -e "  ${GREEN}WebMail:${NC}         https://emailing.tetrisnews.fr/roundcube/"
    echo -e "  ${GREEN}Login:${NC}           billion / billion"
    echo ""
    
    pause
}

# Boucle principale du menu
while true; do
    show_menu
    read choice
    
    case $choice in
        1)
            run_auto_fix
            ;;
        2)
            run_diagnostic
            ;;
        3)
            show_documentation
            ;;
        4)
            check_services
            ;;
        5)
            show_useful_commands
            ;;
        6)
            clear
            echo -e "${GREEN}Au revoir! 👋${NC}"
            echo ""
            exit 0
            ;;
        *)
            clear
            echo -e "${RED}Choix invalide. Veuillez choisir entre 1 et 6.${NC}"
            echo ""
            show_menu
            ;;
    esac
done
