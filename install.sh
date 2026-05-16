#!/bin/bash
set -e

######################################################################################
#                                                                                    #
#  MiuuJS Theme Installer                                                            #
#                                                                                    #
#  Modern dark theme for Pterodactyl panel                                           #
#                                                                                    #
#  Copyright (C) 2026 MiuuJS                                                         #
#  https://github.com/miuujs/miuujs                                                  #
#                                                                                    #
#  This program is free software: you can redistribute it and/or modify              #
#  it under the terms of the GNU General Public License as published by              #
#  the Free Software Foundation, either version 3 of the License, or                 #
#  (at your option) any later version.                                               #
#                                                                                    #
######################################################################################

export MIUUJS_VERSION="1.0.0"
export MIUUJS_SOURCE="https://raw.githubusercontent.com/miuujs/miuujs/main"
LOG_PATH="/var/log/miuujs-installer.log"

# Colors
RESET="\e[0m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
BOLD="\e[1m"
DIM="\e[2m"

# --- Helper Functions ---
error() { echo -e "* ${RED}ERROR${RESET}: $*" 1>&2; }
warning() { echo -e "* ${YELLOW}WARNING${RESET}: $*"; }
success() { echo -e "* ${GREEN}SUCCESS${RESET}: $*"; }
info() { echo -e "* ${CYAN}INFO${RESET}: $*"; }
input() { echo -ne "* ${MAGENTA}$*${RESET}"; }

print_banner() {
    clear
    echo -e ""
    echo -e "  ${MAGENTA}███╗   ███╗██╗██╗   ██╗██╗   ██╗${BOLD}${CYAN}███████╗${RESET}"
    echo -e "  ${MAGENTA}████╗ ████║██║██║   ██║██║   ██║${BOLD}${CYAN}██╔════╝${RESET}"
    echo -e "  ${MAGENTA}██╔████╔██║██║██║   ██║██║   ██║${BOLD}${CYAN}███████╗${RESET}"
    echo -e "  ${MAGENTA}██║╚██╔╝██║██║██║   ██║██║   ██║${BOLD}${CYAN}╚════██║${RESET}"
    echo -e "  ${MAGENTA}██║ ╚═╝ ██║██║╚██████╔╝╚██████╔╝${BOLD}${CYAN}███████║${RESET}"
    echo -e "  ${MAGENTA}╚═╝     ╚═╝╚═╝ ╚═════╝  ╚═════╝ ${BOLD}${CYAN}╚══════╝${RESET}"
    echo -e ""
    echo -e "  ${BOLD}Pterodactyl Theme Installer v${MIUUJS_VERSION}${RESET}"
    echo -e "  ${DIM}Modern dark theme for Pterodactyl panel${RESET}"
    echo ""
}

# --- Pre-flight Checks ---
preflight() {
    print_banner

    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (sudo)."
        exit 1
    fi

    if ! [ -x "$(command -v curl)" ]; then
        error "curl is required. Install it with: apt install curl -y"
        exit 1
    fi

    if ! [ -x "$(command -v tar)" ]; then
        error "tar is required. Install it with: apt install tar -y"
        exit 1
    fi

    # Detect panel
    PANEL_DIR=""
    if [ -d "/var/www/pterodactyl" ] && [ -f "/var/www/pterodactyl/artisan" ]; then
        PANEL_DIR="/var/www/pterodactyl"
    elif [ -d "/srv/panel" ] && [ -f "/srv/panel/artisan" ]; then
        PANEL_DIR="/srv/panel"
    else
        error "Pterodactyl panel not found at /var/www/pterodactyl or /srv/panel"
        input "Enter panel directory manually: "
        read -r PANEL_DIR
        if [ ! -f "$PANEL_DIR/artisan" ]; then
            error "No Pterodactyl panel found at $PANEL_DIR"
            exit 1
        fi
    fi

    echo ""
    info "Panel detected at: ${BOLD}$PANEL_DIR${RESET}"
    echo ""
}

