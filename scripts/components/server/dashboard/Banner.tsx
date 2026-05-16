/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import React from 'react';
import { ServerContext } from '@/state/server';

const Banner = () => {
    const eggImage = ServerContext.useStoreState((state) => state.server.data!.eggImage);

    return(
        <div className={'lg:col-span-2'}>
            <div className={'bg-center bg-no-repeat bg-cover w-full h-[25vh] rounded-box max-h-[250px]'} css={`background-image:url(${eggImage ? eggImage : '/miuujs/minecraft-banner.png'})`} />
        </div>
    )
}

export default Banner;