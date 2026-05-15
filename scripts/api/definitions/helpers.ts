/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import {
    FractalPaginatedResponse,
    FractalResponseData,
    FractalResponseList,
    getPaginationSet,
    PaginatedResult,
} from '@/api/http';
import { Model } from '@definitions/index';

type TransformerFunc<T> = (callback: FractalResponseData) => T;

const isList = (data: FractalResponseList | FractalResponseData): data is FractalResponseList => data.object === 'list';

function transform<T, M>(data: null | undefined, transformer: TransformerFunc<T>, missing?: M): M;
function transform<T, M>(
    data: FractalResponseData | null | undefined,
    transformer: TransformerFunc<T>,
    missing?: M
): T | M;
function transform<T, M>(
    data: FractalResponseList | FractalPaginatedResponse | null | undefined,
    transformer: TransformerFunc<T>,
    missing?: M
): T[] | M;
function transform<T>(
    data: FractalResponseData | FractalResponseList | FractalPaginatedResponse | null | undefined,
    transformer: TransformerFunc<T>,
    missing = undefined
) {
    if (data === undefined || data === null) {
        return missing;
    }

    if (isList(data)) {
        return data.data.map(transformer);
    }

    if (!data || !data.attributes || data.object === 'null_resource') {
        return missing;
    }

    return transformer(data);
}

function toPaginatedSet<T extends TransformerFunc<Model>>(
    response: FractalPaginatedResponse,
    transformer: T
): PaginatedResult<ReturnType<T>> {
    return {
        items: transform(response, transformer) as ReturnType<T>[],
        pagination: getPaginationSet(response.meta.pagination),
    };
}

export { transform, toPaginatedSet };
