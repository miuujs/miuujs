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
import classNames from 'classnames';
import styles from './styles.module.css';

enum Variant {
    Normal,
    Snug,
    Loose,
}

interface InputFieldProps extends React.ComponentProps<'input'> {
    variant?: Variant;
}

const Component = forwardRef<HTMLInputElement, InputFieldProps>(({ className, variant, ...props }, ref) => (
    <input
        ref={ref}
        className={classNames(
            'form-input',
            styles.text_input,
            { [styles.loose]: variant === Variant.Loose },
            className
        )}
        {...props}
    />
));

const InputField = Object.assign(Component, { Variants: Variant });

export default InputField;
