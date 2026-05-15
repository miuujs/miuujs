/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { action, Action, thunk, Thunk } from 'easy-peasy';
import getSystemPermissions from '@/api/getSystemPermissions';

export interface PanelPermissions {
    [key: string]: {
        description: string;
        keys: { [k: string]: string };
    };
}

export interface GloablPermissionsStore {
    data: PanelPermissions;
    setPermissions: Action<GloablPermissionsStore, PanelPermissions>;
    getPermissions: Thunk<GloablPermissionsStore, void, Record<string, unknown>, any, Promise<void>>;
}

const permissions: GloablPermissionsStore = {
    data: {},

    setPermissions: action((state, payload) => {
        state.data = payload;
    }),

    getPermissions: thunk(async (actions) => {
        const permissions = await getSystemPermissions();

        actions.setPermissions(permissions);
    }),
};

export default permissions;
