<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Artisan;
use Symfony\Component\HttpFoundation\StreamedResponse;

class PluginsController extends BaseController
{
    private const TMP_DIR = '/tmp/miuujs-plugin-cache';
    private const STATUS_FILE = '/var/www/pterodactyl/storage/miuujs-plugins.json';

    private function getInstalledPlugins(): array
    {
        if (!file_exists(self::STATUS_FILE)) return [];
        $data = json_decode(file_get_contents(self::STATUS_FILE), true);
        return is_array($data) ? $data : [];
    }

    private function setInstalledPlugin(string $name, array $data): void
    {
        $installed = $this->getInstalledPlugins();
        $installed[$name] = array_merge($data, ['installed_at' => now()->toISOString()]);
        @mkdir(dirname(self::STATUS_FILE), 0755, true);
        file_put_contents(self::STATUS_FILE, json_encode($installed, JSON_PRETTY_PRINT));
    }

    private function removeInstalledPlugin(string $name): void
    {
        $installed = $this->getInstalledPlugins();
        unset($installed[$name]);
        file_put_contents(self::STATUS_FILE, json_encode($installed, JSON_PRETTY_PRINT));
    }

    public function index(): View
    {
        $installed = $this->getInstalledPlugins();

        $plugins = [];
        foreach ($installed as $id => $info) {
            $plugins[] = [
                'id' => $id,
                'name' => $info['name'] ?? ucfirst($id),
                'icon' => $info['icon'] ?? 'fa-puzzle-piece',
                'desc' => $info['description'] ?? 'A plugin for the MiuuJS theme.',
                'features' => $info['features'] ?? [],
                'installed_at' => $info['installed_at'] ?? null,
                'version' => $info['version'] ?? '1.0.0',
            ];
        }

        return view('admin.plugins.index', ['plugins' => $plugins]);
    }

