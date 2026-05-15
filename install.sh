#!/bin/bash

set -e

PTERO_DIR="/var/www/pterodactyl"
REPO_URL="https://github.com/miuujs/miuujs.git"
TEMP_DIR="/tmp/miuujs-installer"
BACKUP_DIR="/root/miuujs-backup-$(date +%Y%m%d-%H%M%S)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════╗"
    echo "║           MiuuJS Installer               ║"
    echo "║     Pterodactyl Theme                    ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}This script must be run as root${NC}"
        exit 1
    fi
}

check_panel() {
    if [[ ! -f "$PTERO_DIR/artisan" ]]; then
        echo -e "${RED}Pterodactyl panel not found at $PTERO_DIR${NC}"
        exit 1
    fi
    echo -e "${GREEN}Pterodactyl panel detected at $PTERO_DIR${NC}"
}

backup_files() {
    echo -e "${YELLOW}Creating backup...${NC}"
    mkdir -p "$BACKUP_DIR"
    
    if [[ -d "$PTERO_DIR/resources/scripts" ]]; then
        cp -r "$PTERO_DIR/resources/scripts" "$BACKUP_DIR/"
    fi
    if [[ -d "$PTERO_DIR/resources/views" ]]; then
        cp -r "$PTERO_DIR/resources/views" "$BACKUP_DIR/"
    fi
    if [[ -f "$PTERO_DIR/config/miuujs.php" ]]; then
        cp "$PTERO_DIR/config/miuujs.php" "$BACKUP_DIR/"
    fi
    if [[ -f "$PTERO_DIR/tailwind.config.js" ]]; then
        cp "$PTERO_DIR/tailwind.config.js" "$BACKUP_DIR/"
    fi
    if [[ -f "$PTERO_DIR/webpack.config.js" ]]; then
        cp "$PTERO_DIR/webpack.config.js" "$BACKUP_DIR/"
    fi
    
    echo -e "${GREEN}Backup saved to $BACKUP_DIR${NC}"
}

install_deps() {
    echo -e "${YELLOW}Installing PHP dependencies...${NC}"
    
    if [[ ! -d "$PTERO_DIR/vendor" ]]; then
        cd "$PTERO_DIR" && composer install --no-dev --optimize-autoloader 2>/dev/null || true
    fi
    
    echo -e "${YELLOW}Installing Node.js dependencies...${NC}"
    cd "$PTERO_DIR"
    
    local packages="react-icons md5 bbcode-to-react path-browserify i18next-browser-languagedetector"
    for pkg in $packages; do
        if [[ ! -d "node_modules/$pkg" ]]; then
            npm install "$pkg" --legacy-peer-deps 2>/dev/null || true
        fi
    done
    
    echo -e "${GREEN}Dependencies installed${NC}"
}

clone_theme() {
    echo -e "${YELLOW}Downloading MiuuJS theme...${NC}"
    
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null
    
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to download theme${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Theme downloaded${NC}"
}

install_theme() {
    echo -e "${YELLOW}Installing theme files...${NC}"
    
    if [[ -d "$TEMP_DIR/scripts" ]]; then
        cp -r "$TEMP_DIR/scripts/"* "$PTERO_DIR/resources/scripts/"
    fi
    
    if [[ -d "$TEMP_DIR/resources" ]]; then
        cp -r "$TEMP_DIR/resources/views/"* "$PTERO_DIR/resources/views/"
    fi
    
    if [[ -d "$TEMP_DIR/config" ]]; then
        cp -r "$TEMP_DIR/config/"* "$PTERO_DIR/config/"
    fi
    
    if [[ -d "$TEMP_DIR/public" ]]; then
        cp -r "$TEMP_DIR/public/"* "$PTERO_DIR/public/"
    fi
    
    if [[ -d "$TEMP_DIR/app" ]]; then
        cp -r "$TEMP_DIR/app/"* "$PTERO_DIR/app/"
    fi
    
    if [[ -d "$TEMP_DIR/routes" ]]; then
        cp -r "$TEMP_DIR/routes/"* "$PTERO_DIR/routes/"
    fi
    
    if [[ -f "$TEMP_DIR/tailwind.config.js" ]]; then
        cp "$TEMP_DIR/tailwind.config.js" "$PTERO_DIR/"
    fi
    
    if [[ -f "$TEMP_DIR/webpack.config.js" ]]; then
        cp "$TEMP_DIR/webpack.config.js" "$PTERO_DIR/"
    fi
    
    chown -R www-data:www-data "$PTERO_DIR/resources" "$PTERO_DIR/public" "$PTERO_DIR/config" "$PTERO_DIR/app" 2>/dev/null || true
    
    echo -e "${GREEN}Theme files installed${NC}"
}

build_assets() {
    echo -e "${YELLOW}Building frontend assets (this may take a while)...${NC}"
    cd "$PTERO_DIR"
    
    npm run build 2>/dev/null
    
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Build failed. Trying full npm install first...${NC}"
        npm install --legacy-peer-deps 2>/dev/null || true
        npm run build 2>/dev/null || {
            echo -e "${RED}Build failed. Check npm/node versions.${NC}"
            exit 1
        }
    fi
    
    echo -e "${GREEN}Frontend built successfully${NC}"
}

clear_cache() {
    echo -e "${YELLOW}Clearing cache...${NC}"
    cd "$PTERO_DIR"
    php artisan view:clear 2>/dev/null || true
    php artisan config:clear 2>/dev/null || true
    php artisan route:clear 2>/dev/null || true
    echo -e "${GREEN}Cache cleared${NC}"
}

uninstall_theme() {
    echo -e "${YELLOW}Uninstalling MiuuJS theme...${NC}"
    
    if [[ ! -f "$PTERO_DIR/artisan" ]]; then
        echo -e "${RED}Pterodactyl panel not found${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}This will restore your panel to default. A backup is recommended.${NC}"
    
    local files_to_remove=(
        "$PTERO_DIR/config/miuujs.php"
        "$PTERO_DIR/tailwind.config.js"
        "$PTERO_DIR/webpack.config.js"
        "$PTERO_DIR/public/miuujs"
        "$PTERO_DIR/public/themes/pterodactyl/css/miuujs.css"
    )
    
    for file in "${files_to_remove[@]}"; do
        if [[ -e "$file" ]]; then
            rm -rf "$file"
            echo -e "${GREEN}Removed: $file${NC}"
        fi
    done
    
    echo -e "${YELLOW}Note: Scripts and views are not removed to avoid breaking the panel.${NC}"
    echo -e "${YELLOW}Restore from backup: cp -r $BACKUP_DIR/* $PTERO_DIR/${NC}"
    
    cd "$PTERO_DIR"
    npm run build 2>/dev/null || true
    php artisan view:clear 2>/dev/null || true
    php artisan config:clear 2>/dev/null || true
    
    echo -e "${GREEN}Uninstall complete${NC}"
}

main() {
    print_banner
    
    if [[ "$1" == "uninstall" ]]; then
        uninstall_theme
        exit 0
    fi
    
    check_root
    check_panel
    backup_files
    install_deps
    clone_theme
    install_theme
    build_assets
    clear_cache
    
    echo ""
    echo -e "${PURPLE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║       Installation Complete!             ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Backup: ${GREEN}$BACKUP_DIR${NC}"
    echo ""
    echo -e "To uninstall: ${YELLOW}bash $0 uninstall${NC}"
}

main "$@"