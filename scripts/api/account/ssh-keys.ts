/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import useSWR, { ConfigInterface } from 'swr';
import http, { FractalResponseList } from '@/api/http';
import { SSHKey, Transformers } from '@definitions/user';
import { AxiosError } from 'axios';
import { useUserSWRKey } from '@/plugins/useSWRKey';

const useSSHKeys = (config?: ConfigInterface<SSHKey[], AxiosError>) => {
    const key = useUserSWRKey(['account', 'ssh-keys']);

    return useSWR(
        key,
        async () => {
            const { data } = await http.get('/api/client/account/ssh-keys');

            return (data as FractalResponseList).data.map((datum: any) => {
                return Transformers.toSSHKey(datum.attributes);
            });
        },
        { revalidateOnMount: false, ...(config || {}) }
    );
};

const createSSHKey = async (name: string, publicKey: string): Promise<SSHKey> => {
    const { data } = await http.post('/api/client/account/ssh-keys', { name, public_key: publicKey });

    return Transformers.toSSHKey(data.attributes);
};

const deleteSSHKey = async (fingerprint: string): Promise<void> =>
    await http.post('/api/client/account/ssh-keys/remove', { fingerprint });

export { useSSHKeys, createSSHKey, deleteSSHKey };
