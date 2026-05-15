/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import DialogComponent from './Dialog';
import DialogFooter from './DialogFooter';
import DialogIcon from './DialogIcon';
import ConfirmationDialog from './ConfirmationDialog';

const Dialog = Object.assign(DialogComponent, {
    Confirm: ConfirmationDialog,
    Footer: DialogFooter,
    Icon: DialogIcon,
});

export { Dialog };
export * from './types.d';
export * from './context';
export { default as styles } from './style.module.css';
