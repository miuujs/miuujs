/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import React from 'react';
import { SettableModalProps } from '@/hoc/asModal';

export interface ModalContextValues {
    dismiss: () => void;
    setPropOverrides: (
        value:
            | ((current: Readonly<Partial<SettableModalProps>>) => Partial<SettableModalProps>)
            | Partial<SettableModalProps>
            | null
    ) => void;
}

const ModalContext = React.createContext<ModalContextValues>({
    dismiss: () => null,
    setPropOverrides: () => null,
});

ModalContext.displayName = 'ModalContext';

export default ModalContext;
