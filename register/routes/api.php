<?php

use Illuminate\Support\Facades\Route;
use Pterodactyl\Http\Controllers\Auth;

Route::get('/register', function() {
    return view('auth.register');
})->name('auth.register.page');

Route::post('/register', [Auth\RegisterController::class, 'register'])->name('auth.register');
