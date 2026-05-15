<?php

namespace Pterodactyl\Http\Controllers\Admin\MiuuJS;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class MiuuJSController extends Controller
{
    public function __construct(private SettingsRepositoryInterface $settings)
    {
    }

    public function index(): View
    {
        return view('admin.miuujs.index', [
            'config' => config('miuujs'),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        foreach ($request->except(['_token', '_method']) as $key => $value) {
            $this->settings->set('miuujs::' . $key, $value);
        }

        return redirect()->route('admin.miuujs')->with('success', 'Settings updated successfully.');
    }
}