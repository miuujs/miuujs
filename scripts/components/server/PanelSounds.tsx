/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import React, { useEffect, useRef } from 'react';
import { ServerContext } from '@/state/server';

const PanelSounds = () => {
    const status = ServerContext.useStoreState((state) => state.status.value);
    
    const prevStatusRef = useRef<string | null>(null);

    useEffect(() => {
        const panelSoundsEnabled = localStorage.getItem('panelSounds') === 'true';

        if (prevStatusRef.current !== null && (status === 'running' || status === 'offline') && panelSoundsEnabled) {
            if (status === 'running') {
                const runningSound = new Audio('/miuujs/online.mp3');
                runningSound.volume = 1;
                runningSound.play();
            } else if (status === 'offline') {
                const offlineSound = new Audio('/miuujs/offline.mp3');
                offlineSound.volume = 0.2;
                offlineSound.play();
            }
        }

        prevStatusRef.current = status;
    }, [status]);

    return null;
};

export default PanelSounds;