# --- Backup ---
backup_panel() {
    print_banner
    echo -e "  ${BOLD}Step 1: Backup Panel${RESET}"
    echo ""

    BACKUP_DIR="${PANEL_DIR}-backup-$(date +%Y%m%d-%H%M%S)"

    warning "This will create a full backup of your panel."
    warning "Backup location: ${YELLOW}$BACKUP_DIR${RESET}"
    echo ""

    input "Proceed with backup? (y/N): "
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ [Yy] ]]; then
        error "Backup aborted. Installation cannot continue without backup."
        exit 1
    fi

    echo ""
    info "Creating backup, please wait..."

    # Backup files
    cp -a "$PANEL_DIR" "$BACKUP_DIR"
    success "Panel files backed up to: $BACKUP_DIR"

    # Backup database info
    if [ -f "$PANEL_DIR/.env" ]; then
        DB_DATABASE=$(grep DB_DATABASE "$PANEL_DIR/.env" 2>/dev/null | cut -d '=' -f2 || echo "unknown")
    else
        DB_DATABASE="unknown"
    fi

    echo ""
    echo -e "  ${BOLD}Backup Summary:${RESET}"
    echo -e "  Files: ${GREEN}$BACKUP_DIR${RESET}"
    echo -e "  Database: ${YELLOW}$DB_DATABASE${RESET} (not backed up by this script)"
    echo -e "  ${DIM}Tip: Backup your database separately with:${RESET}"
    echo -e "  ${DIM}  mysqldump -u root -p $DB_DATABASE > panel-db.sql${RESET}"
    echo ""

    echo "$BACKUP_DIR" > /tmp/miuujs_backup_path
}

# --- Detect Package Manager ---
detect_node() {
    # Check node
    if ! [ -x "$(command -v node)" ]; then
        error "Node.js is not installed."
        info "Install Node.js 22 with: curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt install nodejs -y"
        exit 1
    fi

    NODE_VERSION=$(node -v | sed 's/v//' | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 22 ]; then
        warning "Node.js v$(node -v | sed 's/v//') detected, v22+ recommended."
        info "Upgrade with: n 22  (if 'n' is installed) or install Node.js 22 from nodesource."
        input "Continue anyway? (y/N): "
        read -r CONFIRM
        if [[ ! "$CONFIRM" =~ [Yy] ]]; then
            exit 1
        fi
    fi

    # Check yarn or npm
    if [ -x "$(command -v yarn)" ]; then
        PKG_MANAGER="yarn"
        info "Using yarn for package installation."
    elif [ -x "$(command -v npm)" ]; then
        PKG_MANAGER="npm"
        info "Using npm for package installation."
    else
        error "Neither yarn nor npm found."
        info "Install yarn: npm install -g yarn  (requires Node.js)"
        exit 1
    fi
}

# --- Source Files ---
determine_source() {
    # Check if running from the cloned repo or from curl
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

    if [ -f "$SCRIPT_DIR/package.json" ] && grep -q "miuujs" "$SCRIPT_DIR/README.md" 2>/dev/null; then
        SOURCE="local"
        REPO_DIR="$SCRIPT_DIR"
        info "Using local repository: $REPO_DIR"
    else
        SOURCE="remote"
        REPO_DIR="/tmp/miuujs-repo"
        info "Downloading theme from GitHub..."
        rm -rf "$REPO_DIR"
        curl -sL "https://github.com/miuujs/miuujs/archive/main.tar.gz" -o /tmp/miuujs.tar.gz
        tar -xzf /tmp/miuujs.tar.gz -C /tmp/
        mv /tmp/miuujs-main "$REPO_DIR"
        success "Theme downloaded to $REPO_DIR"
    fi
    echo ""
}

