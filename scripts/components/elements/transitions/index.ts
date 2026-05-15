/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { Transition as TransitionComponent } from '@headlessui/react';
import FadeTransition from '@/components/elements/transitions/FadeTransition';

const Transition = Object.assign(TransitionComponent, {
    Fade: FadeTransition,
});

export { Transition };
