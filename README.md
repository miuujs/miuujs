<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=24&height=200&section=header&text=MiuuJS&fontSize=70&fontColor=ffffff&desc=Pterodactyl%20Theme&descSize=20&descAlignY=65">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=24&height=200&section=header&text=MiuuJS&fontSize=70&fontColor=4A35CF&desc=Pterodactyl%20Theme&descSize=20&descAlignY=65">
</picture>

MiuuJS is a modern dark theme for Pterodactyl panel. It integrates the full Arix UI for the user dashboard, featuring a custom login page with MiuuJS branding, WhatsApp/GitHub social widgets, and a fully responsive design.

## Features

- **Login Page** -- Custom login with background image, gradient overlay, MiuuJS watermark, and custom reCAPTCHA button
- **User Dashboard** -- Full Arix UI integration with sidebar navigation, server cards (gradient/banner/default), and live resource monitoring
- **Server Management** -- Console, file manager, databases, schedules, backups, network, users, and startup pages with Arix-style theming
- **Dark Theme** -- Deep dark color scheme with purple primary accent (#4A35CF), Rubik + IBM Plex Sans fonts
- **Social Widgets** -- WhatsApp link, GitHub stars widget, and support link
- **Customizable** -- Theme configuration via config/miuujs.php and admin panel
- **Responsive** -- Fully responsive for mobile, tablet, and desktop
- **Admin Panel** -- Dark-styled admin interface with Arix CSS

## Installation

### Prerequisites

- Pterodactyl panel (v1.12+)
- Node.js >= 20
- PHP 8.1+

### Steps

1. Clone the repository into your Pterodactyl panel directory:

```bash
cd /var/www/pterodactyl
git clone https://github.com/miuujs/miuujs.git ./miuujs-temp
```

2. Copy the theme files:

```bash
cp -r miuujs-temp/resources/* resources/
cp -r miuujs-temp/scripts/* resources/scripts/
cp -r miuujs-temp/public/* public/
cp -r miuujs-temp/config/* config/
cp -r miuujs-temp/routes/* routes/
cp -r miuujs-temp/app/* app/
cp miuujs-temp/tailwind.config.js .
cp miuujs-temp/webpack.config.js .
cp miuujs-temp/package.json .
rm -rf miuujs-temp
```

3. Install dependencies and build:

```bash
npm install
npm run build
```

4. Clear cache:

```bash
php artisan view:clear
php artisan config:clear
php artisan route:clear
```

## Configuration

Theme settings can be modified in `config/miuujs.php`. Key settings include:

| Setting | Default | Description |
|---------|---------|-------------|
| logo | /miuujs/MiuuJS.jpg | Panel logo path |
| primary | #4A35CF | Primary accent color |
| whatsapp | https://whatsapp.com/channel/... | WhatsApp channel URL |
| support | https://github.com/miuujs/miuujs/issues | Support URL |
| loginLayout | 1 | Login page layout (1-4) |
| layout | 1 | Dashboard layout (1, 3, 5) |
| serverRow | 1 | Server card style (1-gradient, 2-banner, 3-default) |
| githubBox | true | Show GitHub stars widget |
| announcementType | party | Announcement type (disabled, info, success, etc.) |

## Dependencies

- react-icons
- md5
- bbcode-to-react
- path-browserify
- i18next-browser-languagedetector
- animejs (admin config page)

## File Structure

```
config/miuujs.php                    -- Theme configuration
resources/scripts/                   -- React components
  components/                        -- UI components
    auth/                            -- Login pages
    dashboard/                       -- Dashboard pages
    elements/                        -- Shared UI elements
    server/                          -- Server management pages
  routers/                           -- React router definitions
  state/                             -- State management
resources/views/                     -- Blade templates
  templates/auth/core.blade.php      -- Login page template
  templates/base/core.blade.php      -- Dashboard template
  templates/wrapper.blade.php        -- Main layout wrapper
  layouts/admin.blade.php            -- Admin layout
  admin/miuujs/index.blade.php       -- Theme config page
public/miuujs/                       -- Theme assets
  MiuuJS.jpg                         -- Logo
  background-login.png               -- Login background
public/themes/pterodactyl/css/       -- CSS files
app/Http/ViewComposers/              -- PHP view composers
app/Http/Controllers/                -- PHP controllers
routes/                              -- Laravel routes
```

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Opera (latest)

## License

GNU General Public License v3.0. See LICENSE file for details.

This project includes modified code from Arix Theme (originally by Weijers.one) and Pterodactyl Panel (MIT License).

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=24&height=120&section=footer">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=24&height=120&section=footer">
</picture>