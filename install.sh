#!/bin/bash

set -e

PTERO_DIR="/var/www/pterodactyl"
REPO_URL="https://github.com/miuujs/miuujs.git"
TEMP_DIR="/tmp/miuujs-installer"
BACKUP_DIR="/root/miuujs-backup-$(date +%Y%m%d-%H%M%S)"

COLOR_RESET="\033[0m"
COLOR_BLACK="\033[0;30m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_BLUE="\033[0;34m"
COLOR_PURPLE="\033[0;35m"
COLOR_CYAN="\033[0;36m"
COLOR_WHITE="\033[1;37m"
COLOR_BOLD="\033[1m"

print_banner() {
    echo ""
    echo -e "${COLOR_PURPLE}${COLOR_BOLD}  _      _                   ${COLOR_WHITE}  _  __     __ ${COLOR_RESET}"
    echo -e "${COLOR_PURPLE}${COLOR_BOLD} | |    (_)                  ${COLOR_WHITE} | | \ \   / /${COLOR_RESET}"  
    echo -e "${COLOR_PURPLE}${COLOR_BOLD} | |     _ _ __ ___   ___   ${COLOR_WHITE} | |  \ \_/ / ${COLOR_RESET}"
    echo -e "${COLOR_PURPLE}${COLOR_BOLD} | |    | | '_ \` _ \ / _ \ ${COLOR_WHITE} | |   \   /  ${COLOR_RESET}"
    echo -e "${COLOR_PURPLE}${COLOR_BOLD} | |____| | | | | | | (_) |${COLOR_WHITE} | |____| |   ${COLOR_RESET}"
    echo -e "${COLOR_PURPLE}${COLOR_BOLD} |______|_|_| |_| |_|\___/ ${COLOR_WHITE} |______|_|   ${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_GREEN}  MiuuJS Theme Installer v1.0.0${COLOR_RESET}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${COLOR_RED}* This script must be run as root.${COLOR_RESET}"
        exit 1
    fi
}

check_panel() {
    echo -n "* Checking Pterodactyl installation..."
    if [[ ! -f "$PTERO_DIR/artisan" ]]; then
        echo -e " ${COLOR_RED}not found at $PTERO_DIR${COLOR_RESET}"
        exit 1
    fi
    echo -e " ${COLOR_GREEN}found${COLOR_RESET}"
}

backup_files() {
    echo -n "* Creating backup..."
    mkdir -p "$BACKUP_DIR"
    [[ -d "$PTERO_DIR/resources/scripts" ]] && cp -r "$PTERO_DIR/resources/scripts" "$BACKUP_DIR/" 2>/dev/null
    [[ -d "$PTERO_DIR/resources/views" ]] && cp -r "$PTERO_DIR/resources/views" "$BACKUP_DIR/" 2>/dev/null
    [[ -f "$PTERO_DIR/config/miuujs.php" ]] && cp "$PTERO_DIR/config/miuujs.php" "$BACKUP_DIR/" 2>/dev/null
    [[ -f "$PTERO_DIR/tailwind.config.js" ]] && cp "$PTERO_DIR/tailwind.config.js" "$BACKUP_DIR/" 2>/dev/null
    [[ -f "$PTERO_DIR/webpack.config.js" ]] && cp "$PTERO_DIR/webpack.config.js" "$BACKUP_DIR/" 2>/dev/null
    echo -e " ${COLOR_GREEN}done${COLOR_RESET}"
}

install_deps() {
    echo -n "* Installing PHP dependencies..."
    if [[ ! -d "$PTERO_DIR/vendor" ]]; then
        cd "$PTERO_DIR" && composer install --no-dev --optimize-autoloader &>/dev/null || true
    fi
    echo -e " ${COLOR_GREEN}done${COLOR_RESET}"

    echo -n "* Installing Node.js dependencies..."
    cd "$PTERO_DIR"
    for pkg in react-icons md5 bbcode-to-react path-browserify i18next-browser-languagedetector; do
        [[ ! -d "node_modules/$pkg" ]] && npm install "$pkg" --legacy-peer-deps &>/dev/null || true
    done
    echo -e " ${COLOR_GREEN}done${COLOR_RESET}"
}

clone_theme() {
    echo -n "* Downloading MiuuJS theme..."
    [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR" &>/dev/null || {
        echo -e " ${COLOR_RED}failed${COLOR_RESET}"
        exit 1
    }
    echo -e " ${COLOR_GREEN}done${COLOR_RESET}"
}

install_theme() {
    echo -n "* Installing theme files..."
    [[ -d "$TEMP_DIR/scripts" ]] && cp -r "$TEMP_DIR/scripts/"* "$PTERO_DIR/resources/scripts/"
    [[ -d "$TEMP_DIR/resources" ]] && cp -r "$TEMP_DIR/resources/views/"* "$PTERO_DIR/resources/views/"
    [[ -d "$TEMP_DIR/config" ]] && cp -r "$TEMP_DIR/config/"* "$PTERO_DIR/config/"
    [[ -d "$TEMP_DIR/public" ]] && cp -r "$TEMP_DIR/public/"* "$PTERO_DIR/public/"
    [[ -d "$TEMP_DIR/app" ]] && cp -r "$TEMP_DIR/app/"* "$PTERO_DIR/app/"
    [[ -d "$TEMP_DIR/routes" ]] && cp -r "$TEMP_DIR/routes/"* "$PTERO_DIR/routes/"
    [[ -f "$TEMP_DIR/tailwind.config.js" ]] && cp "$TEMP_DIR/tailwind.config.js" "$PTERO_DIR/"
    [[ -f "$TEMP_DIR/webpack.config.js" ]] && cp "$TEMP_DIR/webpack.config.js" "$PTERO_DIR/"
    chown -R www-data:www-data "$PTERO_DIR/resources" "$PTERO_DIR/public" "$PTERO_DIR/config" "$PTERO_DIR/app" 2>/dev/null || true
    echo -e " ${COLOR_GREEN}done${COLOR_RESET}"
}

build_assets() {
    echo -e "* Building frontend assets..."
    cd "$PTERO_DIR"
    npm run build &>/dev/null || {
        npm install --legacy-peer-deps &>/dev/null || true
        npm run build &>/dev/null || {
            echo -e " ${COLOR_RED}Build failed. Check npm/node versions.${COLOR_RESET}"
            exit 1
        }
    }
    echo -e " ${COLOR_GREEN}  done${COLOR_RESET}"
}

clear_cache() {
    echo -n "* Clearing cache..."
    cd "$PTERO_DIR"
    php artisan view:clear &>/dev/null || true
    php artisan config:clear &>/dev/null || true
    php artisan route:clear &>/dev/null || true
    echo -e " ${COLOR_GREEN}done${COLOR_RESET}"
}

uninstall_theme() {
    echo -n "* Removing theme files..."
    for file in "$PTERO_DIR/config/miuujs.php" "$PTERO_DIR/tailwind.config.js" "$PTERO_DIR/webpack.config.js"; do
        [[ -e "$file" ]] && rm -rf "$file"
    done
    [[ -d "$PTERO_DIR/public/miuujs" ]] && rm -rf "$PTERO_DIR/public/miuujs"
    [[ -f "$PTERO_DIR/public/themes/pterodactyl/css/miuujs.css" ]] && rm -f "$PTERO_DIR/public/themes/pterodactyl/css/miuujs.css"
    echo -e " ${COLOR_GREEN}done${COLOR_RESET}"

    echo -n "* Rebuilding panel..."
    cd "$PTERO_DIR"
    npm run build &>/dev/null || true
    php artisan view:clear &>/dev/null || true
    php artisan config:clear &>/dev/null || true
    echo -e " ${COLOR_GREEN}done${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_GREEN}  MiuuJS theme has been uninstalled.${COLOR_RESET}"
}

main() {
    clear 2>/dev/null || true
    print_banner
    check_root
    check_panel

    if [[ -f "$PTERO_DIR/config/miuujs.php" ]]; then
        echo -e "${COLOR_YELLOW}  MiuuJS theme is already installed.${COLOR_RESET}"
        echo ""
        echo -e "  ${COLOR_GREEN}[1]${COLOR_RESET} Reinstall (update to latest version)"
        echo -e "  ${COLOR_RED}[2]${COLOR_RESET} Uninstall"
        echo -e "  ${COLOR_WHITE}[3]${COLOR_RESET} Cancel"
        echo ""
        read -p "$(echo -e ${COLOR_CYAN}"  Select option [1-3]: "${COLOR_RESET})" choice
        case "$choice" in
            1) echo "" ;;
            2) echo ""; uninstall_theme; exit 0 ;;
            *) echo ""; exit 0 ;;
        esac
    fi

    backup_files
    install_deps
    clone_theme
    install_theme
    build_assets
    clear_cache

    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_GREEN}  Installation complete!${COLOR_RESET}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    echo -e "  Backup: ${COLOR_YELLOW}$BACKUP_DIR${COLOR_RESET}"
    echo ""
}

main