/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { Action, action } from 'easy-peasy';
import { Websocket } from '@/plugins/Websocket';

export interface SocketStore {
    instance: Websocket | null;
    connected: boolean;
    setInstance: Action<SocketStore, Websocket | null>;
    setConnectionState: Action<SocketStore, boolean>;
}

const socket: SocketStore = {
    instance: null,
    connected: false,
    setInstance: action((state, payload) => {
        state.instance = payload;
    }),
    setConnectionState: action((state, payload) => {
        state.connected = payload;
    }),
};

export default socket;
