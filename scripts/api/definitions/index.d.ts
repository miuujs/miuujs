/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import { MarkRequired } from 'ts-essentials';
import { FractalResponseData, FractalResponseList } from '../http';

export type UUID = string;
export type Identifier<P extends string = string> = `${P}_${string}`;

export interface Model {}

interface ModelWithRelationships extends Model {
    relationships: Record<string, FractalResponseData | FractalResponseList | undefined>;
}

type WithLoaded<M extends ModelWithRelationships, R extends keyof M['relationships']> = M & {
    relationships: MarkRequired<M['relationships'], R>;
};

export type InferModel<T extends (...args: any) => any> = ReturnType<T> extends Promise<infer U> ? U : T;
