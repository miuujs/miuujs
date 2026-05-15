/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { action, Action } from 'easy-peasy';

export type SubuserPermission =
    | 'websocket.connect'
    | 'control.console'
    | 'control.start'
    | 'control.stop'
    | 'control.restart'
    | 'user.create'
    | 'user.read'
    | 'user.update'
    | 'user.delete'
    | 'file.create'
    | 'file.read'
    | 'file.update'
    | 'file.delete'
    | 'file.archive'
    | 'file.sftp'
    | 'allocation.read'
    | 'allocation.update'
    | 'startup.read'
    | 'startup.update'
    | 'database.create'
    | 'database.read'
    | 'database.update'
    | 'database.delete'
    | 'database.view_password'
    | 'schedule.create'
    | 'schedule.read'
    | 'schedule.update'
    | 'schedule.delete';

export interface Subuser {
    uuid: string;
    username: string;
    email: string;
    image: string;
    twoFactorEnabled: boolean;
    createdAt: Date;
    permissions: SubuserPermission[];

    can(permission: SubuserPermission): boolean;
}

export interface ServerSubuserStore {
    data: Subuser[];
    setSubusers: Action<ServerSubuserStore, Subuser[]>;
    appendSubuser: Action<ServerSubuserStore, Subuser>;
    removeSubuser: Action<ServerSubuserStore, string>;
}

const subusers: ServerSubuserStore = {
    data: [],

    setSubusers: action((state, payload) => {
        state.data = payload;
    }),

    appendSubuser: action((state, payload) => {
        let matched = false;
        state.data = [
            ...state.data
                .map((user) => {
                    if (user.uuid === payload.uuid) {
                        matched = true;

                        return payload;
                    }

                    return user;
                })
                .concat(matched ? [] : [payload]),
        ];
    }),

    removeSubuser: action((state, payload) => {
        state.data = [...state.data.filter((user) => user.uuid !== payload)];
    }),
};

export default subusers;
