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
import { Field, FieldProps } from 'formik';
import InputError from '@/components/elements/InputError';
import Label from '@/components/elements/Label';

interface Props {
    id?: string;
    name: string;
    children: React.ReactNode;
    className?: string;
    label?: string;
    description?: string;
    validate?: (value: any) => undefined | string | Promise<any>;
}

const FormikFieldWrapper = ({ id, name, label, className, description, validate, children }: Props) => (
    <Field name={name} validate={validate}>
        {({ field, form: { errors, touched } }: FieldProps) => (
            <div className={`${className} ${touched[field.name] && errors[field.name] ? 'has-error' : undefined}`}>
                {label && <Label htmlFor={id}>{label}</Label>}
                {children}
                <InputError errors={errors} touched={touched} name={field.name}>
                    {description || null}
                </InputError>
            </div>
        )}
    </Field>
);

export default FormikFieldWrapper;
