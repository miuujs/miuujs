<?php

namespace Pterodactyl\Http\Controllers\Admin\MiuuJS;

use Illuminate\View\View;
use Pterodactyl\Http\Controllers\Controller;

class MiuuJSController extends Controller
{
    public function index(): View
    {
        return view('admin.miuujs.index', [
            'config' => config('miuujs'),
        ]);
    }
}