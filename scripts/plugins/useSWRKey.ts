/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { useDeepCompareMemo } from '@/plugins/useDeepCompareMemo';
import { ServerContext } from '@/state/server';
import { useStoreState } from '@/state/hooks';

type Context = string | string[] | (string | number | null | {})[];

function useSWRKey(context: Context, prefix: string | null = null): string {
    const key = useDeepCompareMemo((): string => {
        return (Array.isArray(context) ? context : [context]).map((value) => JSON.stringify(value)).join(':');
    }, [context]);

    if (!key.trim().length) {
        throw new Error('Must provide a valid context key to "useSWRKey".');
    }

    return `swr::${prefix ? `${prefix}:` : ''}${key.trim()}`;
}

function useServerSWRKey(context: Context): string {
    const uuid = ServerContext.useStoreState((state) => state.server.data?.uuid);

    return useSWRKey(context, `server:${uuid}`);
}

function useUserSWRKey(context: Context): string {
    const uuid = useStoreState((state) => state.user.data?.uuid);

    return useSWRKey(context, `user:${uuid}`);
}

export default useSWRKey;
export { useServerSWRKey, useUserSWRKey };
