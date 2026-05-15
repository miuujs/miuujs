/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { ComponentType, ReactElement } from 'react';
import styledImport, { css as cssImport, CSSProp, StyledComponentProps } from 'styled-components';

declare module 'react' {
    interface Attributes {
        css?: CSSProp;
    }
}

declare module 'styled-components' {
    interface StyledComponentBase<
        C extends string | ComponentType<any>,
        // eslint-disable-next-line @typescript-eslint/ban-types
        T extends object,
        // eslint-disable-next-line @typescript-eslint/ban-types
        O extends object = {},
        A extends keyof any = never
    > extends ForwardRefExoticBase<StyledComponentProps<C, T, O, A>> {
        (
            props: StyledComponentProps<C, T, O, A> & { as?: Element | string; forwardedAs?: never | undefined }
        ): ReactElement<StyledComponentProps<C, T, O, A>>;
    }
}

declare module 'twin.macro' {
    const css: typeof cssImport;
    const styled: typeof styledImport;
}
