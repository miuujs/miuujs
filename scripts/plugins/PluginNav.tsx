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
import { NavLink } from 'react-router-dom';
import { getPluginNavItems } from '@/plugins';
import * as HeroIcons from '@heroicons/react/outline';

export const PluginNavItems: React.FC = () => {
    const items = getPluginNavItems();
    return (
        <>
            {items.map((item, i) => {
                const IconComponent = (HeroIcons as any)[item.icon];
                if (!IconComponent) return null;
                return (
                    <NavLink key={`${item.path}-${i}`} to={item.path} exact={item.exact !== false}>
                        <IconComponent className={'w-5'} />{item.label}
                    </NavLink>
                );
            })}
        </>
    );
};

export const PluginNavItemsMobile: React.FC = () => {
    const items = getPluginNavItems();
    return (
        <>
            {items.map((item, i) => {
                const IconComponent = (HeroIcons as any)[item.icon];
                if (!IconComponent) return null;
                return (
                    <NavLink key={`${item.path}-${i}`} to={item.path} exact={item.exact !== false}>
                        <IconComponent />{item.label}
                    </NavLink>
                );
            })}
        </>
    );
};
