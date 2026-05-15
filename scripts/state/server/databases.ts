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
import { ServerDatabase } from '@/api/server/databases/getServerDatabases';

export interface ServerDatabaseStore {
    data: ServerDatabase[];
    setDatabases: Action<ServerDatabaseStore, ServerDatabase[]>;
    appendDatabase: Action<ServerDatabaseStore, ServerDatabase>;
    removeDatabase: Action<ServerDatabaseStore, string>;
}

const databases: ServerDatabaseStore = {
    data: [],

    setDatabases: action((state, payload) => {
        state.data = payload;
    }),

    appendDatabase: action((state, payload) => {
        if (state.data.find((database) => database.id === payload.id)) {
            state.data = state.data.map((database) => (database.id === payload.id ? payload : database));
        } else {
            state.data = [...state.data, payload];
        }
    }),

    removeDatabase: action((state, payload) => {
        state.data = [...state.data.filter((database) => database.id !== payload)];
    }),
};

export default databases;
