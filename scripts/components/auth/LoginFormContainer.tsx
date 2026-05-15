/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import React, { forwardRef, useEffect, useState } from 'react';
import { Form } from 'formik';
import { ApplicationStore } from '@/state';
import { useStoreState } from 'easy-peasy';
import { SupportIcon } from '@heroicons/react/outline';
import parser from 'bbcode-to-react';
import FlashMessageRender from '@/components/FlashMessageRender';
import tw from 'twin.macro';
import { useTranslation } from 'react-i18next';

type Props = React.DetailedHTMLProps<React.FormHTMLAttributes<HTMLFormElement>, HTMLFormElement> & {
    title?: string;
};

export default forwardRef<HTMLFormElement, Props>(({ title, ...props }, ref) => {
    localStorage.setItem("username", "yuvraj_hun_007");
    localStorage.setItem("BuyerID", "616942");
    localStorage.setItem("Timestamp", "1751282130");
    
    const { t } = useTranslation('miuujs/auth');

    const name = useStoreState((state: ApplicationStore) => state.settings.data!.name);
    const copyright = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.copyright);
    const loginLayout = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.loginLayout);
    const logo = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.logo);
    const logoHeight = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.logoHeight);
    const fullLogo = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.fullLogo);
    const socialPosition = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.socialPosition);
    const logoPosition = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.logoPosition);
    const whatsapp = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.whatsapp);
    const support = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.support);
    
    return(
        <div className={'my-auto mx-auto px-4'}>
            <FlashMessageRender css={tw`mb-2 px-1`} />
            <Form {...props} ref={ref}>
                <div className={`max-w-[450px] w-screen lg:p-6 p-5 ${loginLayout == 1 ? 'bg-gray-700 rounded-box' : ''}`}>
                    {logoPosition == 1 &&
                    <div className='flex gap-x-2 items-center font-semibold text-lg text-gray-50 pb-5'>
                        <img src={logo} alt={name + 'logo'} css={`height:${logoHeight};`} />
                        {String(fullLogo) === 'false' && name}
                    </div>}
                    {title && <h2 css={tw`text-lg text-gray-50 font-medium mb-3`}>{title}</h2>}
                    {props.children}

                    {socialPosition == 2 &&
                        <div className={'flex justify-center gap-x-6 mt-5'}>
                            {whatsapp &&
                            <a className={'flex gap-x-1 items-center duration-300 hover:text-gray-100'} href={whatsapp} target={'_blank'}>
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5">
                                    <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
                                </svg>
                                WhatsApp
                            </a>}
                            {support && <a className={'flex gap-x-1 items-center duration-300 hover:text-gray-100'} href={support}><SupportIcon className={'w-5'} />{t('support')}</a>}
                        </div>
                    }
                </div>
            </Form>
            <div className={'mt-4'}>
                <p css={tw`text-center text-neutral-300 text-xs`}>
                    <a
                        rel={'noopener nofollow noreferrer'}
                        href={'https://pterodactyl.io'}
                        target={'_blank'}
                        css={tw`no-underline text-neutral-300 hover:text-neutral-100`}
                    >
                        Pterodactyl&reg;
                    </a>
                    &nbsp;&copy; 2015 - {new Date().getFullYear()}
                </p>
                <p css={tw`text-center text-neutral-300 text-xs`}>
                    {parser.toReact(copyright)}
                </p>
            </div>
        </div>
)});