    public function installFromUrl(): StreamedResponse
    {
        $url = request()->input('url');
        if (!$url) {
            return $this->streamError('No URL provided.');
        }

        $panelDir = base_path();
        $pluginSrc = '/tmp/miuujs-plugin-install';

        return $this->stream(function ($emit) use ($url, $panelDir, $pluginSrc) {
            try {
                $emit('[1/5] Creating backup...');
                $backupDir = $panelDir . '-backup-' . date('Ymd');
                if (!is_dir($backupDir)) {
                    $backupDir = $panelDir . '-backup-' . date('Ymd-His');
                    $emit('  Running: cp -a ' . $panelDir . ' ' . $backupDir);
                    shell_exec('cp -a ' . escapeshellarg($panelDir) . ' ' . escapeshellarg($backupDir) . ' 2>&1');
                }
                $emit('  Backup created: ' . basename($backupDir));

                $emit('[2/5] Downloading plugin...');
                shell_exec('rm -rf ' . escapeshellarg($pluginSrc) . ' 2>/dev/null');

                $logs = [];
                $pluginName = $this->downloadPlugin($url, $pluginSrc, $logs, $emit);
                if (!$pluginName) {
                    $emit('ERROR: Failed to download or extract plugin.');
                    return;
                }
                $emit('  Plugin extracted: ' . $pluginName);

                $src = $pluginSrc . '/' . $pluginName;
                $manifest = $this->readManifest($src);

                $emit('[3/5] Installing plugin files...');

                $emit('  Copying app/ files...');
                $this->copyDir($src . '/app', $panelDir . '/app');
                $emit('  Copying database migrations...');
                $this->copyDir($src . '/database/migrations', $panelDir . '/database/migrations');
                $emit('  Copying view templates...');
                $this->copyDir($src . '/resources/views', $panelDir . '/resources/views');

                if (is_dir($src . '/resources/scripts')) {
                    $pluginsDir = $panelDir . '/resources/scripts/plugins/' . $pluginName;
                    if (is_dir($pluginsDir)) {
                        $emit('  Removing old plugin frontend files...');
                        shell_exec('rm -rf ' . escapeshellarg($pluginsDir) . ' 2>&1');
                    }
                    $emit('  Copying frontend files to plugins/' . $pluginName . '/...');
                    $this->copyDir($src . '/resources/scripts', $pluginsDir);
                }

                $routesDir = $panelDir . '/routes/plugins';
                @mkdir($routesDir, 0755, true);
                if (is_dir($src . '/routes')) {
                    $emit('  Copying route files to routes/plugins/...');
                    foreach (scandir($src . '/routes') as $file) {
                        if ($file === '.' || $file === '..') continue;
                        copy($src . '/routes/' . $file, $routesDir . '/' . $pluginName . '_' . $file);
                        $emit('    -> ' . $pluginName . '_' . $file);
                    }
                }

                $emit('  Setting file permissions...');
                shell_exec('chown -R www-data:www-data ' . escapeshellarg($panelDir . '/routes/plugins') . ' ' . escapeshellarg($panelDir . '/resources/scripts/plugins') . ' 2>/dev/null');
                $emit('  All files copied successfully.');

                $emit('[4/5] Running database migrations...');
                $migrateOutput = '';
                Artisan::call('migrate', ['--force' => true]);
                $migrateOutput = Artisan::output();
                if ($migrateOutput) {
                    foreach (explode("\n", $migrateOutput) as $line) {
                        if (trim($line)) $emit('  ' . trim($line));
                    }
                }
                $emit('  Migrations complete.');

                $emit('[5/5] Rebuilding frontend...');
                $emit('  Running: npx webpack --mode production');
                $webpackOutput = shell_exec('cd ' . escapeshellarg($panelDir) . ' && npx webpack --mode production 2>&1');
                if ($webpackOutput) {
                    foreach (explode("\n", $webpackOutput) as $line) {
                        if (trim($line)) $emit('  ' . trim($line));
                    }
                }
                $emit('  Frontend rebuilt.');

                $emit('Clearing caches...');
                Artisan::call('config:clear');
                $emit('  config:clear');
                Artisan::call('cache:clear');
                $emit('  cache:clear');
                Artisan::call('view:clear');
                $emit('  view:clear');
                Artisan::call('route:clear');
                $emit('  route:clear');
                Artisan::call('queue:restart');
                $emit('  queue:restart');

                $emit('Setting final permissions...');
                shell_exec('chown -R www-data:www-data ' . escapeshellarg($panelDir . '/storage') . ' ' . escapeshellarg($panelDir . '/bootstrap/cache') . ' ' . escapeshellarg($panelDir . '/public/assets') . ' ' . escapeshellarg($panelDir . '/routes/plugins') . ' ' . escapeshellarg($panelDir . '/resources/scripts/plugins') . ' 2>/dev/null');

                $pluginData = [
                    'version' => $manifest['version'] ?? '1.0.0',
                    'source' => $url,
                    'name' => $manifest['name'] ?? ucfirst($pluginName),
                    'icon' => $manifest['icon'] ?? 'fa-puzzle-piece',
                    'description' => $manifest['description'] ?? '',
                    'features' => $manifest['features'] ?? [],
                ];
                if (isset($manifest['frontend']['adminLinks'])) {
                    $pluginData['admin_links'] = $manifest['frontend']['adminLinks'];
                }

                $this->setInstalledPlugin($pluginName, $pluginData);

                shell_exec('rm -rf ' . escapeshellarg($pluginSrc) . ' 2>/dev/null');

                $emit('');
                $emit('Plugin "' . ($manifest['name'] ?? ucfirst($pluginName)) . '" installed successfully.');
                $emit('__DONE__');
            } catch (\Exception $e) {
                $emit('');
                $emit('Installation failed: ' . $e->getMessage());
                $emit('__ERROR__');
                shell_exec('rm -rf ' . escapeshellarg($pluginSrc) . ' 2>/dev/null');
            }
        });
    }

