#!/bin/bash

PTERO_DIR="/var/www/pterodactyl"
MOD_DIR="/root/pteromod"

echo "Starting Pterodactyl Mod Installation..."

# 1. Copy Files
cp -rv $MOD_DIR/app/* $PTERO_DIR/app/
cp -rv $MOD_DIR/database/migrations/* $PTERO_DIR/database/migrations/
cp -rv $MOD_DIR/resources/* $PTERO_DIR/resources/

# 2. Add Routes
echo "Adding routes..."
if ! grep -q "MIUUJS_PLUGIN_MUSTIKAPAY_START" $PTERO_DIR/routes/admin.php 2>/dev/null; then
    cat >> $PTERO_DIR/routes/admin.php << 'MIUUJS_ROUTES'

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

if ! grep -q "MIUUJS_PLUGIN_STORE_START" $PTERO_DIR/routes/api-client.php 2>/dev/null; then
    cat >> $PTERO_DIR/routes/api-client.php << 'MIUUJS_ROUTES'

/* MIUUJS_PLUGIN_STORE_START */
/* Store Routes */
Route::prefix('/store')->group(function () {
    Route::get('/', [Client\Store\StoreController::class, 'index']);
    Route::post('/pay', [Client\Store\StoreController::class, 'pay']);
    Route::post('/buy', [Client\Store\StoreController::class, 'buy']);
    Route::post('/webhook', [Client\Store\StoreController::class, 'webhook']);
});
/* MIUUJS_PLUGIN_STORE_END */
MIUUJS_ROUTES
fi

# 3. Modify Models
echo "Modifying Models..."
sed -i "/'root_admin',/a \        'balance'," $PTERO_DIR/app/Models/User.php

if ! grep -q "is_billed" $PTERO_DIR/app/Models/Server.php 2>/dev/null; then
    sed -i "/'oom_disabled' => 'boolean',/a \        'is_billed' => 'boolean'," $PTERO_DIR/app/Models/Server.php
    sed -i "/'oom_disabled' => 'boolean',/a \        'expires_at' => 'datetime'," $PTERO_DIR/app/Models/Server.php
fi

# 4. Composer
if grep -q "Pterodactyl" $PTERO_DIR/composer.json 2>/dev/null && ! grep -q "MustikaPay" $PTERO_DIR/composer.json 2>/dev/null; then
    sed -i 's|"Pterodactyl\\\\": "app/",|"Pterodactyl\\\\": "app/",\n            "MustikaPay\\\\": "app/Extensions/Payment/MustikaPay/",|' $PTERO_DIR/composer.json
fi
cd $PTERO_DIR && composer dump-autoload 2>/dev/null

# 5. Database
chown -R www-data:www-data $PTERO_DIR/*
cd $PTERO_DIR
php artisan migrate --force

# 6. Build Frontend
echo "Building frontend... this may take a while."
npm install
npm run build

echo "Installation Complete!"
