/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { capitalize } from '@/lib/strings';

describe('@/lib/strings.ts', function () {
    describe('capitalize()', function () {
        it('should capitalize a string', function () {
            expect(capitalize('foo bar')).toBe('Foo bar');
            expect(capitalize('FOOBAR')).toBe('Foobar');
        });

        it('should handle empty strings', function () {
            expect(capitalize('')).toBe('');
        });
    });
});