    public function uninstall(string $name): StreamedResponse
    {
        $installed = $this->getInstalledPlugins();
        if (!isset($installed[$name])) {
            return $this->streamError('Plugin "' . $name . '" is not installed.');
        }

        $panelDir = base_path();

        return $this->stream(function ($emit) use ($name, $panelDir) {
            try {
                $emit('[1/4] Removing plugin files...');

                $pluginsDir = $panelDir . '/resources/scripts/plugins/' . $name;
                if (is_dir($pluginsDir)) {
                    $emit('  Removing: ' . $pluginsDir);
                    shell_exec('rm -rf ' . escapeshellarg($pluginsDir) . ' 2>&1');
                    $emit('  Frontend plugin files removed.');
                } else {
                    $emit('  No frontend files found to remove.');
                }

                $routesDir = $panelDir . '/routes/plugins';
                if (is_dir($routesDir)) {
                    $removed = [];
                    foreach (scandir($routesDir) as $file) {
                        if ($file === '.' || $file === '..') continue;
                        if (str_starts_with($file, $name . '_')) {
                            unlink($routesDir . '/' . $file);
                            $removed[] = $file;
                        }
                    }
                    if (count($removed) > 0) {
                        $emit('  Route files removed: ' . implode(', ', $removed));
                    } else {
                        $emit('  No route files found to remove.');
                    }
                }

                $emit('[2/4] Clearing Laravel caches...');
                Artisan::call('config:clear');
                $emit('  config:clear');
                Artisan::call('cache:clear');
                $emit('  cache:clear');
                Artisan::call('view:clear');
                $emit('  view:clear');
                Artisan::call('route:clear');
                $emit('  route:clear');

                $emit('[3/4] Rebuilding frontend...');
                $emit('  Running: npx webpack --mode production');
                $webpackOutput = shell_exec('cd ' . escapeshellarg($panelDir) . ' && npx webpack --mode production 2>&1');
                if ($webpackOutput) {
                    foreach (explode("\n", $webpackOutput) as $line) {
                        if (trim($line)) $emit('  ' . trim($line));
                    }
                }
                $emit('  Frontend rebuilt.');

                $emit('[4/4] Finalizing...');
                $this->removeInstalledPlugin($name);
                shell_exec('chown -R www-data:www-data ' . escapeshellarg($panelDir . '/storage') . ' ' . escapeshellarg($panelDir . '/bootstrap/cache') . ' 2>/dev/null');
                $emit('  Permissions updated.');

                $emit('');
                $emit('Plugin "' . $name . '" uninstalled successfully.');
                $emit('__DONE__');
            } catch (\Exception $e) {
                $emit('');
                $emit('Uninstall failed: ' . $e->getMessage());
                $emit('__ERROR__');
            }
        });
    }

    private function stream(callable $callback): StreamedResponse
    {
        $response = new StreamedResponse(function () use ($callback) {
            $emit = function (string $line) {
                echo "data: " . json_encode($line) . "\n\n";
                ob_flush();
                flush();
            };
            $callback($emit);
        });

        $response->headers->set('Content-Type', 'text/event-stream');
        $response->headers->set('Cache-Control', 'no-cache');
        $response->headers->set('X-Accel-Buffering', 'no');

        return $response;
    }

    private function streamError(string $message): StreamedResponse
    {
        return $this->stream(function ($emit) use ($message) {
            $emit('ERROR: ' . $message);
            $emit('__ERROR__');
        });
    }

    private function readManifest(string $pluginDir): array
    {
        $manifestFile = $pluginDir . '/manifest.json';
        if (file_exists($manifestFile)) {
            return json_decode(file_get_contents($manifestFile), true) ?? [];
        }
        return [];
    }

