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
import { IconPosition } from '@/components/elements/dialog/DialogIcon';

type Callback<T> = ((value: T) => void) | React.Dispatch<React.SetStateAction<T>>;

export interface DialogProps {
    open: boolean;
    onClose: () => void;
}

export type IconPosition = 'title' | 'container' | undefined;

export interface DialogIconProps {
    type: 'danger' | 'info' | 'success' | 'warning';
    position?: IconPosition;
    className?: string;
}

export interface RenderDialogProps extends DialogProps {
    hideCloseIcon?: boolean;
    preventExternalClose?: boolean;
    title?: string;
    description?: string | undefined;
    children?: React.ReactNode;
}

export type WrapperProps = Omit<RenderDialogProps, 'children' | 'open' | 'onClose'>;
export interface DialogWrapperContextType {
    props: Readonly<WrapperProps>;
    setProps: React.Dispatch<React.SetStateAction<WrapperProps>>;
    close: () => void;
}

export interface DialogContextType {
    setIcon: Callback<React.ReactNode>;
    setFooter: Callback<React.ReactNode>;
    setIconPosition: Callback<IconPosition>;
}
