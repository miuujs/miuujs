/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import PageContentBlock, { PageContentBlockProps } from '@/components/elements/PageContentBlock';
import React from 'react';
import { ApplicationStore } from '@/state';
import { useStoreState } from 'easy-peasy';
import { ServerContext } from '@/state/server';

interface Props extends PageContentBlockProps {
    title: string;
    icon?: React.ComponentType<{ className?: string }>;
}

const ServerContentBlock: React.FC<Props> = ({ title, icon: Icon, children, ...props }) => {
    const name = ServerContext.useStoreState((state) => state.server.data!.name);
    const pageTitle = String(useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.pageTitle));

    return (
        <PageContentBlock title={`${name} | ${title}`} {...props}>
            {pageTitle == 'true' && Icon &&
                <div className={'flex items-center gap-x-3 mb-6'}>
                    <div css={'background-color:color-mix(in srgb, var(--primary) 30%, transparent);'} className={'w-10 h-10 rounded-component !border-none flex items-center justify-center text-miuujs backdrop'}>
                        <Icon className={'w-6'} />
                    </div>
                    <p className={'text-lg font-medium text-gray-300'}>
                        {title}
                    </p>
                </div>
            }
            {children}
        </PageContentBlock>
    );
};

export default ServerContentBlock;
