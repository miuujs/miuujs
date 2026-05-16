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
    echo -e "  ${MAGENTA}███    ███ ██ ██    ██ ██    ██      ██ ███████ ${RESET}"
    echo -e "  ${MAGENTA}████  ████ ██ ██    ██ ██    ██      ██ ██      ${RESET}"
    echo -e "  ${MAGENTA}██ ████ ██ ██ ██    ██ ██    ██      ██ ███████ ${RESET}"
    echo -e "  ${MAGENTA}██  ██  ██ ██ ██    ██ ██    ██ ██   ██      ██ ${RESET}"
    echo -e "  ${MAGENTA}██      ██ ██  ██████   ██████   █████  ███████ ${RESET}"
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

    if ! [ -x "$(command -v rsync)" ]; then
        info "rsync not found. Installing..."
        apt-get install rsync -y 2>/dev/null || {
            error "Failed to install rsync. Install it with: apt install rsync -y"
            exit 1
        }
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

# --- Auto-upgrade Node.js to v22 ---
ensure_node22() {
    if ! [ -x "$(command -v node)" ]; then
        info "Node.js not found. Installing Node.js 22..."
        curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
        apt install nodejs -y
        # Ensure /usr/bin/node takes precedence over any old node in /usr/local/bin
        update-alternatives --remove node /usr/local/bin/node 2>/dev/null || true
        update-alternatives --install /usr/local/bin/node node /usr/bin/node 100 2>/dev/null || true
        hash -r
        success "Node.js installed: $(node -v)"
        return
    fi

    NODE_VERSION=$(node -v | sed 's/v//' | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 22 ]; then
        info "Node.js v$(node -v) detected. Upgrading to v22..."
        curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
        apt install nodejs -y
        # Fix PATH: /usr/local/bin/node (old) might shadow /usr/bin/node (new)
        update-alternatives --remove node /usr/local/bin/node 2>/dev/null || true
        update-alternatives --install /usr/local/bin/node node /usr/bin/node 100 2>/dev/null || true
        hash -r
        # Verify upgrade
        NEW_NODE=$(node -v 2>/dev/null || /usr/bin/node -v 2>/dev/null || echo "unknown")
        success "Node.js upgraded: $NEW_NODE"
    else
        info "Node.js v$(node -v) meets requirements."
    fi

    # Ensure the correct Node is in PATH for subsequent commands
    if [ -x /usr/bin/node ] && [ "$(node -v 2>/dev/null | cut -d'.' -f1 | sed 's/v//')" -lt 22 ]; then
        export PATH="/usr/bin:$PATH"
    fi

    # Check yarn or npm
    if [ -x "$(command -v yarn)" ]; then
        PKG_MANAGER="yarn"
    elif [ -x "$(command -v npm)" ]; then
        PKG_MANAGER="npm"
    else
        error "Neither yarn nor npm found."
        info "Install yarn: npm install -g yarn"
        exit 1
    fi
    info "Using $PKG_MANAGER for package installation."
}

