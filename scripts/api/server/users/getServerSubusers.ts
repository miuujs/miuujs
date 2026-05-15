/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import http, { FractalResponseData } from '@/api/http';
import { Subuser } from '@/state/server/subusers';

export const rawDataToServerSubuser = (data: FractalResponseData): Subuser => ({
    uuid: data.attributes.uuid,
    username: data.attributes.username,
    email: data.attributes.email,
    image: data.attributes.image,
    twoFactorEnabled: data.attributes['2fa_enabled'],
    createdAt: new Date(data.attributes.created_at),
    permissions: data.attributes.permissions || [],
    can: (permission) => (data.attributes.permissions || []).indexOf(permission) >= 0,
});

export default (uuid: string): Promise<Subuser[]> => {
    return new Promise((resolve, reject) => {
        http.get(`/api/client/servers/${uuid}/users`)
            .then(({ data }) => resolve((data.data || []).map(rawDataToServerSubuser)))
            .catch(reject);
    });
};
