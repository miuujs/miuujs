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
import Spinner from '@/components/elements/Spinner';
import Console from '@/components/server/console/Console';

const FullConsoleContainer = () => {

    return (
        <div>
            <Spinner.Suspense>
                <Console fullConsole/>
            </Spinner.Suspense>
            <div className={'fixed top-0 left-0 h-full w-full z-[50] bg-gray-800'}/>
        </div>
    );
};

export default FullConsoleContainer;
