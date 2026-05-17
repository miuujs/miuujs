/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import React from 'react';

export interface PluginRoute {
    path: string;
    component: React.LazyExoticComponent<React.ComponentType<any>>;
    exact?: boolean;
}

export interface PluginNavItem {
    label: string;
    icon: string;
    path: string;
    exact?: boolean;
}

export interface PluginAdminLink {
    route: string;
    title: string;
    icon: string;
}

export interface Plugin {
    id: string;
    name: string;
    routes: PluginRoute[];
    navItems: PluginNavItem[];
    adminLinks: PluginAdminLink[];
}

const plugins: Plugin[] = [];

export function registerPlugin(plugin: Plugin): void {
    plugins.push(plugin);
}

export function getPlugins(): Plugin[] {
    return plugins;
}

export function getPluginRoutes(): PluginRoute[] {
    return plugins.flatMap(p => p.routes);
}

export function getPluginNavItems(): PluginNavItem[] {
    return plugins.flatMap(p => p.navItems);
}

export function getPluginAdminLinks(): PluginAdminLink[] {
    return plugins.flatMap(p => p.adminLinks);
}
