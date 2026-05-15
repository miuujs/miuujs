/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { ServerContext } from '@/state/server';
import useSWR from 'swr';
import http from '@/api/http';
import { rawDataToServerAllocation } from '@/api/transformers';
import { Allocation } from '@/api/server/getServer';

export default () => {
    const uuid = ServerContext.useStoreState((state) => state.server.data!.uuid);

    return useSWR<Allocation[]>(
        ['server:allocations', uuid],
        async () => {
            const { data } = await http.get(`/api/client/servers/${uuid}/network/allocations`);

            return (data.data || []).map(rawDataToServerAllocation);
        },
        { revalidateOnFocus: false, revalidateOnMount: false }
    );
};
