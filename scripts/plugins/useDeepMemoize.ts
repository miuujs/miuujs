/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { DependencyList, MutableRefObject, useRef } from 'react';
import isEqual from 'react-fast-compare';

export const useDeepMemoize = <T = DependencyList>(value: T): T => {
    const ref: MutableRefObject<T | undefined> = useRef();

    if (!isEqual(value, ref.current)) {
        ref.current = value;
    }

    return ref.current as T;
};