# --- Install Dependencies ---
install_deps() {
    print_banner
    echo -e "  ${BOLD}Step 2: Install Dependencies${RESET}"
    echo ""

    cd "$PANEL_DIR"

    # Composer dependencies
    if [ -x "$(command -v composer)" ]; then
        info "Checking Composer dependencies..."
        composer install --no-dev --quiet 2>/dev/null || composer install --no-dev 2>&1 | tail -5
        success "Composer dependencies updated."
    else
        warning "Composer not found. Skipping PHP dependency check."
    fi

    # Node dependencies
    info "Installing Node.js dependencies with $PKG_MANAGER..."

    # Ensure correct package.json from theme (overwrites panel's original)
    cp "$REPO_DIR/package.json" "$PANEL_DIR/package.json"
    cp "$REPO_DIR/tailwind.config.js" "$PANEL_DIR/tailwind.config.js"
    cp "$REPO_DIR/webpack.config.js" "$PANEL_DIR/webpack.config.js"

    # Remove old lock file and node_modules if incompatible
    if [ "$PKG_MANAGER" = "yarn" ]; then
        [ -f yarn.lock ] && rm -f yarn.lock
        yarn install --frozen-lockfile 2>/dev/null || yarn install
    else
        [ -f package-lock.json ] && rm -f package-lock.json
        npm install
    fi

    success "Dependencies installed."
    echo ""
}

# --- Copy Theme Files ---
copy_theme() {
    print_banner
    echo -e "  ${BOLD}Step 3: Copy Theme Files${RESET}"
    echo ""

    cd "$PANEL_DIR"
    SRC="$REPO_DIR"

    info "Copying theme files to panel..."

    # Create directories if needed
    mkdir -p "$PANEL_DIR/resources/views/admin/miuujs"

    # Copy app/ files
    if [ -d "$SRC/app/Http/Controllers/Admin/MiuuJS" ]; then
        cp -r "$SRC/app/Http/Controllers/Admin/MiuuJS" "$PANEL_DIR/app/Http/Controllers/Admin/"
    fi
    [ -f "$SRC/app/Http/Controllers/Base/LocaleController.php" ] && \
        cp "$SRC/app/Http/Controllers/Base/LocaleController.php" "$PANEL_DIR/app/Http/Controllers/Base/"
    [ -f "$SRC/app/Http/Requests/Base/LocaleRequest.php" ] && \
        cp "$SRC/app/Http/Requests/Base/LocaleRequest.php" "$PANEL_DIR/app/Http/Requests/Base/"
    [ -f "$SRC/app/Http/ViewComposers/AssetComposer.php" ] && \
        cp "$SRC/app/Http/ViewComposers/AssetComposer.php" "$PANEL_DIR/app/Http/ViewComposers/"

    # Copy config/
    [ -f "$SRC/config/arix.php" ] && cp "$SRC/config/arix.php" "$PANEL_DIR/config/"
    [ -f "$SRC/config/miuujs.php" ] && cp "$SRC/config/miuujs.php" "$PANEL_DIR/config/"

    # Copy routes/
    [ -f "$SRC/routes/admin.php" ] && cp "$SRC/routes/admin.php" "$PANEL_DIR/routes/admin.php"

    # Copy public/
    if [ -d "$SRC/public/miuujs" ]; then
        cp -r "$SRC/public/miuujs" "$PANEL_DIR/public/"
    fi
    if [ -f "$SRC/public/themes/pterodactyl/css/miuujs.css" ]; then
        mkdir -p "$PANEL_DIR/public/themes/pterodactyl/css"
        cp "$SRC/public/themes/pterodactyl/css/miuujs.css" "$PANEL_DIR/public/themes/pterodactyl/css/"
    fi
    if [ -f "$SRC/public/themes/pterodactyl/css/pterodactyl.css" ]; then
        cp "$SRC/public/themes/pterodactyl/css/pterodactyl.css" "$PANEL_DIR/public/themes/pterodactyl/css/"
    fi

    # Copy resources/lang/
    if [ -d "$SRC/resources/lang/en/miuujs" ]; then
        cp -r "$SRC/resources/lang/en/miuujs" "$PANEL_DIR/resources/lang/en/"
    fi

    # Copy resources/views/
    [ -f "$SRC/resources/views/admin/miuujs/index.blade.php" ] && \
        cp "$SRC/resources/views/admin/miuujs/index.blade.php" "$PANEL_DIR/resources/views/admin/miuujs/"
    [ -f "$SRC/resources/views/layouts/admin.blade.php" ] && \
        cp "$SRC/resources/views/layouts/admin.blade.php" "$PANEL_DIR/resources/views/layouts/"
    [ -f "$SRC/resources/views/templates/auth/core.blade.php" ] && \
        cp "$SRC/resources/views/templates/auth/core.blade.php" "$PANEL_DIR/resources/views/templates/auth/"
    [ -f "$SRC/resources/views/templates/base/core.blade.php" ] && \
        cp "$SRC/resources/views/templates/base/core.blade.php" "$PANEL_DIR/resources/views/templates/base/"
    [ -f "$SRC/resources/views/templates/wrapper.blade.php" ] && \
        cp "$SRC/resources/views/templates/wrapper.blade.php" "$PANEL_DIR/resources/views/templates/"

    # Copy scripts/ (React frontend)
    if [ -d "$SRC/scripts" ]; then
        rsync -a "$SRC/scripts/" "$PANEL_DIR/resources/scripts/"
    fi

    success "All theme files copied."
    echo ""
}

