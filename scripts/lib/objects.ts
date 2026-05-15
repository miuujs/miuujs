/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
function isObject(val: unknown): val is Record<string, unknown> {
    return typeof val === 'object' && val !== null && !Array.isArray(val);
}

function isEmptyObject(val: {}): boolean {
    return Object.keys(val).length === 0 && Object.getPrototypeOf(val) === Object.prototype;
}

function getObjectKeys<T extends {}>(o: T): (keyof T)[] {
    return Object.keys(o) as (keyof typeof o)[];
}

export { isObject, isEmptyObject, getObjectKeys };
