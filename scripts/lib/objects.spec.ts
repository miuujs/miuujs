/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { isObject } from '@/lib/objects';

describe('@/lib/objects.ts', function () {
    describe('isObject()', function () {
        it('should return true for objects', function () {
            expect(isObject({})).toBe(true);
            expect(isObject({ foo: 123 })).toBe(true);
            expect(isObject(Object.freeze({}))).toBe(true);
        });

        it('should return false for null', function () {
            expect(isObject(null)).toBe(false);
        });

        it.each([undefined, 123, 'foobar', () => ({}), Function, String(123), isObject, () => null, [], [1, 2, 3]])(
            'should return false for %p',
            function (value) {
                expect(isObject(value)).toBe(false);
            }
        );
    });
});
