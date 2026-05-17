# MiuuJS Plugin Development Guide

This document describes the plugin architecture for the MiuuJS Pterodactyl theme and provides instructions for creating custom plugins.

## Architecture Overview

The MiuuJS plugin system uses a zero-injection architecture. Plugins self-register with the theme's plugin registry at runtime. The theme provides extension points that plugins can hook into without modifying any theme source files.

### How It Works

1. The theme exposes a plugin registry at `scripts/plugins/index.ts`
2. Each plugin provides a `register.tsx` file that calls `registerPlugin()` with its configuration
3. The theme entry point (`scripts/index.tsx`) auto-loads all `register.tsx` files via `require.context`
4. Plugin routes, navigation items, and admin links are rendered dynamically by the theme

### Directory Structure

A plugin is installed to the following locations:

```
/var/www/pterodactyl/
├── app/                                    # PHP backend (controllers, models, etc.)
├── database/migrations/                    # Database migrations
├── resources/
│   ├── views/                              # Blade templates
│   └── scripts/plugins/{plugin_name}/      # Frontend files
│       ├── register.tsx                    # Plugin registration (required)
│       ├── components/                     # React components
│       └── ...
├── routes/plugins/                         # Laravel route files
│   ├── {plugin_name}_admin.php             # Admin routes
│   └── {plugin_name}_api.php               # API routes
└── storage/miuujs-plugins.json             # Plugin registry (auto-generated)
```

## Creating a Plugin

### Step 1: Create the Plugin Directory

Create a directory for your plugin with the following structure:

```
myplugin/
├── app/
│   └── Http/Controllers/
│       └── Admin/
│           └── MyPluginController.php
├── database/
│   └── migrations/
│       └── 2026_01_01_000000_create_myplugin_table.php
├── resources/
│   ├── views/
│   │   └── admin/
│   │       └── myplugin.blade.php
│   └── scripts/
│       ├── register.tsx
│       └── components/
│           └── MyComponent.tsx
├── routes/
│   ├── admin.php
│   └── api.php
└── manifest.json
```

### Step 2: Create manifest.json

The manifest file contains plugin metadata and frontend configuration:

```json
{
    "id": "myplugin",
    "name": "My Plugin",
    "version": "1.0.0",
    "description": "Description of what this plugin does.",
    "icon": "fa-cog",
    "features": [
        "Feature one",
        "Feature two"
    ],
    "frontend": {
        "routes": [
            {
                "path": "/my-page",
                "component": "MyComponent",
                "importPath": "./components/MyComponent"
            }
        ],
        "nav": [
            {
                "label": "My Page",
                "icon": "ShoppingCartIcon",
                "path": "/my-page"
            }
        ],
        "adminLinks": [
            {
                "route": "admin.myplugin",
                "title": "My Plugin",
                "icon": "fa-cog"
            }
        ]
    }
}
```

#### Manifest Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique plugin identifier (lowercase, no spaces) |
| name | string | Yes | Display name |
| version | string | Yes | Semantic version |
| description | string | Yes | Short description |
| icon | string | Yes | FontAwesome icon class (e.g., `fa-cog`, `fa-credit-card`) |
| features | string[] | No | List of features for display in admin panel |
| frontend.routes | object[] | No | Frontend routes to register |
| frontend.nav | object[] | No | Navigation items for sidebar and top bar |
| frontend.adminLinks | object[] | No | Admin header links |

### Step 3: Create register.tsx

This file registers your plugin with the theme. It must be placed at `resources/scripts/register.tsx`:

```tsx
import React from 'react';
import { registerPlugin } from '@/plugins';
import MyComponent from './components/MyComponent';

registerPlugin({
    id: 'myplugin',
    name: 'My Plugin',
    routes: [
        {
            path: '/my-page',
            component: React.lazy(() => import('./components/MyComponent')),
        },
    ],
    navItems: [
        {
            label: 'My Page',
            icon: 'ShoppingCartIcon',
            path: '/my-page',
        },
    ],
    adminLinks: [
        {
            route: 'admin.myplugin',
            title: 'My Plugin',
            icon: 'fa-cog',
        },
    ],
});
```

#### Plugin Registration Interface

```typescript
interface Plugin {
    id: string;
    name: string;
    routes: PluginRoute[];
    navItems: PluginNavItem[];
    adminLinks: PluginAdminLink[];
}

interface PluginRoute {
    path: string;
    component: React.LazyExoticComponent<React.ComponentType<any>>;
    exact?: boolean;
}

interface PluginNavItem {
    label: string;
    icon: string;
    path: string;
    exact?: boolean;
}

interface PluginAdminLink {
    route: string;
    title: string;
    icon: string;
}
```

#### Available Icons

Navigation icons must match Heroicons outline icon names:

- `ShoppingCartIcon`
- `ServerIcon`
- `UserCircleIcon`
- `CogIcon`
- `ChartBarIcon`
- `FolderIcon`
- `BellIcon`
- `DocumentTextIcon`
- `CurrencyDollarIcon`
- `ShieldCheckIcon`

