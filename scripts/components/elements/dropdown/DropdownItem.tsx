/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import React, { forwardRef } from 'react';
import { Menu } from '@headlessui/react';
import styles from './style.module.css';
import classNames from 'classnames';

interface Props {
    children: React.ReactNode | ((opts: { active: boolean; disabled: boolean }) => JSX.Element);
    danger?: boolean;
    disabled?: boolean;
    className?: string;
    icon?: JSX.Element;
    onClick?: (e: React.MouseEvent) => void;
}

const DropdownItem = forwardRef<HTMLAnchorElement, Props>(
    ({ disabled, danger, className, onClick, children, icon: IconComponent }, ref) => {
        return (
            <Menu.Item disabled={disabled}>
                {({ disabled, active }) => (
                    <a
                        ref={ref}
                        href={'#'}
                        className={classNames(
                            styles.menu_item,
                            {
                                [styles.danger]: danger,
                                [styles.disabled]: disabled,
                            },
                            className
                        )}
                        onClick={onClick}
                    >
                        {IconComponent}
                        {typeof children === 'function' ? children({ disabled, active }) : children}
                    </a>
                )}
            </Menu.Item>
        );
    }
);

export default DropdownItem;
