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

export interface TwoFactorTokenData {
    // eslint-disable-next-line camelcase
    image_url_data: string;
    secret: string;
}

export default (): Promise<TwoFactorTokenData> => {
    return new Promise((resolve, reject) => {
        http.get('/api/client/account/two-factor')
            .then(({ data }) => resolve(data.data))
            .catch(reject);
    });
};