    private function downloadPlugin(string $url, string $dest, array &$logs, callable $emit): ?string
    {
        mkdir($dest, 0755, true);

        if (preg_match('#github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)#', $url, $m)) {
            $owner = $m[1];
            $repo = $m[2];
            $branch = $m[3];
            $path = $m[4];
            $tarUrl = "https://github.com/$owner/$repo/archive/refs/heads/$branch.tar.gz";
            $tmpFile = $dest . '/plugin.tar.gz';

            $emit('  Downloading from: ' . $tarUrl);
            shell_exec('curl -sL ' . escapeshellarg($tarUrl) . ' -o ' . escapeshellarg($tmpFile) . ' 2>&1');
            if (!file_exists($tmpFile) || filesize($tmpFile) < 100) {
                $emit('  Failed to download tarball.');
                return null;
            }
            $emit('  Download complete (' . round(filesize($tmpFile) / 1024, 1) . ' KB)');

            $emit('  Extracting archive...');
            shell_exec('tar xzf ' . escapeshellarg($tmpFile) . ' -C ' . escapeshellarg($dest) . ' 2>&1');
            unlink($tmpFile);

            $extracted = glob($dest . '/*');
            if (empty($extracted)) return null;
            $extractedDir = $extracted[0];

            $pluginFolder = basename($path);
            if (is_dir($extractedDir . '/' . $pluginFolder)) {
                return $pluginFolder;
            }

            foreach (scandir($extractedDir) as $item) {
                if ($item === '.' || $item === '..') continue;
                $fullPath = $extractedDir . '/' . $item;
                if (is_dir($fullPath) && file_exists($fullPath . '/manifest.json')) {
                    return $item;
                }
            }

            $parts = explode('/', $path);
            foreach ($parts as $part) {
                if (is_dir($extractedDir . '/' . $part) && file_exists($extractedDir . '/' . $part . '/manifest.json')) {
                    return $part;
                }
            }

            return basename($path);
        }

        if (preg_match('/\.(tar\.gz|tgz|zip)$/i', $url)) {
            $tmpFile = $dest . '/plugin.' . (str_ends_with($url, '.zip') ? 'zip' : 'tar.gz');
            $emit('  Downloading: ' . $url);
            shell_exec('curl -sL ' . escapeshellarg($url) . ' -o ' . escapeshellarg($tmpFile) . ' 2>&1');

            if (str_ends_with($url, '.zip')) {
                $emit('  Extracting ZIP...');
                shell_exec('unzip -o ' . escapeshellarg($tmpFile) . ' -d ' . escapeshellarg($dest) . ' 2>&1');
            } else {
                $emit('  Extracting tarball...');
                shell_exec('tar xzf ' . escapeshellarg($tmpFile) . ' -C ' . escapeshellarg($dest) . ' 2>&1');
            }
            unlink($tmpFile);

            $extracted = glob($dest . '/*');
            if (empty($extracted)) return null;
            $extractedDir = $extracted[0];

            foreach (scandir($extractedDir) as $item) {
                if ($item === '.' || $item === '..') continue;
                if (is_dir($extractedDir . '/' . $item) && file_exists($extractedDir . '/' . $item . '/manifest.json')) {
                    return $item;
                }
            }
            return basename($extractedDir);
        }

        if (preg_match('#raw\.githubusercontent\.com#', $url)) {
            return null;
        }

        $emit('  Unsupported URL format.');
        return null;
    }

    private function copyDir(string $src, string $dest): void
    {
        if (!is_dir($src)) return;
        $dest = rtrim($dest, '/');
        if (!is_dir($dest)) mkdir($dest, 0755, true);

        $iterator = new \RecursiveIteratorIterator(
            new \RecursiveDirectoryIterator($src, \RecursiveDirectoryIterator::SKIP_DOTS),
            \RecursiveIteratorIterator::SELF_FIRST
        );

        foreach ($iterator as $item) {
            $destPath = $dest . '/' . $iterator->getSubPathName();
            if ($item->isDir()) {
                if (!is_dir($destPath)) mkdir($destPath, 0755, true);
            } else {
                copy($item->getPathname(), $destPath);
            }
        }
    }
}
