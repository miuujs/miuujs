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

function disableAccountTwoFactor(password: string): Promise<void> {
    return new Promise((resolve, reject) => {
        http.post('/api/client/account/two-factor/disable', { password })
            .then(() => resolve())
            .catch(reject);
    });
}

export default disableAccountTwoFactor;
