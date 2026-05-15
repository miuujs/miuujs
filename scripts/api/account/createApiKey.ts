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
import { ApiKey, rawDataToApiKey } from '@/api/account/getApiKeys';

export default (description: string, allowedIps: string): Promise<ApiKey & { secretToken: string }> => {
    return new Promise((resolve, reject) => {
        http.post('/api/client/account/api-keys', {
            description,
            allowed_ips: allowedIps.length > 0 ? allowedIps.split('\n') : [],
        })
            .then(({ data }) =>
                resolve({
                    ...rawDataToApiKey(data.attributes),
                    // eslint-disable-next-line camelcase
                    secretToken: data.meta?.secret_token ?? '',
                })
            )
            .catch(reject);
    });
};
