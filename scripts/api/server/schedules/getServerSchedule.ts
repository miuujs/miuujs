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
import { rawDataToServerSchedule, Schedule } from '@/api/server/schedules/getServerSchedules';

export default (uuid: string, schedule: number): Promise<Schedule> => {
    return new Promise((resolve, reject) => {
        http.get(`/api/client/servers/${uuid}/schedules/${schedule}`, {
            params: {
                include: ['tasks'],
            },
        })
            .then(({ data }) => resolve(rawDataToServerSchedule(data.attributes)))
            .catch(reject);
    });
};