Admin link icons use FontAwesome classes:

- `fa-cog`, `fa-credit-card`, `fa-shopping-cart`, `fa-server`, `fa-users`, `fa-database`, `fa-chart-bar`, etc.

### Step 4: Create Route Files

#### Admin Routes (routes/admin.php)

```php
<?php

use Illuminate\Support\Facades\Route;
use Pterodactyl\Http\Controllers\Admin;

Route::group(['prefix' => 'myplugin'], function () {
    Route::get('/', [Admin\MyPluginController::class, 'index'])->name('admin.myplugin');
    Route::post('/', [Admin\MyPluginController::class, 'update'])->name('admin.myplugin.update');
});
```

#### API Routes (routes/api.php)

```php
<?php

use Illuminate\Support\Facades\Route;
use Pterodactyl\Http\Controllers\Api\Client;

Route::prefix('/my-api')->group(function () {
    Route::get('/', [Client\MyPluginController::class, 'index']);
    Route::post('/action', [Client\MyPluginController::class, 'action']);
});
```

### Step 5: Create PHP Backend

Create your controller following Pterodactyl conventions:

```php
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Http\Controllers\Controller;
use Illuminate\View\View;
use Illuminate\Http\Request;

class MyPluginController extends Controller
{
    public function index(): View
    {
        return view('admin.myplugin', [
            'data' => [],
        ]);
    }

    public function update(Request $request): \Illuminate\Http\RedirectResponse
    {
        // Handle update
        return redirect()->route('admin.myplugin')->with('success', 'Settings saved.');
    }
}
```

### Step 6: Create Frontend Component

```tsx
import React from 'react';
import PageContentBlock from '@/components/elements/PageContentBlock';
import ContentBox from '@/components/elements/ContentBox';

export default () => {
    return (
        <PageContentBlock title={'My Page'}>
            <ContentBox title={'My Component'}>
                <p>Plugin content goes here.</p>
            </ContentBox>
        </PageContentBlock>
    );
};
```

### Step 7: Create Database Migrations

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('myplugin_table', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('myplugin_table');
    }
};
```

## Publishing a Plugin

### Repository Structure

Host your plugin in a Git repository with this structure:

```
myplugin/
├── app/
├── database/
├── resources/
│   ├── views/
│   └── scripts/
│       ├── register.tsx
│       └── components/
├── routes/
│   ├── admin.php
│   └── api.php
└── manifest.json
```

### Installation URL

Users install plugins via the admin panel using one of these URL formats:

GitHub branch tree URL:
```
https://github.com/username/repository/tree/branch/plugin-directory
```

Example:
```
https://github.com/miuujs/miuujs/tree/plugins/mustikapay
```

Direct tarball URL:
```
https://example.com/myplugin.tar.gz
```

## Plugin Lifecycle

### Installation

1. Admin enters the plugin URL in the Plugins management page
2. The system downloads and extracts the plugin
3. Files are copied to their respective directories
4. Database migrations are run
5. Frontend is rebuilt with webpack
6. Plugin is registered in `storage/miuujs-plugins.json`

### Uninstallation

1. Admin clicks "Uninstall" on the plugin card
2. Frontend plugin files are removed from `resources/scripts/plugins/`
3. Route files are removed from `routes/plugins/`
4. Laravel caches are cleared
5. Frontend is rebuilt
6. Plugin entry is removed from `storage/miuujs-plugins.json`

Note: Database migrations are not rolled back automatically. If your plugin creates tables, provide a separate uninstall script or document manual cleanup steps.

## Best Practices

### Naming

- Use lowercase identifiers with no spaces (e.g., `myplugin`, `billing_system`)
- Controller names should be descriptive (e.g., `BillingController`, `StoreController`)
- Route names should be prefixed with `admin.` for admin routes (e.g., `admin.billing`)

### File Organization

- Keep `register.tsx` at the root of `resources/scripts/`
- Place React components in `resources/scripts/components/`
- Separate admin and API routes into different files
- Use the plugin ID as a prefix for all route names

### Compatibility

- Do not modify theme files directly. Use the plugin registry API only.
- Use `React.lazy()` for route components to enable code splitting.
- Test your plugin with the latest version of the MiuuJS theme.

### Security

- Validate all user input in controllers
- Use Laravel's CSRF protection for forms
- Follow Pterodactyl's permission system for access control
- Do not expose sensitive data in frontend components

## Example: MustikaPay Plugin

The MustikaPay plugin is a reference implementation. Study its structure at:

```
https://github.com/miuujs/miuujs/tree/plugins/mustikapay
```

Key files to review:
- `manifest.json` - Plugin metadata and configuration
- `resources/scripts/register.tsx` - Plugin registration
- `routes/admin.php` - Admin route definitions
- `routes/api.php` - API route definitions
- `app/Http/Controllers/Admin/MustikaPayController.php` - Admin controller
- `app/Http/Controllers/Api/Client/Store/StoreController.php` - API controller
