/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import React, { memo } from 'react';
import { usePermissions } from '@/plugins/usePermissions';
import isEqual from 'react-fast-compare';

interface Props {
    action: string | string[];
    matchAny?: boolean;
    renderOnError?: React.ReactNode | null;
    children: React.ReactNode;
}

const Can = ({ action, matchAny = false, renderOnError, children }: Props) => {
    const can = usePermissions(action);

    return (
        <>
            {(matchAny && can.filter((p) => p).length > 0) || (!matchAny && can.every((p) => p))
                ? children
                : renderOnError}
        </>
    );
};

export default memo(Can, isEqual);
