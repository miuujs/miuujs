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

interface Data {
    token: string;
    password: string;
    passwordConfirmation: string;
}

interface PasswordResetResponse {
    redirectTo?: string | null;
    sendToLogin: boolean;
}

export default (email: string, data: Data): Promise<PasswordResetResponse> => {
    return new Promise((resolve, reject) => {
        http.post('/auth/password/reset', {
            email,
            token: data.token,
            password: data.password,
            password_confirmation: data.passwordConfirmation,
        })
            .then((response) =>
                resolve({
                    redirectTo: response.data.redirect_to,
                    sendToLogin: response.data.send_to_login,
                })
            )
            .catch(reject);
    });
};
