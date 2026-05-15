#!/bin/bash

set -e

PTERO_DIR="/var/www/pterodactyl"
REPO_URL="https://github.com/miuujs/miuujs.git"
TEMP_DIR="/tmp/miuujs-installer"
BACKUP_DIR="/root/miuujs-backup-$(date +%Y%m%d-%H%M%S)"

print_banner() {
    echo ""
    echo "  MiuuJS Theme Installer"
    echo ""
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root."
        exit 1
    fi
}

check_panel() {
    if [[ ! -f "$PTERO_DIR/artisan" ]]; then
        echo "Pterodactyl panel not found at $PTERO_DIR"
        exit 1
    fi
    echo "Pterodactyl panel detected at $PTERO_DIR"
}

backup_files() {
    echo "Creating backup..."
    mkdir -p "$BACKUP_DIR"
    [[ -d "$PTERO_DIR/resources/scripts" ]] && cp -r "$PTERO_DIR/resources/scripts" "$BACKUP_DIR/"
    [[ -d "$PTERO_DIR/resources/views" ]] && cp -r "$PTERO_DIR/resources/views" "$BACKUP_DIR/"
    [[ -f "$PTERO_DIR/config/miuujs.php" ]] && cp "$PTERO_DIR/config/miuujs.php" "$BACKUP_DIR/"
    [[ -f "$PTERO_DIR/tailwind.config.js" ]] && cp "$PTERO_DIR/tailwind.config.js" "$BACKUP_DIR/"
    [[ -f "$PTERO_DIR/webpack.config.js" ]] && cp "$PTERO_DIR/webpack.config.js" "$BACKUP_DIR/"
    echo "Backup saved to $BACKUP_DIR"
}

install_deps() {
    if [[ ! -d "$PTERO_DIR/vendor" ]]; then
        echo "Installing PHP dependencies..."
        cd "$PTERO_DIR" && composer install --no-dev --optimize-autoloader &>/dev/null || true
    fi

    echo "Installing Node.js dependencies..."
    cd "$PTERO_DIR"
    for pkg in react-icons md5 bbcode-to-react path-browserify i18next-browser-languagedetector; do
        [[ ! -d "node_modules/$pkg" ]] && npm install "$pkg" --legacy-peer-deps &>/dev/null || true
    done
}

clone_theme() {
    echo "Downloading MiuuJS theme..."
    [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR" &>/dev/null || {
        echo "Failed to download theme"
        exit 1
    }
}

install_theme() {
    echo "Installing theme files..."
    [[ -d "$TEMP_DIR/scripts" ]] && cp -r "$TEMP_DIR/scripts/"* "$PTERO_DIR/resources/scripts/"
    [[ -d "$TEMP_DIR/resources" ]] && cp -r "$TEMP_DIR/resources/views/"* "$PTERO_DIR/resources/views/"
    [[ -d "$TEMP_DIR/config" ]] && cp -r "$TEMP_DIR/config/"* "$PTERO_DIR/config/"
    [[ -d "$TEMP_DIR/public" ]] && cp -r "$TEMP_DIR/public/"* "$PTERO_DIR/public/"
    [[ -d "$TEMP_DIR/app" ]] && cp -r "$TEMP_DIR/app/"* "$PTERO_DIR/app/"
    [[ -d "$TEMP_DIR/routes" ]] && cp -r "$TEMP_DIR/routes/"* "$PTERO_DIR/routes/"
    [[ -f "$TEMP_DIR/tailwind.config.js" ]] && cp "$TEMP_DIR/tailwind.config.js" "$PTERO_DIR/"
    [[ -f "$TEMP_DIR/webpack.config.js" ]] && cp "$TEMP_DIR/webpack.config.js" "$PTERO_DIR/"
    chown -R www-data:www-data "$PTERO_DIR/resources" "$PTERO_DIR/public" "$PTERO_DIR/config" "$PTERO_DIR/app" &>/dev/null || true
}

build_assets() {
    echo "Building frontend assets (this may take a while)..."
    cd "$PTERO_DIR"
    npm run build &>/dev/null || {
        npm install --legacy-peer-deps &>/dev/null || true
        npm run build &>/dev/null || {
            echo "Build failed. Check npm/node versions."
            exit 1
        }
    }
}

clear_cache() {
    cd "$PTERO_DIR"
    php artisan view:clear &>/dev/null || true
    php artisan config:clear &>/dev/null || true
    php artisan route:clear &>/dev/null || true
}

uninstall_theme() {
    echo "Removing theme files..."
    for file in "$PTERO_DIR/config/miuujs.php" "$PTERO_DIR/tailwind.config.js" "$PTERO_DIR/webpack.config.js"; do
        [[ -e "$file" ]] && rm -rf "$file"
    done
    [[ -d "$PTERO_DIR/public/miuujs" ]] && rm -rf "$PTERO_DIR/public/miuujs"
    [[ -f "$PTERO_DIR/public/themes/pterodactyl/css/miuujs.css" ]] && rm -f "$PTERO_DIR/public/themes/pterodactyl/css/miuujs.css"

    echo "Rebuilding panel..."
    cd "$PTERO_DIR"
    npm run build &>/dev/null || true
    php artisan view:clear &>/dev/null || true
    php artisan config:clear &>/dev/null || true
    echo "MiuuJS theme has been uninstalled."
}

main() {
    print_banner
    check_root
    check_panel

    if [[ -f "$PTERO_DIR/config/miuujs.php" ]]; then
        echo ""
        echo "MiuuJS theme is already installed."
        echo ""
        echo "[1] Reinstall (update to latest version)"
        echo "[2] Uninstall"
        echo "[3] Cancel"
        echo ""
        read -p "Select option [1-3]: " choice
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
    echo "================================"
    echo "  Installation complete!"
    echo "================================"
    echo ""
    echo "Backup: $BACKUP_DIR"
    echo ""
}

main