# --- Backup (skip if any backup already exists) ---
backup_panel() {
    print_banner
    echo -e "  ${BOLD}Step 1: Backup Panel${RESET}"
    echo ""

    EXISTING_BACKUPS=($(ls -d "${PANEL_DIR}-backup-"* 2>/dev/null || true))
    if [ ${#EXISTING_BACKUPS[@]} -gt 0 ]; then
        info "Existing backup found: ${EXISTING_BACKUPS[0]}"
        info "Skipping backup (backup already exists)."
        echo "${EXISTING_BACKUPS[0]}" > /tmp/miuujs_backup_path
        return
    fi

    BACKUP_DIR="${PANEL_DIR}-backup-$(date +%Y%m%d-%H%M%S)"

    echo ""
    info "Creating backup, please wait..."

    cp -a "$PANEL_DIR" "$BACKUP_DIR"
    success "Panel files backed up to: $BACKUP_DIR"

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

# --- Source Files ---
determine_source() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

    if [ -f "$SCRIPT_DIR/package.json" ] && [ -f "$SCRIPT_DIR/README.md" ] && grep -q "miuujs" "$SCRIPT_DIR/README.md" 2>/dev/null; then
        SOURCE="local"
        REPO_DIR="$SCRIPT_DIR"
        info "Using local repository: $REPO_DIR"
    else
        SOURCE="remote"
        REPO_DIR="/tmp/miuujs-repo"
        info "Downloading theme from GitHub..."
        rm -rf "$REPO_DIR"
        echo ""
        curl -L "https://github.com/miuujs/miuujs/archive/main.tar.gz" -o /tmp/miuujs.tar.gz
        echo ""
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

    if [ -x "$(command -v composer)" ]; then
        info "Updating Composer dependencies..."
        composer install --no-dev --no-interaction 2>&1 | tail -5
        local COMPOSER_EXIT=${PIPESTATUS[0]}
        if [ "$COMPOSER_EXIT" -ne 0 ]; then
            warning "Composer install exited with code $COMPOSER_EXIT."
        else
            success "Composer dependencies updated."
        fi
    else
        warning "Composer not found. Skipping PHP dependency check."
    fi

    info "Installing Node.js dependencies with $PKG_MANAGER..."
    echo ""

    # Use the repo's package.json so all deps (including path-browserify) match
    # the repo's webpack.config.js and scripts
    cp "$REPO_DIR/package.json" "$PANEL_DIR/package.json"
    cp "$REPO_DIR/tailwind.config.js" "$PANEL_DIR/tailwind.config.js"
    cp "$REPO_DIR/webpack.config.js" "$PANEL_DIR/webpack.config.js"

    if [ "$PKG_MANAGER" = "yarn" ]; then
        yarn install --no-progress 2>&1 | tail -10
        local INSTALL_EXIT=${PIPESTATUS[0]}
    else
        npm install --no-progress 2>&1 | tail -10
        local INSTALL_EXIT=${PIPESTATUS[0]}
    fi
    if [ "$INSTALL_EXIT" -ne 0 ]; then
        error "$PKG_MANAGER install failed (exit $INSTALL_EXIT)."
        exit 1
    fi
    echo ""

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

    mkdir -p "$PANEL_DIR/resources/views/admin/miuujs"

    if [ -d "$SRC/app/Http/Controllers/Admin/MiuuJS" ]; then
        cp -r "$SRC/app/Http/Controllers/Admin/MiuuJS" "$PANEL_DIR/app/Http/Controllers/Admin/"
    fi
    [ -f "$SRC/app/Http/Controllers/Base/LocaleController.php" ] && \
        cp "$SRC/app/Http/Controllers/Base/LocaleController.php" "$PANEL_DIR/app/Http/Controllers/Base/"
    [ -f "$SRC/app/Http/Requests/Base/LocaleRequest.php" ] && \
        cp "$SRC/app/Http/Requests/Base/LocaleRequest.php" "$PANEL_DIR/app/Http/Requests/Base/"
    [ -f "$SRC/app/Http/ViewComposers/AssetComposer.php" ] && \
        cp "$SRC/app/Http/ViewComposers/AssetComposer.php" "$PANEL_DIR/app/Http/ViewComposers/"

    [ -f "$SRC/config/miuujs.php" ] && cp "$SRC/config/miuujs.php" "$PANEL_DIR/config/"

    # Save plugin routes before overwriting admin.php
    MUSTIKAPAY_ROUTES=""
    if grep -q "MIUUJS_PLUGIN_MUSTIKAPAY_START" "$PANEL_DIR/routes/admin.php" 2>/dev/null; then
        MUSTIKAPAY_ROUTES=$(sed -n '/MIUUJS_PLUGIN_MUSTIKAPAY_START/,/MIUUJS_PLUGIN_MUSTIKAPAY_END/p' "$PANEL_DIR/routes/admin.php" 2>/dev/null)
    fi
    [ -f "$SRC/routes/admin.php" ] && cp "$SRC/routes/admin.php" "$PANEL_DIR/routes/admin.php"
    # Re-add plugin routes if they existed
    if [ -n "$MUSTIKAPAY_ROUTES" ]; then
        echo "" >> "$PANEL_DIR/routes/admin.php"
        echo "$MUSTIKAPAY_ROUTES" >> "$PANEL_DIR/routes/admin.php"
    fi

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

    if [ -d "$SRC/resources/lang/en/miuujs" ]; then
        cp -r "$SRC/resources/lang/en/miuujs" "$PANEL_DIR/resources/lang/en/"
    fi

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

    info "Building frontend assets..."
    echo -e "  ${DIM}This may take 2-5 minutes. Full log saved for debugging.${RESET}"
    echo ""

    BUILD_LOG="/tmp/miuujs-build-$(date +%s).log"
    info "Build started at $(date '+%H:%M:%S') — log: $BUILD_LOG"
    echo ""
    if [ "$PKG_MANAGER" = "yarn" ]; then
        yarn run build:production 2>&1 | tee "$BUILD_LOG" | tail -20
    else
        npm run build:production 2>&1 | tee "$BUILD_LOG" | tail -20
    fi
    BUILD_EXIT=${PIPESTATUS[0]}

    if [ "$BUILD_EXIT" -eq 0 ]; then
        success "Frontend built successfully at $(date '+%H:%M:%S')."
    else
        error "Frontend build failed! Full log: $BUILD_LOG"
        exit 1
    fi
    echo ""
}

# --- Run Migrations ---
run_migrations() {
    info "Running database migrations..."
    echo ""
    cd "$PANEL_DIR"
    php artisan migrate --force --no-interaction 2>&1
    echo ""
    success "Migrations complete."
    echo ""
}

# --- Finalize ---
finalize() {
    print_banner
    echo -e "  ${BOLD}Step 5: Finalize${RESET}"
    echo ""

    cd "$PANEL_DIR"

    info "Setting file permissions..."
    chown -R www-data:www-data "$PANEL_DIR/storage" "$PANEL_DIR/bootstrap/cache" "$PANEL_DIR/public/assets" 2>/dev/null || true
    success "Permissions set."

    info "Clearing Laravel caches..."
    php artisan view:clear 2>/dev/null || true
    php artisan config:clear 2>/dev/null || true
    php artisan cache:clear 2>/dev/null || true
    php artisan optimize:clear 2>/dev/null || true
    php artisan queue:restart 2>/dev/null || true
    success "Caches cleared."

    BACKUP_PATH=$(cat /tmp/miuujs_backup_path 2>/dev/null || echo "")

    echo ""
    echo -e "  ${BOLD}==================== INSTALLATION COMPLETE ====================${RESET}"
    echo ""
    echo -e "  ${GREEN}MiuuJS theme has been installed successfully!${RESET}"
    echo ""
    echo -e "  ${CYAN}Admin Config:${RESET}  ${BOLD}https://your-panel.com/admin/miuujs${RESET}"
    echo ""
    if [ -n "$BACKUP_PATH" ] && [ -d "$BACKUP_PATH" ]; then
        echo -e "  ${CYAN}Backup:${RESET}        ${BOLD}$BACKUP_PATH${RESET}"
        echo ""
    fi
    echo -e "  ${YELLOW}Note:${RESET} If you see any visual issues, clear your browser cache."
    echo ""
}

# --- Install MustikaPay Plugin ---
install_mustikapay() {
    print_banner
    echo -e "  ${BOLD}Install MustikaPay Payment Gateway Plugin${RESET}"
    echo ""
    echo -e "  ${CYAN}Adds:${RESET} Top-up saldo, pembelian server, pembayaran QRIS/VA"
    echo ""

    cd "$PANEL_DIR"
    SRC="$REPO_DIR"

    if [ ! -d "$SRC/plugins" ]; then
        warning "plugins/ not found in $REPO_DIR. Re-cloning repository..."
        rm -rf "$REPO_DIR"
        git clone https://github.com/miuujs/miuujs.git "$REPO_DIR" 2>/dev/null || {
            error "Failed to clone repo. Ensure git is installed."
            return
        }
    fi

    info "Installing MustikaPay plugin..."

    if [ -d "$SRC/plugins/app/Extensions" ]; then
        cp -r "$SRC/plugins/app/Extensions" "$PANEL_DIR/app/"
    fi
    if [ -d "$SRC/plugins/app/Http/Controllers/Admin" ]; then
        cp "$SRC/plugins/app/Http/Controllers/Admin/MustikaPayController.php" "$PANEL_DIR/app/Http/Controllers/Admin/"
    fi
    if [ -d "$SRC/plugins/app/Http/Controllers/Api/Client/Store" ]; then
        mkdir -p "$PANEL_DIR/app/Http/Controllers/Api/Client/Store"
        cp "$SRC/plugins/app/Http/Controllers/Api/Client/Store/StoreController.php" "$PANEL_DIR/app/Http/Controllers/Api/Client/Store/"
    fi
    if [ -d "$SRC/plugins/app/Models" ]; then
        cp "$SRC/plugins/app/Models/"*.php "$PANEL_DIR/app/Models/"
    fi
    if [ -d "$SRC/plugins/database/migrations" ]; then
        cp "$SRC/plugins/database/migrations/"*.php "$PANEL_DIR/database/migrations/"
    fi
    if [ -f "$SRC/plugins/resources/views/admin/mustikapay.blade.php" ]; then
        cp "$SRC/plugins/resources/views/admin/mustikapay.blade.php" "$PANEL_DIR/resources/views/admin/"
    fi

    # Admin routes
    if ! grep -q "MIUUJS_PLUGIN_MUSTIKAPAY_START" "$PANEL_DIR/routes/admin.php" 2>/dev/null; then
        cat >> "$PANEL_DIR/routes/admin.php" << 'MIUUJS_ROUTES'

/* MIUUJS_PLUGIN_MUSTIKAPAY_START */
/* MustikaPay Billing Routes */
Route::group(['prefix' => 'mustikapay'], function () {
    Route::get('/', [Admin\MustikaPayController::class, 'index'])->name('admin.mustikapay');
    Route::post('/', [Admin\MustikaPayController::class, 'update'])->name('admin.mustikapay.update');
    Route::post('/product', [Admin\MustikaPayController::class, 'addProduct'])->name('admin.mustikapay.product.add');
    Route::post('/product/{id}', [Admin\MustikaPayController::class, 'updateProduct'])->name('admin.mustikapay.product.update');
    Route::delete('/product/{id}', [Admin\MustikaPayController::class, 'deleteProduct'])->name('admin.mustikapay.product.delete');
});
/* MIUUJS_PLUGIN_MUSTIKAPAY_END */
MIUUJS_ROUTES
    fi

    # API Routes
    if ! grep -q "MIUUJS_PLUGIN_STORE_START" "$PANEL_DIR/routes/api-client.php" 2>/dev/null; then
        cat >> "$PANEL_DIR/routes/api-client.php" << 'MIUUJS_ROUTES'

/* MIUUJS_PLUGIN_STORE_START */
/* Store API Routes (MustikaPay) */
Route::prefix('/products')->group(function () {
    Route::get('/', [Client\Store\StoreController::class, 'index']);
    Route::post('/pay', [Client\Store\StoreController::class, 'pay']);
    Route::post('/buy', [Client\Store\StoreController::class, 'buy']);
    Route::post('/webhook', [Client\Store\StoreController::class, 'webhook']);
});
/* MIUUJS_PLUGIN_STORE_END */
MIUUJS_ROUTES
    fi

    # Model modifications (use $'...' ANSI-C quoting so \t is actual tab, \\n is sed newline)
    if ! grep -q "'balance'" "$PANEL_DIR/app/Models/User.php" 2>/dev/null; then
        sed -i $'/\'root_admin\',/a\\\t\t\'balance\',' "$PANEL_DIR/app/Models/User.php"
    fi
    if ! grep -q "'is_billed'" "$PANEL_DIR/app/Models/Server.php" 2>/dev/null; then
        sed -i $'/\'oom_disabled\' => \'boolean\',/a\\\t\t\'is_billed\' => \'boolean\',\\n\\t\t\'expires_at\' => \'datetime\',' "$PANEL_DIR/app/Models/Server.php"
    fi

    # Admin sidebar: ensure MiuuJS link exists, then add MustikaPay link after it
    if ! grep -q "mustikapay" "$PANEL_DIR/resources/views/layouts/admin.blade.php" 2>/dev/null; then
        if ! grep -q "miuujs" "$PANEL_DIR/resources/views/layouts/admin.blade.php" 2>/dev/null; then
            if [ -f "$SRC/resources/views/layouts/admin.blade.php" ]; then
                cp "$SRC/resources/views/layouts/admin.blade.php" "$PANEL_DIR/resources/views/layouts/admin.blade.php"
            fi
        fi
        MUSTIKAPAY_LINK='                                <li><a href="{{ route('"'"'admin.mustikapay'"'"') }}" data-toggle="tooltip" data-placement="bottom" title="MustikaPay Billing"><i class="fa fa-credit-card"></i></a></li>'
        sed -i "/route('admin.miuujs')/a\\${MUSTIKAPAY_LINK}" "$PANEL_DIR/resources/views/layouts/admin.blade.php"
    fi

    # Fallback: restore theme frontend files if missing or Products nav was removed by uninstall
    if [ ! -f "$PANEL_DIR/resources/scripts/components/dashboard/StoreContainer.tsx" ]; then
        mkdir -p "$PANEL_DIR/resources/scripts/components/dashboard"
        [ -f "$SRC/scripts/components/dashboard/StoreContainer.tsx" ] && cp "$SRC/scripts/components/dashboard/StoreContainer.tsx" "$PANEL_DIR/resources/scripts/components/dashboard/"
    fi
    if [ ! -f "$PANEL_DIR/resources/scripts/components/NavigationBar.tsx" ] || ! grep -q "ShoppingCartIcon" "$PANEL_DIR/resources/scripts/components/NavigationBar.tsx" 2>/dev/null; then
        [ -f "$SRC/scripts/components/NavigationBar.tsx" ] && cp "$SRC/scripts/components/NavigationBar.tsx" "$PANEL_DIR/resources/scripts/components/NavigationBar.tsx"
    fi
    if [ ! -f "$PANEL_DIR/resources/scripts/components/SideBar.tsx" ] || ! grep -q "ShoppingCartIcon" "$PANEL_DIR/resources/scripts/components/SideBar.tsx" 2>/dev/null; then
        [ -f "$SRC/scripts/components/SideBar.tsx" ] && cp "$SRC/scripts/components/SideBar.tsx" "$PANEL_DIR/resources/scripts/components/SideBar.tsx"
    fi
    if [ ! -f "$PANEL_DIR/resources/scripts/routers/DashboardRouter.tsx" ] || ! grep -q "StoreContainer" "$PANEL_DIR/resources/scripts/routers/DashboardRouter.tsx" 2>/dev/null; then
        [ -f "$SRC/scripts/routers/DashboardRouter.tsx" ] && cp "$SRC/scripts/routers/DashboardRouter.tsx" "$PANEL_DIR/resources/scripts/routers/DashboardRouter.tsx"
    fi

    # Composer autoload
    if ! grep -q "MustikaPay" "$PANEL_DIR/composer.json" 2>/dev/null; then
        sed -i 's|"Pterodactyl\\\\": "app/",|"Pterodactyl\\\\": "app/",\n            "MustikaPay\\\\": "app/Extensions/Payment/MustikaPay/",|' "$PANEL_DIR/composer.json"
    fi
    composer dump-autoload 2>/dev/null || true

    # Clear stale migration records, then run migrations
    cd "$PANEL_DIR"
    php artisan tinker --execute='DB::table("migrations")->where("migration", "like", "%2026_05_11%")->delete();' 2>/dev/null || true
    run_migrations

    success "MustikaPay plugin installed."
    echo ""
}

# --- Uninstall Plugins ---
uninstall_plugins() {
    print_banner
    echo -e "  ${BOLD}Uninstall Plugins${RESET}"
    echo ""

    warning "This will remove all plugin files, routes, and database tables."
    input "Are you sure? (y/N): "
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ [Yy] ]]; then
        info "Cancelled."
        return
    fi

    cd "$PANEL_DIR"

    info "Removing Products nav links from theme..."
    # Must use two-step sed: one-liner first, then multi-line blocks
    # (single range delete would eat following lines if start+end match on same line)
    sed -i 's/, ShoppingCartIcon//' "$PANEL_DIR/resources/scripts/components/NavigationBar.tsx" 2>/dev/null || true
    sed -i '/<NavLink[^>]*\/products[^>]*>.*<\/NavLink>/d' "$PANEL_DIR/resources/scripts/components/NavigationBar.tsx" 2>/dev/null || true
    sed -i '/<NavLink[^>]*\/products[^>]*>/,/<\/NavLink>/d' "$PANEL_DIR/resources/scripts/components/NavigationBar.tsx" 2>/dev/null || true
    # SideBar
    sed -i 's/, ShoppingCartIcon//' "$PANEL_DIR/resources/scripts/components/SideBar.tsx" 2>/dev/null || true
    sed -i '/<NavLink[^>]*\/products[^>]*>.*<\/NavLink>/d' "$PANEL_DIR/resources/scripts/components/SideBar.tsx" 2>/dev/null || true
    sed -i '/<NavLink[^>]*\/products[^>]*>/,/<\/NavLink>/d' "$PANEL_DIR/resources/scripts/components/SideBar.tsx" 2>/dev/null || true
    # DashboardRouter: remove StoreContainer import + Products route block
    sed -i '/StoreContainer/d' "$PANEL_DIR/resources/scripts/routers/DashboardRouter.tsx" 2>/dev/null || true
    sed -i '/<Route.*\/products/,/<\/Route>/d' "$PANEL_DIR/resources/scripts/routers/DashboardRouter.tsx" 2>/dev/null || true

    info "Removing plugin files..."

    # Remove controllers
    rm -f "$PANEL_DIR/app/Http/Controllers/Admin/MustikaPayController.php"
    rm -rf "$PANEL_DIR/app/Http/Controllers/Api/Client/Store"
    rm -rf "$PANEL_DIR/app/Extensions/Payment/MustikaPay"

    # Remove models
    rm -f "$PANEL_DIR/app/Models/MustikaPayProduct.php"
    rm -f "$PANEL_DIR/app/Models/MustikaPayTransaction.php"

    # Remove views
    rm -f "$PANEL_DIR/resources/views/admin/mustikapay.blade.php"

    # Remove migration files
    rm -f "$PANEL_DIR/database/migrations/2026_05_11_043856_add_balance_to_users_table.php"
    rm -f "$PANEL_DIR/database/migrations/2026_05_11_043900_create_mustikapay_transactions_table.php"
    rm -f "$PANEL_DIR/database/migrations/2026_05_11_050142_add_billing_to_servers_table.php"
    rm -f "$PANEL_DIR/database/migrations/2026_05_11_055912_create_mustikapay_products_table.php"

    # Remove StoreContainer.tsx from plugins
    rm -f "$PANEL_DIR/resources/scripts/components/dashboard/StoreContainer.tsx"

    # Remove route entries from admin.php using markers
    if [ -f "$PANEL_DIR/routes/admin.php" ]; then
        sed -i '/MIUUJS_PLUGIN_MUSTIKAPAY_START/,/MIUUJS_PLUGIN_MUSTIKAPAY_END/d' "$PANEL_DIR/routes/admin.php"
    fi

    # Remove route entries from api-client.php using markers
    if [ -f "$PANEL_DIR/routes/api-client.php" ]; then
        sed -i '/MIUUJS_PLUGIN_STORE_START/,/MIUUJS_PLUGIN_STORE_END/d' "$PANEL_DIR/routes/api-client.php"
    fi

    # Revert User.php fillable
    if grep -q "'balance'" "$PANEL_DIR/app/Models/User.php" 2>/dev/null; then
        sed -i "/'balance',/d" "$PANEL_DIR/app/Models/User.php"
    fi

    # Revert Server.php casts
    if grep -q "'is_billed'" "$PANEL_DIR/app/Models/Server.php" 2>/dev/null; then
        sed -i "/'is_billed' => 'boolean',/d" "$PANEL_DIR/app/Models/Server.php"
        sed -i "/'expires_at' => 'datetime',/d" "$PANEL_DIR/app/Models/Server.php"
    fi

    # Revert admin sidebar
    if grep -q "mustikapay" "$PANEL_DIR/resources/views/layouts/admin.blade.php" 2>/dev/null; then
        sed -i '/mustikapay/d' "$PANEL_DIR/resources/views/layouts/admin.blade.php"
    fi

    # Remove MustikaPay namespace from composer.json
    if grep -q "MustikaPay" "$PANEL_DIR/composer.json" 2>/dev/null; then
        sed -i '/"MustikaPay\\\\": "app\/Extensions\/Payment\/MustikaPay\/",/d' "$PANEL_DIR/composer.json"
    fi
    composer dump-autoload 2>/dev/null || true

    # Drop plugin tables
    info "Dropping plugin database tables..."
    php artisan tinker --execute='Schema::dropIfExists("mustikapay_products");' 2>/dev/null || true
    php artisan tinker --execute='Schema::dropIfExists("mustikapay_transactions");' 2>/dev/null || true

    # Clear migration records so reinstall works
    info "Clearing migration records..."
    php artisan tinker --execute='DB::table("migrations")->where("migration", "like", "%2026_05_11%")->delete();' 2>/dev/null || true

    success "All plugins uninstalled."
    echo ""
}

