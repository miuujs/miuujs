/*
 * User Registration Plugin - MiuuJS Theme
 * Copyright (C) 2026 MiuuJS
 */
import { registerPlugin } from '@/plugins';

registerPlugin({
    id: 'register',
    name: 'User Registration',
    routes: [],
    navItems: [],
    adminLinks: [
        {
            route: 'admin.register',
            title: 'Registration Settings',
            icon: 'fa-user-plus',
        },
    ],
});
