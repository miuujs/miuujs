/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import * as React from 'react';
import { useState, useEffect, useRef } from 'react';
import { Link, NavLink } from 'react-router-dom';
import { useStoreState } from 'easy-peasy';
import { ApplicationStore } from '@/state';
import SearchContainer from '@/components/dashboard/search/SearchContainer';
import tw from 'twin.macro';
import styled from 'styled-components/macro';
import http from '@/api/http';
import ServerSelector from '@/components/elements/ServerSelector';
import SpinnerOverlay from '@/components/elements/SpinnerOverlay';
import UserAvatar from '@/components/UserAvatar';
import DropdownMenu, { DropdownLinkRow, DropdownButtonRow } from '@/components/elements/DropdownMenu';
import { UserCircleIcon, CogIcon, EyeIcon, MoonIcon, LogoutIcon, MenuIcon, XIcon, ServerIcon, SupportIcon } from '@heroicons/react/outline';

import { useTranslation } from 'react-i18next';

interface Props {
    children?: React.ReactNode;
}
interface Dropdown {
    sideBar?: React.ReactNode;
}

const MobileLinks = styled.div`
    ${tw`flex flex-col gap-5 mb-2`};

    & > div{
        ${tw`flex flex-col gap-1`};

        & > span{
            ${tw`text-sm text-gray-300`};
        }

        & > a{
            ${tw`flex items-center gap-x-1 text-gray-200 duration-300 py-1`};

            & > svg{
                ${tw`text-gray-300 duration-300 w-5`};
            }

            &:hover,
            &:focus,
            &.active{
                ${tw`text-gray-50`};

                & > svg{
                    ${tw`text-arix`}
                }
            }
        }
    }
`;
const RightNavigation = styled.div`
    ${tw`lg:flex items-center gap-x-5 hidden`}

    & > a,
    & > button,
    & > .navigation-link {
        ${tw`flex items-center no-underline text-neutral-200 py-2 cursor-pointer transition-all duration-150 gap-x-1`};

        &:active,
        &:hover {
            ${tw`text-neutral-100`};
        }

        & > svg{
            ${tw`w-5`}
        }
    }
`;

const ClientDropdown = ({ sideBar }: Dropdown) => {
    const [isLoggingOut, setIsLoggingOut] = useState(false);
    const [isDarkMode, setIsDarkMode] = useState<boolean>(false);
    const onClickRef = useRef<DropdownMenu>(null);
    
    const { t } = useTranslation(['miuujs/navigation']);

    const modeToggler = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.modeToggler);
    const rootAdmin = useStoreState((state: ApplicationStore) => state.user.data!.rootAdmin);

    useEffect(() => {
        const storedMode = localStorage.getItem('darkMode');
        if (storedMode !== null) {
            setIsDarkMode(storedMode === 'true');
        }
    }, []);

    useEffect(() => {
        localStorage.setItem('darkMode', String(isDarkMode));
        document.body.classList.toggle('lightmode', isDarkMode);
    }, [isDarkMode]);

    const toggleDarkMode = () => {
        setIsDarkMode((prevMode) => !prevMode);
    };

    const onTriggerLogout = () => {
        setIsLoggingOut(true);
        http.post('/auth/logout').finally(() => {
            // @ts-expect-error this is valid
            window.location = '/';
        });
    };

    return(
        <DropdownMenu
            ref={onClickRef}
            sideBar={sideBar ? true : false}
            renderToggle={(onClick) => (
                <div onClick={onClick} className="cursor-pointer flex gap-x-2 items-center">
                    <UserAvatar /> 
                    <div>
                        <p>{t`account`}</p>
                    </div>
                </div>
            )}
        >
            <SpinnerOverlay visible={isLoggingOut} />
            <DropdownLinkRow href="/account">
                <UserCircleIcon className="w-5" /> <span className={'whitespace-nowrap'}>{t`account-overview`}</span>
            </DropdownLinkRow>
            {rootAdmin && <DropdownLinkRow href="/admin">
                <CogIcon className="w-5" /> {t`admin-area`}
            </DropdownLinkRow> }
            <DropdownLinkRow href="/account/activity">
                <EyeIcon className="w-5" /> {t`account-activity`}
            </DropdownLinkRow>
            {String(modeToggler) == 'true' &&
            <DropdownButtonRow onClick={toggleDarkMode}>
                <MoonIcon className="w-5" /> {t`dark-light-mode`}
            </DropdownButtonRow>}
            <hr className={'border-b border-gray-500 my-2'}/>
            <DropdownButtonRow danger onClick={onTriggerLogout}>
                <LogoutIcon className="w-5" /> {t`logout`}
            </DropdownButtonRow>
        </DropdownMenu>
    )
}