# --- Uninstall Theme ---
uninstall_theme() {
    print_banner
    echo -e "  ${BOLD}Uninstall MiuuJS Theme${RESET}"
    echo ""

    warning "This will restore your panel to its original Pterodactyl state."
    warning "All theme and plugin modifications will be removed."
    echo ""
    input "Are you sure? (y/N): "
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ [Yy] ]]; then
        info "Cancelled."
        return
    fi

    cd "$PANEL_DIR"

    # Find latest backup
    BACKUP_DIR=$(ls -dt "${PANEL_DIR}-backup-"* 2>/dev/null | head -1)
    if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
        error "No backup found at ${PANEL_DIR}-backup-*"
        info "Run the theme install first to create a backup."
        return
    fi
    info "Found backup: $BACKUP_DIR"
    echo ""

    # Step 1: Remove theme-specific files (backup may not have them, so --delete won't catch)
    info "Removing theme files..."
    rm -f "$PANEL_DIR/config/miuujs.php"
    rm -rf "$PANEL_DIR/app/Http/Controllers/Admin/MiuuJS"
    rm -f "$PANEL_DIR/app/Http/Controllers/Base/LocaleController.php"
    rm -f "$PANEL_DIR/app/Http/Requests/Base/LocaleRequest.php"
    rm -f "$PANEL_DIR/app/Http/ViewComposers/AssetComposer.php"
    rm -rf "$PANEL_DIR/public/miuujs"
    rm -f "$PANEL_DIR/public/themes/pterodactyl/css/miuujs.css"
    rm -f "$PANEL_DIR/public/themes/pterodactyl/css/pterodactyl.css"
    rm -rf "$PANEL_DIR/resources/lang/en/miuujs"
    rm -rf "$PANEL_DIR/resources/views/admin/miuujs"
    success "Theme files removed."

    # Step 2: Restore from backup (--delete removes plugin files not in backup)
    info "Restoring original panel files from backup..."
    rsync -a --delete \
        --exclude='.env' \
        --exclude='storage' \
        --exclude='node_modules' \
        --exclude='vendor' \
        --exclude='bootstrap/cache' \
        "$BACKUP_DIR/" "$PANEL_DIR/"
    success "Original panel files restored."
    echo ""

    # Step 3: Clean up plugin database tables if they exist
    if php artisan tinker --execute='echo Schema::hasTable("mustikapay_products") ? "1" : "0";' 2>/dev/null | grep -q "1"; then
        info "Cleaning up plugin database tables..."
        php artisan tinker --execute='Schema::dropIfExists("mustikapay_products");' 2>/dev/null || true
        php artisan tinker --execute='Schema::dropIfExists("mustikapay_transactions");' 2>/dev/null || true
        php artisan tinker --execute='DB::table("migrations")->where("migration", "like", "%2026_05_11%")->delete();' 2>/dev/null || true
        success "Plugin database tables removed."
        echo ""
    fi

    # Step 4: Rebuild frontend
    ensure_node22
    build_frontend

    # Step 5: Clear caches
    info "Clearing caches..."
    php artisan view:clear 2>/dev/null || true
    php artisan config:clear 2>/dev/null || true
    php artisan cache:clear 2>/dev/null || true
    php artisan optimize:clear 2>/dev/null || true
    php artisan queue:restart 2>/dev/null || true
    composer dump-autoload 2>/dev/null || true
    echo ""

    success "Theme uninstalled. Panel restored to original Pterodactyl state."
    echo ""
}

