#!/bin/bash
set -e

######################################################################################
#                                                                                    #
#  MiuuJS Theme Installer v1.1.0                                                     #
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

export MIUUJS_VERSION="1.1.0"
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
error()   { echo -e "* ${RED}ERROR${RESET}: $*" 1>&2; }
warning() { echo -e "* ${YELLOW}WARNING${RESET}: $*"; }
success() { echo -e "* ${GREEN}SUCCESS${RESET}: $*"; }
info()    { echo -e "* ${CYAN}INFO${RESET}: $*"; }
input()   { echo -ne "* ${MAGENTA}$*${RESET}"; }

print_banner() {
    clear
    echo -e ""
    echo -e "  ${MAGENTA}███    ███ ██ ██    ██ ██    ██      ██ ███████ ${RESET}"
    echo -e "  ${MAGENTA}████  ████ ██ ██    ██ ██    ██      ██ ██      ${RESET}"
    echo -e "  ${MAGENTA}██ ████ ██ ██ ██    ██ ██    ██      ██ ███████ ${RESET}"
    echo -e "  ${MAGENTA}██  ██  ██ ██ ██    ██ ██    ██ ██   ██      ██ ${RESET}"
    echo -e "  ${MAGENTA}██      ██ ██  ██████   ██████   █████  ███████ ${RESET}"
    echo -e ""
    echo -e "  ${BOLD}MiuuJS Theme Installer v${MIUUJS_VERSION}${RESET}"
    echo -e "  ${DIM}Modern dark theme for Pterodactyl panel${RESET}"
    echo ""
}

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_PATH" 2>/dev/null || true; }

# --- Pre-flight Checks ---
preflight() {
    print_banner

    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (sudo)."
        exit 1
    fi

    for cmd in curl tar rsync; do
        if ! [ -x "$(command -v $cmd)" ]; then
            info "$cmd not found. Installing..."
            apt-get install "$cmd" -y 2>/dev/null || {
                error "Failed to install $cmd."
                exit 1
            }
        fi
    done

    # Detect panel
    PANEL_DIR=""
    for dir in /var/www/pterodactyl /srv/panel; do
        if [ -d "$dir" ] && [ -f "$dir/artisan" ]; then
            PANEL_DIR="$dir"
            break
        fi
    done

    if [ -z "$PANEL_DIR" ]; then
        error "Pterodactyl panel not found at /var/www/pterodactyl or /srv/panel"
        input "Enter panel directory manually: "
        read -r PANEL_DIR
        if [ ! -f "$PANEL_DIR/artisan" ]; then
            error "No Pterodactyl panel found at $PANEL_DIR"
            exit 1
        fi
    fi

    info "Panel detected at: ${BOLD}$PANEL_DIR${RESET}"
    echo ""
    log "Panel detected at: $PANEL_DIR"
}

# --- Auto-upgrade Node.js to v22+ ---
ensure_node() {
    if ! [ -x "$(command -v node)" ]; then
        info "Node.js not found. Installing Node.js 22..."
        curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
        apt install nodejs -y
        hash -r
        success "Node.js installed: $(node -v)"
        return
    fi

    NODE_MAJOR=$(node -v | sed 's/v//' | cut -d'.' -f1)
    if [ "$NODE_MAJOR" -lt 22 ]; then
        info "Node.js v$(node -v) detected. Upgrading to v22..."
        curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
        apt install nodejs -y
        update-alternatives --remove node /usr/local/bin/node 2>/dev/null || true
        update-alternatives --install /usr/local/bin/node node /usr/bin/node 100 2>/dev/null || true
        hash -r
        success "Node.js upgraded: $(node -v)"
    else
        info "Node.js v$(node -v) meets requirements (>=22)."
    fi

    # Ensure correct Node is in PATH
    if [ -x /usr/bin/node ] && [ "$(node -v 2>/dev/null | cut -d'.' -f1 | sed 's/v//')" -lt 22 ]; then
        export PATH="/usr/bin:$PATH"
    fi

    # Detect package manager
    if [ -x "$(command -v yarn)" ]; then
        PKG_MANAGER="yarn"
    elif [ -x "$(command -v npm)" ]; then
        PKG_MANAGER="npm"
    else
        error "Neither yarn nor npm found."
        exit 1
    fi
    info "Using $PKG_MANAGER for package installation."
}