# --- Build Frontend ---
build_frontend() {
    print_banner
    echo -e "  ${BOLD}Step 4: Build Frontend${RESET}"
    echo ""

    cd "$PANEL_DIR"

    info "Building frontend assets (this may take a few minutes)..."
    echo ""

    if [ "$PKG_MANAGER" = "yarn" ]; then
        yarn run build:production 2>&1 | tail -20
    else
        npm run build:production 2>&1 | tail -20
    fi

    if [ $? -eq 0 ]; then
        success "Frontend built successfully."
    else
        error "Frontend build failed! Check the output above."
        exit 1
    fi
    echo ""
}

# --- Finalize ---
finalize() {
    print_banner
    echo -e "  ${BOLD}Step 5: Finalize${RESET}"
    echo ""

    cd "$PANEL_DIR"

    # Set permissions
    info "Setting file permissions..."
    chown -R www-data:www-data "$PANEL_DIR/storage" "$PANEL_DIR/bootstrap/cache" "$PANEL_DIR/public/assets" 2>/dev/null || true
    chown www-data:www-data \
        "$PANEL_DIR/app/Http/Controllers/Admin/MiuuJS" \
        "$PANEL_DIR/app/Http/Controllers/Base/LocaleController.php" \
        "$PANEL_DIR/app/Http/Requests/Base/LocaleRequest.php" \
        "$PANEL_DIR/app/Http/ViewComposers/AssetComposer.php" \
        "$PANEL_DIR/config/arix.php" \
        "$PANEL_DIR/config/miuujs.php" \
        "$PANEL_DIR/public/miuujs" \
        "$PANEL_DIR/public/themes/pterodactyl/css/miuujs.css" \
        "$PANEL_DIR/resources/lang/en/miuujs" \
        "$PANEL_DIR/resources/views/admin/miuujs" \
        "$PANEL_DIR/resources/views/layouts/admin.blade.php" \
        "$PANEL_DIR/resources/views/templates/auth/core.blade.php" \
        "$PANEL_DIR/resources/views/templates/base/core.blade.php" \
        "$PANEL_DIR/resources/views/templates/wrapper.blade.php" \
        "$PANEL_DIR/package.json" \
        "$PANEL_DIR/tailwind.config.js" \
        "$PANEL_DIR/webpack.config.js" 2>/dev/null || true
    success "Permissions set."

    # Clear caches
    info "Clearing Laravel caches..."
    php artisan view:clear 2>/dev/null || true
    php artisan config:clear 2>/dev/null || true
    php artisan cache:clear 2>/dev/null || true
    php artisan optimize:clear 2>/dev/null || true
    success "Caches cleared."

    # Create restore script
    BACKUP_PATH=$(cat /tmp/miuujs_backup_path 2>/dev/null || echo "$PANEL_DIR-backup-*")
    cat > "$PANEL_DIR/miuujs-restore.sh" << 'RESTORE_EOF'
#!/bin/bash
# MiuuJS Restore Script
# Restores panel from backup created during installation

set -e


RESET="\e[0m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
BOLD="\e[1m"

echo ""
echo "  MiuuJS Theme Restore"
echo ""

if [[ $EUID -ne 0 ]]; then
    echo -e "* ${RED}ERROR${RESET}: Must run as root (sudo)."
    exit 1
fi

BACKUP_DIR="$1"
PANEL_DIR="/var/www/pterodactyl"

if [ -z "$BACKUP_DIR" ]; then
    echo -e "* ${YELLOW}Usage${RESET}: $0 <backup-directory>"
    echo ""
    BACKUPS=($(ls -d /var/www/pterodactyl-backup-* 2>/dev/null || true))
    if [ ${#BACKUPS[@]} -gt 0 ]; then
        echo "  Available backups:"
        for i in "${!BACKUPS[@]}"; do
            echo "  [$i] ${BACKUPS[$i]}"
        done
        echo ""
        echo -n "  Select backup to restore (0-$((${#BACKUPS[@]}-1))): "
        read -r SELECTION
        if [[ "$SELECTION" =~ ^[0-9]+$ ]] && [ "$SELECTION" -lt "${#BACKUPS[@]}" ]; then
            BACKUP_DIR="${BACKUPS[$SELECTION]}"
        else
            echo -e "* ${RED}ERROR${RESET}: Invalid selection."
            exit 1
        fi
    else
        echo -e "* ${RED}ERROR${RESET}: No backups found."
        exit 1
    fi
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "* ${RED}ERROR${RESET}: Backup directory not found: $BACKUP_DIR"
    exit 1
fi

echo -e "* ${CYAN}INFO${RESET}: Restoring from: $BACKUP_DIR"
echo -n "  Are you sure? This will OVERWRITE your current panel. (y/N): "
read -r CONFIRM
if [[ ! "$CONFIRM" =~ [Yy] ]]; then
    echo -e "* ${YELLOW}Cancelled${RESET}."
    exit 0
fi

echo ""
echo -e "* ${CYAN}Restoring...${RESET}"

# Remove current panel files (except storage)
cd "$PANEL_DIR"
for f in * .[!.]* 2>/dev/null; do
    [ "$f" = "storage" ] && continue
    [ "$f" = "miuujs-restore.sh" ] && continue
    rm -rf "$f"
done

# Restore from backup
cp -a "$BACKUP_DIR"/* "$PANEL_DIR/"
cp -a "$BACKUP_DIR"/.[!.]* "$PANEL_DIR/" 2>/dev/null || true

# Rebuild assets
cd "$PANEL_DIR"
if [ -x "$(command -v yarn)" ]; then
    yarn install --frozen-lockfile 2>/dev/null || yarn install
    yarn run build:production 2>&1 | tail -5
elif [ -x "$(command -v npm)" ]; then
    npm install
    npm run build:production 2>&1 | tail -5
fi

php artisan view:clear 2>/dev/null || true
php artisan config:clear 2>/dev/null || true
php artisan optimize:clear 2>/dev/null || true

chown -R www-data:www-data "$PANEL_DIR/storage" "$PANEL_DIR/bootstrap/cache" 2>/dev/null || true

echo ""
echo -e "* ${GREEN}SUCCESS${RESET}: Panel restored from backup."
echo ""
RESTORE_EOF
    chmod +x "$PANEL_DIR/miuujs-restore.sh"
    success "Restore script created at: ${BOLD}$PANEL_DIR/miuujs-restore.sh${RESET}"

    echo ""
    echo -e "  ${BOLD}==================== INSTALLATION COMPLETE ====================${RESET}"
    echo ""
    echo -e "  ${GREEN}MiuuJS theme has been installed successfully!${RESET}"
    echo ""
    echo -e "  ${CYAN}Store:${RESET}         ${BOLD}https://your-panel.com/store${RESET}"
    echo -e "  ${CYAN}Admin Config:${RESET}  ${BOLD}https://your-panel.com/admin/miuujs${RESET}"
    echo -e "  ${CYAN}Admin Billing:${RESET} ${BOLD}https://your-panel.com/admin/mustikapay${RESET}"
    echo ""
    echo -e "  ${CYAN}Restore:${RESET}       ${BOLD}sudo bash $PANEL_DIR/miuujs-restore.sh${RESET}"
    echo -e "  ${CYAN}Backup:${RESET}        ${BOLD}$BACKUP_PATH${RESET}"
    echo ""
    echo -e "  ${YELLOW}Note:${RESET} If you see any visual issues, clear your browser cache."
    echo ""
}

# --- Install MustikaPay Mod ---
install_mod() {
    print_banner
    echo -e "  ${BOLD}Optional: Install MustikaPay Store Mod${RESET}"
    echo ""
    echo -e "  ${CYAN}Adds:${RESET} Balance top-up, server store, payment gateway (QRIS/VA)"
    echo ""

    input "Install MustikaPay Store mod? (y/N): "
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ [Yy] ]]; then
        info "Skipping mod installation."
        return
    fi

    if [ ! -d "$REPO_DIR/plugins" ]; then
        warning "plugins/ not found in $REPO_DIR. Re-cloning repository..."
        rm -rf "$REPO_DIR"
        git clone https://github.com/miuujs/miuujs.git "$REPO_DIR" 2>/dev/null || {
            error "Failed to clone repo. Ensure git is installed."
            return
        }
    fi

    cd "$PANEL_DIR"
    SRC="$REPO_DIR"

    info "Installing MustikaPay mod..."

    # Copy Extensions
    if [ -d "$SRC/plugins/app/Extensions" ]; then
        cp -r "$SRC/plugins/app/Extensions" "$PANEL_DIR/app/"
    fi

    # Copy Controllers
    if [ -d "$SRC/plugins/app/Http/Controllers/Admin" ]; then
        cp "$SRC/plugins/app/Http/Controllers/Admin/MustikaPayController.php" "$PANEL_DIR/app/Http/Controllers/Admin/"
    fi
    if [ -d "$SRC/plugins/app/Http/Controllers/Api/Client/Store" ]; then
        mkdir -p "$PANEL_DIR/app/Http/Controllers/Api/Client/Store"
        cp "$SRC/plugins/app/Http/Controllers/Api/Client/Store/StoreController.php" "$PANEL_DIR/app/Http/Controllers/Api/Client/Store/"
    fi

    # Copy Models
    if [ -d "$SRC/plugins/app/Models" ]; then
        cp "$SRC/plugins/app/Models/"*.php "$PANEL_DIR/app/Models/"
    fi

    # Copy Migrations
    if [ -d "$SRC/plugins/database/migrations" ]; then
        cp "$SRC/plugins/database/migrations/"*.php "$PANEL_DIR/database/migrations/"
    fi

    # Copy Views
    if [ -f "$SRC/plugins/resources/views/admin/mustikapay.blade.php" ]; then
        cp "$SRC/plugins/resources/views/admin/mustikapay.blade.php" "$PANEL_DIR/resources/views/admin/"
    fi

    # Copy the miuujs-upgraded StoreContainer if exists
    if [ -f "$SRC/plugins/resources/scripts/components/dashboard/StoreContainer.tsx" ]; then
        mkdir -p "$PANEL_DIR/resources/scripts/components/dashboard"
        cp "$SRC/plugins/resources/scripts/components/dashboard/StoreContainer.tsx" "$PANEL_DIR/resources/scripts/components/dashboard/"
    fi

    # --- Route modifications ---
    info "Adding MustikaPay routes..."

    if ! grep -q "MustikaPay" "$PANEL_DIR/routes/admin.php" 2>/dev/null; then
        cat << 'ROUTES' >> "$PANEL_DIR/routes/admin.php"

/* MustikaPay Billing Routes */
Route::group(['prefix' => 'mustikapay'], function () {
    Route::get('/', [Admin\MustikaPayController::class, 'index'])->name('admin.mustikapay');
    Route::post('/', [Admin\MustikaPayController::class, 'update'])->name('admin.mustikapay.update');
    Route::post('/product', [Admin\MustikaPayController::class, 'addProduct'])->name('admin.mustikapay.product.add');
    Route::delete('/product/{id}', [Admin\MustikaPayController::class, 'deleteProduct'])->name('admin.mustikapay.product.delete');
});
ROUTES
    fi

    if ! grep -q "/store" "$PANEL_DIR/routes/api-client.php" 2>/dev/null; then
        cat << 'ROUTES' >> "$PANEL_DIR/routes/api-client.php"

/* Store Routes */
Route::prefix('/store')->group(function () {
    Route::get('/', [Client\Store\StoreController::class, 'index']);
    Route::post('/pay', [Client\Store\StoreController::class, 'pay']);
    Route::post('/buy', [Client\Store\StoreController::class, 'buy']);
});
ROUTES
    fi

    # --- Model modifications ---
    info "Updating models..."
    if ! grep -q "'balance'" "$PANEL_DIR/app/Models/User.php" 2>/dev/null; then
        sed -i "/'root_admin',/a \\\t'balance'," "$PANEL_DIR/app/Models/User.php"
    fi
    if ! grep -q "'is_billed'" "$PANEL_DIR/app/Models/Server.php" 2>/dev/null; then
        sed -i "/'oom_disabled' => 'boolean',/a \\\t'is_billed' => 'boolean',\n\\t'expires_at' => 'datetime'," "$PANEL_DIR/app/Models/Server.php"
    fi

    # --- Admin sidebar menu link ---
    info "Adding admin menu link..."
    if ! grep -q "mustikapay" "$PANEL_DIR/resources/views/layouts/admin.blade.php" 2>/dev/null; then
        sed -i 's|title="MiuuJS Config">|title="MiuuJS Config">\n\t\t\t\t\t\t\t\t<li><a href="{{ route('"'"'admin.mustikapay'"'"') }}" data-toggle="tooltip" data-placement="bottom" title="MustikaPay Billing"><i class="fa fa-credit-card"></i></a></li>|' "$PANEL_DIR/resources/views/layouts/admin.blade.php"
    fi

    # --- Composer autoload ---
    info "Registering MustikaPay namespace in composer autoload..."
    if ! grep -q "MustikaPay" "$PANEL_DIR/composer.json" 2>/dev/null; then
        sed -i 's|"Pterodactyl\\\\": "app/",|"Pterodactyl\\\\": "app/",\n            "MustikaPay\\\\": "app/Extensions/Payment/MustikaPay/",|' "$PANEL_DIR/composer.json"
    fi
    composer dump-autoload 2>/dev/null || true

    success "MustikaPay mod installed."
    echo ""
}

# --- Run Migrations ---
run_migrations() {
    info "Running database migrations..."
    cd "$PANEL_DIR"
    php artisan migrate --force 2>&1
    success "Migrations complete."
    echo ""
}

# --- Uninstall ---
uninstall_theme() {
    print_banner
    echo -e "  ${BOLD}Uninstall MiuuJS Theme${RESET}"
    echo ""

    if [ ! -f /tmp/miuujs_backup_path ] && [ -z "$(ls -d /var/www/pterodactyl-backup-* 2>/dev/null)" ]; then
        error "No backup found. Cannot uninstall safely."
        echo "  Use the restore script: sudo bash $PANEL_DIR/miuujs-restore.sh"
        exit 1
    fi

    BACKUP_PATH=$(cat /tmp/miuujs_backup_path 2>/dev/null || ls -d /var/www/pterodactyl-backup-* 2>/dev/null | tail -1)

    warning "This will restore the panel from backup: ${YELLOW}$BACKUP_PATH${RESET}"
    input "Continue? (y/N): "
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ [Yy] ]]; then
        exit 0
    fi

    bash "$PANEL_DIR/miuujs-restore.sh" "$BACKUP_PATH"
}

# --- Main Menu ---
main_menu() {
    print_banner
    echo -e "  ${BOLD}What would you like to do?${RESET}"
    echo ""
    echo "  [0] Install MiuuJS Theme"
    echo "  [1] Uninstall (restore from backup)"
    echo "  [2] Exit"
    echo ""

    input "Select option [0-2]: "
    read -r ACTION
    case "$ACTION" in
        0)
            preflight
            detect_node
            determine_source
            backup_panel
            install_deps
            copy_theme
            install_mod
            build_frontend
            run_migrations
            finalize
            ;;
        1)
            preflight
            uninstall_theme
            ;;
        2)
            exit 0
            ;;
        *)
            error "Invalid option."
            exit 1
            ;;
    esac
}

# --- Run ---
main_menu
