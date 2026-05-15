/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { action, Action } from 'easy-peasy';

export interface ProgressStore {
    continuous: boolean;
    progress?: number;

    startContinuous: Action<ProgressStore>;
    setProgress: Action<ProgressStore, number | undefined>;
    setComplete: Action<ProgressStore>;
}

const progress: ProgressStore = {
    continuous: false,
    progress: undefined,

    startContinuous: action((state) => {
        state.continuous = true;
    }),

    setProgress: action((state, payload) => {
        state.progress = payload;
    }),

    setComplete: action((state) => {
        if (state.progress) {
            state.progress = 100;
        }

        state.continuous = false;
    }),
};

export default progress;
