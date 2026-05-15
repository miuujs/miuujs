/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { DependencyList, EffectCallback, useEffect } from 'react';
import { useDeepMemoize } from './useDeepMemoize';

export const useDeepCompareEffect = (callback: EffectCallback, dependencies: DependencyList) =>
    useEffect(callback, useDeepMemoize(dependencies));