export default ({ children }: Props) => {
    const [isOpen, setIsOpen] = useState<boolean>(false);
    const [guildData, setGuildData] = useState<{ instant_invite: string } | null>(null);

    const { t } = useTranslation(['miuujs/navigation']);

    const name = useStoreState((state: ApplicationStore) => state.settings.data!.name);
    const layout = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.layout);
    const logo = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.logo);
    const logoHeight = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.logoHeight);
    const fullLogo = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.fullLogo);
    const searchComponent = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.searchComponent);
    const whatsapp = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.whatsapp);
    const support = useStoreState((state: ApplicationStore) => state.settings.data!.miuujs.support);

    return (
        <>
        <div className={`w-full px-4 overflow-x-auto !overflow-visible z-20 relative ${layout == 3 ? 'bg-gray-700 backdrop !border-0' : ''}`}>
            <div className={`mx-auto w-full flex items-center justify-between max-w-[1200px] py-2`}>
                <div className="flex gap-x-10 items-center">
                    {layout == 3 &&
                    <div className={'lg:flex hidden gap-x-2 items-center'}>
                        <Link to={'/'} className='flex gap-x-2 items-center font-semibold text-lg text-gray-50 py-2'>
                            <img src={logo} alt={name + 'logo'} css={`height:${logoHeight};`} />
                            {String(fullLogo) === 'false' && name}
                        </Link>
                    </div>
                    }
                    <div className={'lg:hidden flex gap-x-2 items-center'}>
                        <Link to={'/'} className='flex gap-x-2 items-center font-semibold text-lg text-gray-50 py-2'>
                            <img src={logo} alt={name + 'logo'} css={`height:${logoHeight};`} />
                            {String(fullLogo) === 'false' && name}
                        </Link>
                    </div>
                    <div className={'sm:block hidden'}>
                        {searchComponent == 1  
                        ? <ServerSelector />
                        : <SearchContainer /> }
                    </div>
                </div>
                <RightNavigation>
                    {whatsapp &&
                    <a href={whatsapp} target={'_blank'}>
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5">
                            <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
                        </svg>
                        WhatsApp
                    </a>}
                    {support && <a href={support}><SupportIcon className={'w-5'} />{t`supportcenter`}</a>}
                    {layout == 3 && <ClientDropdown />}
                </RightNavigation>
                <button onClick={() => setIsOpen((isOpen) => !isOpen)} className={'lg:hidden'}>
                    <MenuIcon className={'w-5'} />
                </button>
            </div>
        </div>
        {isOpen &&
            <div className={'fixed top-0 left-0 h-full w-full bg-gray-700 z-[99] backdrop-blur-xl px-4 py-2 flex flex-col overflow-y-auto text-xl'}>
                <div className={'flex justify-between items-center'}>
                    <div className={'flex gap-x-2 items-center'} onClick={() => setIsOpen((isOpen) => !isOpen)}>
                        <Link to={'/'} className='flex gap-x-2 items-center font-semibold text-lg text-gray-50 py-2'>
                            <img src={logo} alt={name + 'logo'} css={`height:${logoHeight};`} />
                            {String(fullLogo) === 'false' && name}
                        </Link>
                    </div>
                    <button onClick={() => setIsOpen((isOpen) => !isOpen)}>
                        <XIcon className={'w-5'} />
                    </button>
                </div>
                <MobileLinks onClick={() => setIsOpen((isOpen) => !isOpen)}>
                    <div>
                        <NavLink to={'/'} exact>
                            <ServerIcon/> {t`servers`}
                        </NavLink>
                        <NavLink to={'/account'} exact>
                            <UserCircleIcon/> {t`account`}
                        </NavLink>
                        {whatsapp &&
                        <a href={whatsapp} target={'_blank'}>
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5">
                                <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
                            </svg>
                            WhatsApp
                        </a>}
                        {support !== 'none' && <a href={support}><SupportIcon className={'w-5'} />{t`supportcenter`}</a>}
                    </div>
                    {children}
                </MobileLinks>
                <div className={'mt-auto'}>
                    <ClientDropdown sideBar/>
                </div>
            </div>
        }
        </>
    );
};
