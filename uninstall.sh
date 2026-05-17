#!/bin/bash
set -e

######################################################################################
#                                                                                    #
#  MiuuJS Theme Uninstaller                                                          #
#                                                                                    #
#  Restores Pterodactyl panel to original state using backup created during install  #
#                                                                                    #
#  Copyright (C) 2026 MiuuJS                                                         #
#  https://github.com/miuujs/miuujs                                                  #
#                                                                                    #
######################################################################################

export MIUUJS_VERSION="1.1.0"

RESET="\e[0m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
MAGENTA="\e[35m"
BOLD="\e[1m"

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
    echo -e "  ${BOLD}MiuuJS Theme Uninstaller v${MIUUJS_VERSION}${RESET}"
    echo ""
}

# ──────────────────────────────────────────────────────────────────────────────────
# Pre-flight
# ──────────────────────────────────────────────────────────────────────────────────
preflight() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (sudo)."
        exit 1
    fi

    for cmd in curl tar rsync; do
        if ! [ -x "$(command -v $cmd)" ]; then
            apt-get install "$cmd" -y 2>/dev/null || { error "Failed to install $cmd."; exit 1; }
        fi
    done

    PANEL_DIR=""
    for dir in /var/www/pterodactyl /srv/panel; do
        if [ -d "$dir" ] && [ -f "$dir/artisan" ]; then
            PANEL_DIR="$dir"
            break
        fi
    done

    if [ -z "$PANEL_DIR" ]; then
        error "Pterodactyl panel not found."
        input "Enter panel directory manually: "
        read -r PANEL_DIR
        if [ ! -f "$PANEL_DIR/artisan" ]; then
            error "No Pterodactyl panel found at $PANEL_DIR"
            exit 1
        fi
    fi

    info "Panel detected at: ${BOLD}$PANEL_DIR${RESET}"
}

# ──────────────────────────────────────────────────────────────────────────────────
# Node.js >= 22
# ──────────────────────────────────────────────────────────────────────────────────
ensure_node() {
    if ! [ -x "$(command -v node)" ]; then
        info "Node.js not found. Installing Node.js 22..."
        curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
        apt install nodejs -y
        hash -r
    fi

    NODE_MAJOR=$(node -v | sed 's/v//' | cut -d'.' -f1)
    if [ "$NODE_MAJOR" -lt 22 ]; then
        info "Upgrading Node.js to v22..."
        curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
        apt install nodejs -y
        update-alternatives --remove node /usr/local/bin/node 2>/dev/null || true
        update-alternatives --install /usr/local/bin/node node /usr/bin/node 100 2>/dev/null || true
        hash -r
    fi

    if [ -x "$(command -v yarn)" ]; then
        PKG_MANAGER="yarn"
    elif [ -x "$(command -v npm)" ]; then
        PKG_MANAGER="npm"
    else
        error "Neither yarn nor npm found."
        exit 1
    fi
    info "Using $PKG_MANAGER."
}

# ──────────────────────────────────────────────────────────────────────────────────
# Uninstall
# ──────────────────────────────────────────────────────────────────────────────────
uninstall() {
    print_banner
    echo -e "  ${BOLD}Uninstall MiuuJS Theme${RESET}"
    echo ""

    warning "This will restore your panel to its original Pterodactyl state."
    warning "All theme modifications will be removed."
    echo ""
    input "Are you sure? (y/N): "
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ [Yy] ]]; then
        info "Cancelled."
        exit 0
    fi

    cd "$PANEL_DIR"

    # Find backup
    BACKUP_DIR=$(ls -dt "${PANEL_DIR}-backup-"* 2>/dev/null | head -1)
    if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
        error "No backup found at ${PANEL_DIR}-backup-*"
        info "The backup is created during theme installation. Without it, uninstall cannot proceed."
        exit 1
    fi
    info "Found backup: ${BOLD}$BACKUP_DIR${RESET}"
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
        success "Removed $DELETED_COUNT theme files."
    fi
    rm -f /tmp/miuujs_rsync.log
    if [ "$RSYNC_EXIT" -ne 0 ]; then
        error "rsync restore failed (exit $RSYNC_EXIT)."
        exit 1
    fi
    success "Panel restored to original state."
    echo ""

    # Clean leftover theme files that rsync excludes may miss
    info "Cleaning up leftover files..."
    rm -f "$PANEL_DIR/config/miuujs.php"
    rm -rf "$PANEL_DIR/app/Http/Controllers/Admin/MiuuJS"
    rm -rf "$PANEL_DIR/public/miuujs"
    rm -rf "$PANEL_DIR/resources/lang/en/miuujs"
    rm -rf "$PANEL_DIR/resources/views/admin/miuujs"
    rm -f "$PANEL_DIR/resources/views/layouts/admin.blade.php"
    rm -f "$PANEL_DIR/resources/views/templates/auth/core.blade.php"
    rm -f "$PANEL_DIR/resources/views/templates/base/core.blade.php"
    rm -f "$PANEL_DIR/resources/views/templates/wrapper.blade.php"
    rm -f "$PANEL_DIR/tailwind.config.js"
    rm -f "$PANEL_DIR/babel.config.js"
    success "Leftover files cleaned."
    echo ""

    # Rebuild frontend
    ensure_node
    cd "$PANEL_DIR"

    info "Rebuilding frontend..."
    BUILD_LOG="/tmp/miuujs-uninstall-build-$(date +%s).log"
    if [ "$PKG_MANAGER" = "yarn" ]; then
        yarn run build:production 2>&1 | tee "$BUILD_LOG" | tail -10
    else
        npm run build:production 2>&1 | tee "$BUILD_LOG" | tail -10
    fi
    BUILD_EXIT=${PIPESTATUS[0]}
    if [ "$BUILD_EXIT" -eq 0 ]; then
        success "Frontend rebuilt successfully."
    else
        warning "Frontend build had issues. Check: $BUILD_LOG"
    fi
    echo ""

    # Clear caches
    info "Clearing caches..."
    php artisan view:clear 2>/dev/null || true
    php artisan config:clear 2>/dev/null || true
    php artisan cache:clear 2>/dev/null || true
    php artisan optimize:clear 2>/dev/null || true
    php artisan queue:restart 2>/dev/null || true
    composer dump-autoload 2>/dev/null || true
    success "Caches cleared."
    echo ""

    print_banner
    echo -e "  ${BOLD}==================== UNINSTALL COMPLETE ====================${RESET}"
    echo ""
    echo -e "  ${GREEN}MiuuJS theme has been removed.${RESET}"
    echo ""
    echo -e "  ${YELLOW}Note:${RESET} Clear your browser cache (Ctrl+Shift+R) to see changes."
    echo -e "  ${DIM}Backup still available at: $BACKUP_DIR${RESET}"
    echo ""
}

# ──────────────────────────────────────────────────────────────────────────────────
# Run
# ──────────────────────────────────────────────────────────────────────────────────
preflight
uninstall
