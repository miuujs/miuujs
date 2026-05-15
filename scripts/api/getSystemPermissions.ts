/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { PanelPermissions } from '@/state/permissions';
import http from '@/api/http';

export default (): Promise<PanelPermissions> => {
    return new Promise((resolve, reject) => {
        http.get('/api/client/permissions')
            .then(({ data }) => resolve(data.attributes.permissions))
            .catch(reject);
    });
};
