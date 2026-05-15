<?php

namespace Pterodactyl\Http\ViewComposers;

use Illuminate\View\View;
use Pterodactyl\Services\Helpers\AssetHashService;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class AssetComposer
{
    public function __construct(
        private AssetHashService $assetHashService,
        private SettingsRepositoryInterface $settings,
    )
    {
    }

    public function compose(View $view): void
    {
        $dbSettings = [];
        $prefix = 'miuujs::';
        $allSettings = $this->settings->all();
        foreach ($allSettings as $key => $value) {
            if (str_starts_with($key, $prefix)) {
                $dbSettings[substr($key, strlen($prefix))] = $value;
            }
        }

        $view->with('asset', $this->assetHashService);
        $view->with('siteConfiguration', [
            'name' => config('app.name') ?? 'Pterodactyl',
            'locale' => config('app.locale') ?? 'en',
            'miuujs' => array_merge(config('miuujs', []), $dbSettings),
            'recaptcha' => [
                'enabled' => config('recaptcha.enabled', false),
                'siteKey' => config('recaptcha.website_key') ?? '',
            ],
        ]);
    }
}
