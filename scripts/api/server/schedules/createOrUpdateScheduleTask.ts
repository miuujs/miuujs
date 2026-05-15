/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { rawDataToServerTask, Task } from '@/api/server/schedules/getServerSchedules';
import http from '@/api/http';

interface Data {
    action: string;
    payload: string;
    timeOffset: string | number;
    continueOnFailure: boolean;
}

export default async (uuid: string, schedule: number, task: number | undefined, data: Data): Promise<Task> => {
    const { data: response } = await http.post(
        `/api/client/servers/${uuid}/schedules/${schedule}/tasks${task ? `/${task}` : ''}`,
        {
            action: data.action,
            payload: data.payload,
            continue_on_failure: data.continueOnFailure,
            time_offset: data.timeOffset,
        }
    );

    return rawDataToServerTask(response.attributes);
};
