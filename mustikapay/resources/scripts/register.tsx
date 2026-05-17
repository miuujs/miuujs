/*
 * MustikaPay Plugin - MiuuJS Theme
 * Copyright (C) 2026 MiuuJS
 */
import React from 'react';
import { registerPlugin } from '@/plugins';

registerPlugin({
    id: 'mustikapay',
    name: 'MustikaPay',
    routes: [
        {
            path: '/products',
            component: React.lazy(() => import('./components/dashboard/StoreContainer')),
        },
    ],
    navItems: [
        {
            label: 'Products',
            icon: 'ShoppingCartIcon',
            path: '/products',
        },
    ],
    adminLinks: [
        {
            route: 'admin.mustikapay',
            title: 'MustikaPay Billing',
            icon: 'fa-credit-card',
        },
    ],
});
