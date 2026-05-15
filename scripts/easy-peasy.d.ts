/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import EasyPeasy, { Actions, State } from 'easy-peasy';
import { ApplicationStore } from '@/state';

declare module 'easy-peasy' {
    export function useStoreState<Result>(mapState: (state: State<ApplicationStore>) => Result): Result;

    export function useStoreActions<Result>(mapActions: (actions: Actions<ApplicationStore>) => Result): Result;
}