# --- Detection ---
is_theme_installed() {
    [ -f "$PANEL_DIR/config/miuujs.php" ]
}

is_mustikapay_installed() {
    [ -f "$PANEL_DIR/app/Http/Controllers/Admin/MustikaPayController.php" ]
}

# --- Plugins Menu ---
plugins_menu() {
    print_banner
    echo -e "  ${BOLD}Plugins Menu${RESET}"
    echo ""
    echo "  Available plugins:"
    echo "  [1] MustikaPay Payment Gateway"
    echo ""
    echo "  [0] Uninstall All Plugins"
    echo "  [b] Back to Main Menu"
    echo ""

    input "Select option [0-1/b]: "
    read -r PLUGIN_ACTION
    case "$PLUGIN_ACTION" in
        1)
            preflight
            if is_mustikapay_installed; then
                warning "MustikaPay is already installed!"
                input "Press Enter to return..."
                read -r
                plugins_menu
                return
            fi
            determine_source
            ensure_node22
            install_deps
            install_mustikapay
            build_frontend
            finalize
            ;;
        0)
            preflight
            ensure_node22
            uninstall_plugins
            build_frontend
            info "Clearing caches..."
            php artisan view:clear 2>/dev/null || true
            php artisan config:clear 2>/dev/null || true
            php artisan cache:clear 2>/dev/null || true
            php artisan optimize:clear 2>/dev/null || true
            success "Done."
            echo ""
            ;;
        b|B)
            main_menu
            return
            ;;
        *)
            error "Invalid option."
            input "Press Enter to try again..."
            read -r
            plugins_menu
            ;;
    esac
}

# --- Main Menu ---
main_menu() {
    print_banner
    echo -e "  ${BOLD}What would you like to do?${RESET}"
    echo ""
    echo "  [1] Install MiuuJS Theme"
    echo "  [2] Uninstall MiuuJS Theme"
    echo "  [3] Install Plugins"
    echo ""
    echo -e "  ${DIM}Press Ctrl+C to exit${RESET}"
    echo ""

    input "Select option [1-3]: "
    read -r ACTION
    case "$ACTION" in
        1)
            preflight
            if is_theme_installed; then
                warning "MiuuJS Theme is already installed!"
                input "Press Enter to return to menu..."
                read -r
                main_menu
                return
            fi
            ensure_node22
            determine_source
            backup_panel
            install_deps
            copy_theme
            build_frontend
            finalize
            ;;
        2)
            preflight
            if ! is_theme_installed; then
                warning "MiuuJS Theme is not installed!"
                input "Press Enter to return to menu..."
                read -r
                main_menu
                return
            fi
            ensure_node22
            uninstall_theme
            ;;
        3)
            plugins_menu
            ;;
        *)
            error "Invalid option."
            input "Press Enter to return to menu..."
            read -r
            main_menu
            ;;
    esac
}

# --- Run ---
main_menu
