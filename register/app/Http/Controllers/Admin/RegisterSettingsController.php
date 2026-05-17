<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class RegisterSettingsController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected SettingsRepositoryInterface $settings
    ) {}

    public function index()
    {
        return view('admin.register', [
            'enabled' => $this->settings->get('pterodactyl:auth:register:enabled', '0'),
            'require_email_verification' => $this->settings->get('pterodactyl:auth:register:require_email_verification', '0'),
        ]);
    }

    public function update(Request $request)
    {
        $enabled = $request->input('enabled', '0');
        $this->settings->set('pterodactyl:auth:register:enabled', $enabled);
        $this->settings->set('miuujs::registrationEnabled', $enabled === '1' ? '1' : '0');
        $this->settings->set('pterodactyl:auth:register:require_email_verification', $request->input('require_email_verification', '0'));

        $this->alert->success('Registration settings updated.')->flash();
        return redirect()->route('admin.register');
    }
}
