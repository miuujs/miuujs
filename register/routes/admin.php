<?php

use Illuminate\Support\Facades\Route;
use Pterodactyl\Http\Controllers\Admin;

Route::group(['prefix' => 'register'], function () {
    Route::get('/', [Admin\RegisterSettingsController::class, 'index'])->name('admin.register');
    Route::post('/', [Admin\RegisterSettingsController::class, 'update'])->name('admin.register.update');
});
