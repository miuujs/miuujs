/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { isEmptyObject, isObject } from '@/lib/objects';

export default <T extends {}>(data: T): T => {
    const empty = [undefined, null, ''] as unknown[];

    const removeEmptyValues = (input: T): T =>
        Object.entries(input)
            .filter(([_, value]) => !empty.includes(value))
            .reduce((obj, [k, v]) => {
                const parsed = isObject(v) ? removeEmptyValues(v as any) : v;

                return isObject(parsed) && isEmptyObject(parsed) ? obj : { ...obj, [k]: parsed };
            }, {} as T);

    return removeEmptyValues(data);
};
