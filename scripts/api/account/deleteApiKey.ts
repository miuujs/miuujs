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

export default (identifier: string): Promise<void> => {
    return new Promise((resolve, reject) => {
        http.delete(`/api/client/account/api-keys/${identifier}`)
            .then(() => resolve())
            .catch(reject);
    });
};