# --- Backup Panel ---
backup_panel() {
    print_banner
    echo -e "  ${BOLD}Step 1: Backup Panel${RESET}"
    echo ""

    # Check for existing backup
    EXISTING_BACKUPS=($(ls -dt "${PANEL_DIR}-backup-"* 2>/dev/null || true))
    if [ ${#EXISTING_BACKUPS[@]} -gt 0 ]; then
        info "Existing backup found: ${EXISTING_BACKUPS[0]}"
        echo "${EXISTING_BACKUPS[0]}" > /tmp/miuujs_backup_path
        return
    fi

    BACKUP_DIR="${PANEL_DIR}-backup-$(date +%Y%m%d-%H%M%S)"
    info "Creating backup..."
    cp -a "$PANEL_DIR" "$BACKUP_DIR"
    success "Panel backed up to: $BACKUP_DIR"

    DB_DATABASE=$(grep DB_DATABASE "$PANEL_DIR/.env" 2>/dev/null | cut -d'=' -f2 || echo "unknown")
    echo -e "  ${DIM}Tip: Backup database separately: mysqldump -u root -p $DB_DATABASE > panel-db.sql${RESET}"
    echo "$BACKUP_DIR" > /tmp/miuujs_backup_path
    log "Backup created at: $BACKUP_DIR"
}

# --- Determine Source ---
determine_source() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

    if [ -f "$SCRIPT_DIR/package.json" ] && [ -f "$SCRIPT_DIR/README.md" ] && grep -qi "miuujs" "$SCRIPT_DIR/README.md" 2>/dev/null; then
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
        success "Theme downloaded."
    fi
    log "Source: $SOURCE from $REPO_DIR"
}

# --- Install Dependencies ---
install_deps() {
    print_banner
    echo -e "  ${BOLD}Step 2: Install Dependencies${RESET}"
    echo ""

    cd "$PANEL_DIR"

    # Copy theme config files (these replace panel defaults)
    cp "$REPO_DIR/package.json" "$PANEL_DIR/package.json"
    cp "$REPO_DIR/tailwind.config.js" "$PANEL_DIR/tailwind.config.js"
    cp "$REPO_DIR/webpack.config.js" "$PANEL_DIR/webpack.config.js"
    [ -f "$REPO_DIR/babel.config.js" ] && cp "$REPO_DIR/babel.config.js" "$PANEL_DIR/babel.config.js"

    # Apply critical fixes BEFORE npm install
    apply_fixes

    if [ -x "$(command -v composer)" ]; then
        info "Updating Composer dependencies..."
        composer install --no-dev --no-interaction 2>&1 | tail -5 || warning "Composer install had issues."
    fi

    info "Installing Node.js dependencies..."
    cd "$PANEL_DIR"
    if [ "$PKG_MANAGER" = "yarn" ]; then
        yarn install --no-progress 2>&1 | tail -10
    else
        npm install --no-progress --legacy-peer-deps 2>&1 | tail -10
    fi
    success "Dependencies installed."
    log "Dependencies installed via $PKG_MANAGER"
}

# --- Apply Critical Fixes ---
# These fix bugs that exist in both the original panel and theme source:
# 1. react-dom version mismatch (hot-loader 17.x vs react 16.x) causes React.lazy crash
# 2. react-hot-loader is unnecessary for production builds
apply_fixes() {
    info "Applying critical compatibility fixes..."

    # Fix 1: package.json — remove react-hot-loader, use standard react-dom
    cd "$PANEL_DIR"
    if command -v node &>/dev/null; then
        node -e "
            const fs = require('fs');
            const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
            // Remove hot-loader packages
            delete pkg.dependencies['react-hot-loader'];
            delete pkg.dependencies['@hot-loader/react-dom'];
            // Use standard react-dom matching react version
            pkg.dependencies['react-dom'] = '^16.14.0';
            fs.writeFileSync('package.json', JSON.stringify(pkg, null, 4) + '\n');
        "
        log "Fixed package.json: removed react-hot-loader, set react-dom to ^16.14.0"
    fi

    # Fix 2: webpack.config.js — remove react-hot-loader/patch from entry
    if [ -f "$PANEL_DIR/webpack.config.js" ]; then
        sed -i "s/entry: \['react-hot-loader\/patch', '\.\/resources\/scripts\/index\.tsx'\]/entry: ['.\/resources\/scripts\/index.tsx']/" "$PANEL_DIR/webpack.config.js"
        log "Fixed webpack.config.js: removed react-hot-loader/patch from entry"
    fi

    # Fix 3: babel.config.js — remove react-hot-loader/babel plugin
    if [ -f "$PANEL_DIR/babel.config.js" ]; then
        sed -i "/'react-hot-loader\/babel',/d" "$PANEL_DIR/babel.config.js"
        log "Fixed babel.config.js: removed react-hot-loader/babel plugin"
    fi

    # Fix 4: index.tsx — remove react-hot-loader setConfig
    if [ -f "$PANEL_DIR/resources/scripts/index.tsx" ]; then
        sed -i "/import { setConfig } from 'react-hot-loader';/d" "$PANEL_DIR/resources/scripts/index.tsx"
        sed -i "/setConfig({ reloadHooks: false });/d" "$PANEL_DIR/resources/scripts/index.tsx"
        log "Fixed index.tsx: removed react-hot-loader setConfig"
    fi

    # Fix 5: App.tsx — remove hot() wrapper
    if [ -f "$PANEL_DIR/resources/scripts/components/App.tsx" ]; then
        sed -i "/import { hot } from 'react-hot-loader\/root';/d" "$PANEL_DIR/resources/scripts/components/App.tsx"
        sed -i 's/export default hot(App);/export default App;/' "$PANEL_DIR/resources/scripts/components/App.tsx"
        log "Fixed App.tsx: removed hot() wrapper"
    fi

    success "Compatibility fixes applied."
}

# --- Copy Theme Files ---
copy_theme() {
    print_banner
    echo -e "  ${BOLD}Step 3: Copy Theme Files${RESET}"
    echo ""

    cd "$PANEL_DIR"
    SRC="$REPO_DIR"

    info "Copying theme files..."

    # PHP backend
    mkdir -p "$PANEL_DIR/resources/views/admin/miuujs"
    [ -d "$SRC/app/Http/Controllers/Admin/MiuuJS" ] && \
        cp -r "$SRC/app/Http/Controllers/Admin/MiuuJS" "$PANEL_DIR/app/Http/Controllers/Admin/"
    [ -f "$SRC/app/Http/Controllers/Base/LocaleController.php" ] && \
        cp "$SRC/app/Http/Controllers/Base/LocaleController.php" "$PANEL_DIR/app/Http/Controllers/Base/"
    [ -f "$SRC/app/Http/Requests/Base/LocaleRequest.php" ] && \
        cp "$SRC/app/Http/Requests/Base/LocaleRequest.php" "$PANEL_DIR/app/Http/Requests/Base/"
    [ -f "$SRC/app/Http/ViewComposers/AssetComposer.php" ] && \
        cp "$SRC/app/Http/ViewComposers/AssetComposer.php" "$PANEL_DIR/app/Http/ViewComposers/"

    # Config
    [ -f "$SRC/config/miuujs.php" ] && cp "$SRC/config/miuujs.php" "$PANEL_DIR/config/"

    # Routes (preserve existing plugin routes if any)
    MUSTIKAPAY_ROUTES=""
    if grep -q "MIUUJS_PLUGIN_MUSTIKAPAY_START" "$PANEL_DIR/routes/admin.php" 2>/dev/null; then
        MUSTIKAPAY_ROUTES=$(sed -n '/MIUUJS_PLUGIN_MUSTIKAPAY_START/,/MIUUJS_PLUGIN_MUSTIKAPAY_END/p' "$PANEL_DIR/routes/admin.php")
    fi
    [ -f "$SRC/routes/admin.php" ] && cp "$SRC/routes/admin.php" "$PANEL_DIR/routes/admin.php"
    if [ -n "$MUSTIKAPAY_ROUTES" ]; then
        echo "" >> "$PANEL_DIR/routes/admin.php"
        echo "$MUSTIKAPAY_ROUTES" >> "$PANEL_DIR/routes/admin.php"
    fi

    # Public assets
    [ -d "$SRC/public/miuujs" ] && cp -r "$SRC/public/miuujs" "$PANEL_DIR/public/"
    if [ -d "$SRC/public/themes/pterodactyl/css" ]; then
        mkdir -p "$PANEL_DIR/public/themes/pterodactyl/css"
        cp "$SRC/public/themes/pterodactyl/css/"*.css "$PANEL_DIR/public/themes/pterodactyl/css/" 2>/dev/null || true
    fi

    # Language files
    [ -d "$SRC/resources/lang/en/miuujs" ] && cp -r "$SRC/resources/lang/en/miuujs" "$PANEL_DIR/resources/lang/en/"

    # Views
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

    # React frontend (full replacement)
    if [ -d "$SRC/scripts" ]; then
        rsync -a "$SRC/scripts/" "$PANEL_DIR/resources/scripts/"
    fi

    success "All theme files copied."
    log "Theme files copied from $SRC"
}

# --- Build Frontend ---
build_frontend() {
    print_banner
    echo -e "  ${BOLD}Step 4: Build Frontend${RESET}"
    echo ""

    cd "$PANEL_DIR"
    BUILD_LOG="/tmp/miuujs-build-$(date +%s).log"

    info "Building frontend assets... (this may take 2-5 minutes)"
    info "Build log: $BUILD_LOG"
    echo ""

    if [ "$PKG_MANAGER" = "yarn" ]; then
        yarn run build:production 2>&1 | tee "$BUILD_LOG" | tail -20
    else
        npm run build:production 2>&1 | tee "$BUILD_LOG" | tail -20
    fi
    BUILD_EXIT=${PIPESTATUS[0]}

    if [ "$BUILD_EXIT" -eq 0 ]; then
        success "Frontend built successfully."
    else
        error "Frontend build failed! Check log: $BUILD_LOG"
        exit 1
    fi
    log "Frontend build completed (exit: $BUILD_EXIT)"
}

# --- Run Migrations ---
run_migrations() {
    info "Running database migrations..."
    cd "$PANEL_DIR"
    php artisan migrate --force --no-interaction 2>&1 || warning "Migration had issues (may be normal if tables exist)."
    success "Migrations complete."
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
    echo -e "  ${YELLOW}Note:${RESET} Clear your browser cache (Ctrl+Shift+R) if you see visual issues."
    echo ""
    log "Installation completed successfully."
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
        warning "plugins/ not found. Re-cloning repository..."
        rm -rf "$REPO_DIR"
        git clone https://github.com/miuujs/miuujs.git "$REPO_DIR" 2>/dev/null || {
            error "Failed to clone repo."
            return
        }
    fi

    info "Installing MustikaPay plugin..."

    # Copy plugin files
    [ -d "$SRC/plugins/app/Extensions" ] && cp -r "$SRC/plugins/app/Extensions" "$PANEL_DIR/app/"
    [ -d "$SRC/plugins/app/Http/Controllers/Admin" ] && \
        cp "$SRC/plugins/app/Http/Controllers/Admin/MustikaPayController.php" "$PANEL_DIR/app/Http/Controllers/Admin/" 2>/dev/null || true
    if [ -d "$SRC/plugins/app/Http/Controllers/Api/Client/Store" ]; then
        mkdir -p "$PANEL_DIR/app/Http/Controllers/Api/Client/Store"
        cp "$SRC/plugins/app/Http/Controllers/Api/Client/Store/StoreController.php" "$PANEL_DIR/app/Http/Controllers/Api/Client/Store/"
    fi
    [ -d "$SRC/plugins/app/Models" ] && cp "$SRC/plugins/app/Models/"*.php "$PANEL_DIR/app/Models/" 2>/dev/null || true
    [ -d "$SRC/plugins/database/migrations" ] && cp "$SRC/plugins/database/migrations/"*.php "$PANEL_DIR/database/migrations/" 2>/dev/null || true
    [ -f "$SRC/plugins/resources/views/admin/mustikapay.blade.php" ] && \
        cp "$SRC/plugins/resources/views/admin/mustikapay.blade.php" "$PANEL_DIR/resources/views/admin/"

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

    # API routes
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

    # Model modifications
    if ! grep -q "'balance'" "$PANEL_DIR/app/Models/User.php" 2>/dev/null; then
        sed -i $'/\'root_admin\',/a\\\t\t\'balance\',' "$PANEL_DIR/app/Models/User.php"
    fi
    if ! grep -q "'is_billed'" "$PANEL_DIR/app/Models/Server.php" 2>/dev/null; then
        sed -i $'/\'oom_disabled\' => \'boolean\',/a\\\t\t\'is_billed\' => \'boolean\',\\n\\t\t\'expires_at\' => \'datetime\',' "$PANEL_DIR/app/Models/Server.php"
    fi

    # Admin sidebar
    if ! grep -q "mustikapay" "$PANEL_DIR/resources/views/layouts/admin.blade.php" 2>/dev/null; then
        if ! grep -q "miuujs" "$PANEL_DIR/resources/views/layouts/admin.blade.php" 2>/dev/null; then
            [ -f "$SRC/resources/views/layouts/admin.blade.php" ] && \
                cp "$SRC/resources/views/layouts/admin.blade.php" "$PANEL_DIR/resources/views/layouts/admin.blade.php"
        fi
        MUSTIKAPAY_LINK='                                <li><a href="{{ route('"'"'admin.mustikapay'"'"') }}" data-toggle="tooltip" data-placement="bottom" title="MustikaPay Billing"><i class="fa fa-credit-card"></i></a></li>'
        sed -i "/route('admin.miuujs')/a\\${MUSTIKAPAY_LINK}" "$PANEL_DIR/resources/views/layouts/admin.blade.php"
    fi

    # Add Products nav links back (theme defaults without MustikaPay don't have them)
    mkdir -p "$PANEL_DIR/resources/scripts/components/dashboard"
    [ -f "$SRC/scripts/components/dashboard/StoreContainer.tsx" ] && \
        cp "$SRC/scripts/components/dashboard/StoreContainer.tsx" "$PANEL_DIR/resources/scripts/components/dashboard/"

    # Use Node.js to add Products links to frontend files
    cat > /tmp/miuujs_add_products.js << 'NODESCRIPT'
const fs = require('fs');
const panel = process.env.PANEL_DIR;

// NavigationBar.tsx
let navFile = panel + '/resources/scripts/components/NavigationBar.tsx';
if (fs.existsSync(navFile)) {
    let nav = fs.readFileSync(navFile, 'utf8');
    if (!nav.includes('ShoppingCartIcon')) {
        nav = nav.replace(
            "} from '@heroicons/react/outline';",
            ", ShoppingCartIcon } from '@heroicons/react/outline';"
        );
        nav = nav.replace(
            '{layout == 3 && <ClientDropdown />}',
            '{layout == 3 && <ClientDropdown />}\n                    <NavLink to={"/products"}><ShoppingCartIcon className={"w-5"} />Products</NavLink>'
        );
        nav = nav.replace(
            "<UserCircleIcon/> {t`account`}\n                        </NavLink>\n                    </div>",
            "<UserCircleIcon/> {t`account`}\n                        </NavLink>\n                        <NavLink to={'/products'} exact>\n                            <ShoppingCartIcon/> Products\n                        </NavLink>\n                    </div>"
        );
        fs.writeFileSync(navFile, nav);
        console.log('NavigationBar.tsx: Products link added');
    }
}

// SideBar.tsx
let sidebarFile = panel + '/resources/scripts/components/SideBar.tsx';
if (fs.existsSync(sidebarFile)) {
    let sidebar = fs.readFileSync(sidebarFile, 'utf8');
    if (!sidebar.includes('ShoppingCartIcon')) {
        sidebar = sidebar.replace(
            "} from '@heroicons/react/outline';",
            ", ShoppingCartIcon } from '@heroicons/react/outline';"
        );
        sidebar = sidebar.replace(
            "<UserCircleIcon/> {t('account')}\n                </NavLink>\n            </NavigationLinks>}",
            "<UserCircleIcon/> {t('account')}\n                </NavLink>\n                <NavLink to={'/products'} exact>\n                    <ShoppingCartIcon/> Products\n                </NavLink>\n            </NavigationLinks>}"
        );
        fs.writeFileSync(sidebarFile, sidebar);
        console.log('SideBar.tsx: Products link added');
    }
}

// DashboardRouter.tsx
let routerFile = panel + '/resources/scripts/routers/DashboardRouter.tsx';
if (fs.existsSync(routerFile)) {
    let router = fs.readFileSync(routerFile, 'utf8');
    if (!router.includes('StoreContainer')) {
        router = router.replace(
            "import DashboardContainer from",
            "import StoreContainer from '@/components/dashboard/StoreContainer';\nimport DashboardContainer from"
        );
        router = router.replace(
            "<DashboardContainer />\n                            </Route>\n                            {routes.account.map",
            "<DashboardContainer />\n                            </Route>\n                            <Route path={'/products'} exact>\n                                <StoreContainer />\n                            </Route>\n                            {routes.account.map"
        );
        fs.writeFileSync(routerFile, router);
        console.log('DashboardRouter.tsx: StoreContainer route added');
    }
}
NODESCRIPT
    PANEL_DIR="$PANEL_DIR" node /tmp/miuujs_add_products.js 2>/dev/null || warning "Failed to add Products links."
    rm -f /tmp/miuujs_add_products.js

    # Composer autoload
    if ! grep -q "MustikaPay" "$PANEL_DIR/composer.json" 2>/dev/null; then
        sed -i 's|"Pterodactyl\\\\": "app/",|"Pterodactyl\\\\": "app/",\n            "MustikaPay\\\\": "app/Extensions/Payment/MustikaPay/",|' "$PANEL_DIR/composer.json"
    fi
    composer dump-autoload 2>/dev/null || true

    # Migrations
    cd "$PANEL_DIR"
    php artisan tinker --execute='DB::table("migrations")->where("migration", "like", "%2026_05_11%")->delete();' 2>/dev/null || true
    run_migrations

    success "MustikaPay plugin installed."
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

    info "Removing plugin files..."
    rm -f "$PANEL_DIR/app/Http/Controllers/Admin/MustikaPayController.php"
    rm -rf "$PANEL_DIR/app/Http/Controllers/Api/Client/Store"
    rm -rf "$PANEL_DIR/app/Extensions/Payment/MustikaPay"
    rm -f "$PANEL_DIR/app/Models/MustikaPayProduct.php"
    rm -f "$PANEL_DIR/app/Models/MustikaPayTransaction.php"
    rm -f "$PANEL_DIR/resources/views/admin/mustikapay.blade.php"
    rm -f "$PANEL_DIR/resources/scripts/components/dashboard/StoreContainer.tsx"

    # Remove route markers
    sed -i '/MIUUJS_PLUGIN_MUSTIKAPAY_START/,/MIUUJS_PLUGIN_MUSTIKAPAY_END/d' "$PANEL_DIR/routes/admin.php" 2>/dev/null || true
    sed -i '/MIUUJS_PLUGIN_STORE_START/,/MIUUJS_PLUGIN_STORE_END/d' "$PANEL_DIR/routes/api-client.php" 2>/dev/null || true

    # Revert models
    sed -i "/'balance',/d" "$PANEL_DIR/app/Models/User.php" 2>/dev/null || true
    sed -i "/'is_billed' => 'boolean',/d" "$PANEL_DIR/app/Models/Server.php" 2>/dev/null || true
    sed -i "/'expires_at' => 'datetime',/d" "$PANEL_DIR/app/Models/Server.php" 2>/dev/null || true

    # Revert admin sidebar
    sed -i '/mustikapay/d' "$PANEL_DIR/resources/views/layouts/admin.blade.php" 2>/dev/null || true

    # Remove composer namespace
    sed -i '/"MustikaPay\\\\": "app\/Extensions\/Payment\/MustikaPay\/",/d' "$PANEL_DIR/composer.json" 2>/dev/null || true
    composer dump-autoload 2>/dev/null || true

    # Drop tables
    php artisan tinker --execute='Schema::dropIfExists("mustikapay_products");' 2>/dev/null || true
    php artisan tinker --execute='Schema::dropIfExists("mustikapay_transactions");' 2>/dev/null || true
    php artisan tinker --execute='DB::table("migrations")->where("migration", "like", "%2026_05_11%")->delete();' 2>/dev/null || true

    success "All plugins uninstalled."
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
        return
    fi
    info "Found backup: $BACKUP_DIR"
    echo ""

    # Restore from backup
    info "Restoring original panel files..."
    rsync -av --delete \
        --exclude='.env' \
        --exclude='storage' \
        --exclude='node_modules' \
        --exclude='vendor' \
        --exclude='bootstrap/cache' \
        "$BACKUP_DIR/" "$PANEL_DIR/" 2>&1 | tee /tmp/miuujs_rsync.log | tail -5
    RSYNC_EXIT=${PIPESTATUS[0]}
    DELETED_COUNT=$(grep -c "^deleting " /tmp/miuujs_rsync.log 2>/dev/null || echo 0)
    if [ "$DELETED_COUNT" -gt 0 ]; then
        success "Removed $DELETED_COUNT theme/plugin files."
    fi
    rm -f /tmp/miuujs_rsync.log
    if [ "$RSYNC_EXIT" -ne 0 ]; then
        error "rsync restore failed (exit $RSYNC_EXIT)."
        return
    fi
    success "Panel restored to original state."

    # Clean plugin database tables
    if php artisan tinker --execute='echo Schema::hasTable("mustikapay_products") ? "1" : "0";' 2>/dev/null | grep -q "1"; then
        info "Cleaning up plugin database tables..."
        php artisan tinker --execute='Schema::dropIfExists("mustikapay_products");' 2>/dev/null || true
        php artisan tinker --execute='Schema::dropIfExists("mustikapay_transactions");' 2>/dev/null || true
        php artisan tinker --execute='DB::table("migrations")->where("migration", "like", "%2026_05_11%")->delete();' 2>/dev/null || true
    fi

    # Rebuild frontend with original files
    ensure_node
    build_frontend

    # Clear caches
    info "Clearing caches..."
    php artisan view:clear 2>/dev/null || true
    php artisan config:clear 2>/dev/null || true
    php artisan cache:clear 2>/dev/null || true
    php artisan optimize:clear 2>/dev/null || true
    php artisan queue:restart 2>/dev/null || true
    composer dump-autoload 2>/dev/null || true

    success "Theme uninstalled. Panel restored to original Pterodactyl state."
    log "Theme uninstalled."
}

# --- Detection ---
is_theme_installed() {
    [ -f "$PANEL_DIR/config/miuujs.php" ] &&
    [ -d "$PANEL_DIR/app/Http/Controllers/Admin/MiuuJS" ] &&
    [ -d "$PANEL_DIR/public/miuujs" ] &&
    grep -q "miuujs" "$PANEL_DIR/resources/views/layouts/admin.blade.php" 2>/dev/null
}

is_mustikapay_installed() {
    [ -f "$PANEL_DIR/app/Http/Controllers/Admin/MustikaPayController.php" ] &&
    grep -q "MIUUJS_PLUGIN_MUSTIKAPAY_START" "$PANEL_DIR/routes/admin.php" 2>/dev/null
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
            ensure_node
            install_mustikapay
            build_frontend
            finalize
            ;;
        0)
            preflight
            ensure_node
            uninstall_plugins
            build_frontend
            info "Clearing caches..."
            php artisan view:clear 2>/dev/null || true
            php artisan config:clear 2>/dev/null || true
            php artisan cache:clear 2>/dev/null || true
            php artisan optimize:clear 2>/dev/null || true
            success "Done."
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
            ensure_node
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
            ensure_node
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
