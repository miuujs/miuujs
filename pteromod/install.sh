#!/bin/bash

# Configuration
PTERO_DIR="/var/www/pterodactyl"
MOD_DIR="/root/pteromod"

echo "Starting Pterodactyl Mod Installation..."

# 1. Copy Files
cp -rv $MOD_DIR/app/* $PTERO_DIR/app/
cp -rv $MOD_DIR/database/migrations/* $PTERO_DIR/database/migrations/
cp -rv $MOD_DIR/resources/* $PTERO_DIR/resources/

# 2. Add Routes
echo "Adding routes..."
if ! grep -q "MustikaPay" $PTERO_DIR/routes/admin.php; then
    cat << 'ROUTEE' >> $PTERO_DIR/routes/admin.php

/* MustikaPay Billing Routes */
Route::group(['prefix' => 'mustikapay'], function () {
    Route::get('/', [Admin\MustikaPayController::class, 'index'])->name('admin.mustikapay');
    Route::post('/', [Admin\MustikaPayController::class, 'update'])->name('admin.mustikapay.update');
    Route::post('/product', [Admin\MustikaPayController::class, 'addProduct'])->name('admin.mustikapay.product.add');
    Route::delete('/product/{id}', [Admin\MustikaPayController::class, 'deleteProduct'])->name('admin.mustikapay.product.delete');
});
ROUTEE
fi

if ! grep -q "/store" $PTERO_DIR/routes/api-client.php; then
    cat << 'ROUTEE' >> $PTERO_DIR/routes/api-client.php

/* Store Routes */
Route::prefix('/store')->group(function () {
    Route::get('/', [Client\Store\StoreController::class, 'index']);
    Route::post('/pay', [Client\Store\StoreController::class, 'pay']);
    Route::post('/buy', [Client\Store\StoreController::class, 'buy']);
});
ROUTEE
fi

# 3. Modify Models
echo "Modifying Models..."
# Add balance to User model fillable and attributes
sed -i "/'root_admin',/a \        'balance'," $PTERO_DIR/app/Models/User.php

# Add billing to Server model casts
if ! grep -q "is_billed" $PTERO_DIR/app/Models/Server.php; then
    sed -i "/'oom_disabled' => 'boolean',/a \        'is_billed' => 'boolean'," $PTERO_DIR/app/Models/Server.php
    sed -i "/'oom_disabled' => 'boolean',/a \        'expires_at' => 'datetime'," $PTERO_DIR/app/Models/Server.php
fi

# 4. Permissions & Database
chown -R www-data:www-data $PTERO_DIR/*
cd $PTERO_DIR
php artisan migrate --force

# 5. Build Frontend (Optional but recommended)
echo "Building frontend... this may take a while."
npm install
npm run build

echo "Installation Complete!"
