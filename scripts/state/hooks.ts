/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { createTypedHooks } from 'easy-peasy';
import { ApplicationStore } from '@/state/index';

const hooks = createTypedHooks<ApplicationStore>();

export const useStore = hooks.useStore;
export const useStoreState = hooks.useStoreState;
export const useStoreActions = hooks.useStoreActions;
export const useStoreDispatch = hooks.useStoreDispatch;
