<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=24&height=220&section=header&text=MiuuJS&fontSize=70&fontColor=ffffff&desc=Pterodactyl%20Theme&descSize=20&descAlignY=65">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=24&height=220&section=header&text=MiuuJS&fontSize=70&fontColor=4A35CF&desc=Pterodactyl%20Theme&descSize=20&descAlignY=65">
</picture>

<div align="center">

[![Stars](https://img.shields.io/github/stars/miuujs/miuujs?style=for-the-badge&logo=github&color=4A35CF)](https://github.com/miuujs/miuujs/stargazers)
[![Forks](https://img.shields.io/github/forks/miuujs/miuujs?style=for-the-badge&logo=github&color=4A35CF)](https://github.com/miuujs/miuujs/forks)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg?style=for-the-badge&color=4A35CF)](https://github.com/miuujs/miuujs/blob/main/LICENSE)
[![Code Size](https://img.shields.io/github/languages/code-size/miuujs/miuujs?style=for-the-badge&logo=codefactor&color=4A35CF)](https://github.com/miuujs/miuujs)
[![Last Commit](https://img.shields.io/github/last-commit/miuujs/miuujs?style=for-the-badge&logo=git&color=4A35CF)](https://github.com/miuujs/miuujs/commits/main)

</div>

MiuuJS is a modern dark theme for Pterodactyl panel. It integrates the full Arix UI for the user dashboard, featuring a custom login page with MiuuJS branding, WhatsApp/GitHub social widgets, and a fully responsive design.

## Quick Install

```bash
bash <(curl -s https://raw.githubusercontent.com/miuujs/miuujs/main/install.sh)
```

> [!CAUTION]
> This theme modifies core Pterodactyl panel files. Always backup your installation before applying.
> Use at your own risk. The maintainers are not responsible for any data loss or service disruption.

## Features

- **Login Page** -- Custom login with background image, gradient overlay, MiuuJS watermark, and custom reCAPTCHA button
- **User Dashboard** -- Full Arix UI integration with sidebar navigation, server cards (gradient/banner/default), and live resource monitoring
- **Server Management** -- Console, file manager, databases, schedules, backups, network, users, and startup pages with Arix-style theming
- **Dark Theme** -- Deep dark color scheme with purple primary accent (#4A35CF), Rubik + IBM Plex Sans fonts
- **Social Widgets** -- WhatsApp link, GitHub stars widget, and support link
- **Customizable** -- Theme configuration via config/miuujs.php and admin panel
- **Responsive** -- Fully responsive for mobile, tablet, and desktop
- **Admin Panel** -- Dark-styled admin interface with Arix CSS

## Optional: MustikaPay Store & Billing Mod

The theme includes an optional **MustikaPay** store mod that adds:

- **Balance System** -- User balance column on the `users` table
- **Server Store** -- Browse products and purchase server resources via `/store`
- **Payment Gateway** -- MustikaPay integration (QRIS, BCA VA, BNI VA, BRI VA)
- **Admin Billing** -- Configure API key, prices, and products at `/admin/mustikapay`
- **MiuuJS-styled UI** -- Store container matches theme design (CSS variables, rounded-box, dark)

### Requirements
- PHP 8.0+ with `curl`, `json`, `mbstring` extensions
- MySQL/MariaDB for the `balance` column
- Active [MustikaPay](https://mustikapay.com) merchant account (API key format `MP-xxxx-xxxx`)

### Installation
The mod is automatically offered during theme installation. You can also run manually:

```bash
bash <(curl -s https://raw.githubusercontent.com/miuujs/miuujs/main/install.sh)
# Select option 0 (Install MiuuJS Theme)
# Answer "y" when asked about MustikaPay mod
```

### After Install
1. Go to **Admin Panel → MustikaPay Billing** (`/admin/mustikapay`)
2. Set your `MustikaPay API Key` and click Save
3. Add products (name, description, price, RAM, disk, CPU, servers)
4. Users can top up at `/store` and purchase resources

### Default Prices
| Product         | Price  | RAM  | Disk | CPU | Servers |
|-----------------|--------|------|------|-----|---------|
| RAM 1GB         | Rp 5000 | 1024 MB | —    | 0%  | 0       |
| Disk 1GB        | Rp 3000 | —    | 1024 MB | 0%  | 0       |
| CPU 10%         | Rp 2000 | —    | —    | 10% | 0       |
| Extra Server Slot | Rp 5000 | —  | —    | 0%  | 1       |

### Files
The mod files live under `plugins/` in this repository:
- `plugins/app/Extensions/Payment/MustikaPay/` -- PHP SDK for MustikaPay API
- `plugins/app/Http/Controllers/` -- Admin + API controllers
- `plugins/app/Models/` -- Modified User and Server models with balance/billing fields
- `plugins/database/migrations/` -- Migration files for balance and billing columns
- `plugins/resources/` -- Admin blade view and StoreContainer.tsx frontend
- `plugins/routes/` -- Route stubs injected into admin.php and api-client.php

## License

Distributed under the **GNU General Public License v3.0**. See [LICENSE](LICENSE) for more information.

This project includes modified code from:
- **Arix Theme** -- originally by Weijers.one
- **Pterodactyl Panel** -- MIT License

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=24&height=120&section=footer">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=24&height=120&section=footer">
</picture>