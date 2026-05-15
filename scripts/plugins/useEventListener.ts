/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { useEffect, useRef } from 'react';

export default (
    eventName: string,
    handler: (e: Event | CustomEvent | UIEvent | any) => void,
    options?: boolean | EventListenerOptions
) => {
    const savedHandler = useRef<any>(null);

    useEffect(() => {
        savedHandler.current = handler;
    }, [handler]);

    useEffect(() => {
        const isSupported = window && window.addEventListener;
        if (!isSupported) return;

        const eventListener = (event: any) => savedHandler.current(event);
        window.addEventListener(eventName, eventListener, options);
        return () => {
            window.removeEventListener(eventName, eventListener);
        };
    }, [eventName, window]);
};
