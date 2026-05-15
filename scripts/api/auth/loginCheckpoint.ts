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
import { LoginResponse } from '@/api/auth/login';

export default (token: string, code: string, recoveryToken?: string): Promise<LoginResponse> => {
    return new Promise((resolve, reject) => {
        http.post('/auth/login/checkpoint', {
            confirmation_token: token,
            authentication_code: code,
            recovery_token: recoveryToken && recoveryToken.length > 0 ? recoveryToken : undefined,
        })
            .then((response) =>
                resolve({
                    complete: response.data.data.complete,
                    intended: response.data.data.intended || undefined,
                })
            )
            .catch(reject);
    });
};
