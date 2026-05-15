/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { ComponentType, lazy } from 'react';

const features: Record<string, ComponentType> = {
    eula: lazy(() => import('@feature/eula/EulaModalFeature')),
    java_version: lazy(() => import('@feature/JavaVersionModalFeature')),
    gsl_token: lazy(() => import('@feature/GSLTokenModalFeature')),
    pid_limit: lazy(() => import('@feature/PIDLimitModalFeature')),
    steam_disk_space: lazy(() => import('@feature/SteamDiskSpaceFeature')),
};

export default features;
