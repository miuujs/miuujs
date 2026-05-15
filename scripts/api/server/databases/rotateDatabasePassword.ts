/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { rawDataToServerDatabase, ServerDatabase } from '@/api/server/databases/getServerDatabases';
import http from '@/api/http';

export default (uuid: string, database: string): Promise<ServerDatabase> => {
    return new Promise((resolve, reject) => {
        http.post(`/api/client/servers/${uuid}/databases/${database}/rotate-password`)
            .then((response) => resolve(rawDataToServerDatabase(response.data.attributes)))
            .catch(reject);
    });
};
