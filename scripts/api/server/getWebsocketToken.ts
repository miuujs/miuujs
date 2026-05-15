/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import http from '@/api/http';

interface Response {
    token: string;
    socket: string;
}

export default (server: string): Promise<Response> => {
    return new Promise((resolve, reject) => {
        http.get(`/api/client/servers/${server}/websocket`)
            .then(({ data }) =>
                resolve({
                    token: data.data.token,
                    socket: data.data.socket,
                })
            )
            .catch(reject);
    });
};
