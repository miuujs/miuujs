<?php

use Illuminate\Support\Facades\Route;
use Pterodactyl\Http\Controllers\Api\Client;

Route::prefix('/products')->group(function () {
    Route::get('/', [Client\Store\StoreController::class, 'index']);
    Route::post('/pay', [Client\Store\StoreController::class, 'pay']);
    Route::post('/buy', [Client\Store\StoreController::class, 'buy']);
    Route::post('/webhook', [Client\Store\StoreController::class, 'webhook']);
});
