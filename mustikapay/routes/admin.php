<?php

use Illuminate\Support\Facades\Route;
use Pterodactyl\Http\Controllers\Admin;

Route::group(['prefix' => 'mustikapay'], function () {
    Route::get('/', [Admin\MustikaPayController::class, 'index'])->name('admin.mustikapay');
    Route::post('/', [Admin\MustikaPayController::class, 'update'])->name('admin.mustikapay.update');
    Route::post('/product', [Admin\MustikaPayController::class, 'addProduct'])->name('admin.mustikapay.product.add');
    Route::delete('/product/{id}', [Admin\MustikaPayController::class, 'deleteProduct'])->name('admin.mustikapay.product.delete');
});
