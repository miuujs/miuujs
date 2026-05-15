import React, { useEffect, useState } from 'react';
import { Server } from '@/api/server/getServer';
import { ApplicationStore } from '@/state';
import getServers from '@/api/getServers';
import ServerCard from '@/components/dashboard/ServerCard';
import ServerCardBanner from '@/components/dashboard/ServerCardBanner';
import ServerCardGradient from '@/components/dashboard/ServerCardGradient';
import Spinner from '@/components/elements/Spinner';
import PageContentBlock from '@/components/elements/PageContentBlock';
import useFlash from '@/plugins/useFlash';
import { useStoreState } from 'easy-peasy';
import { usePersistedState } from '@/plugins/usePersistedState';
import Switch from '@/components/elements/Switch';
import tw from 'twin.macro';
import useSWR from 'swr';
import { LuChevronRight, LuCreditCard, LuLifeBuoy, LuRouter } from "react-icons/lu";
import { FiStar, FiGitBranch } from "react-icons/fi";
import { PaginatedResult } from '@/api/http';
import Pagination from '@/components/elements/Pagination';
import { useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';

export default () => {
    const { t } = useTranslation('arix/dashboard');
    const { search } = useLocation();
    const defaultPage = Number(new URLSearchParams(search).get('page') || '1');
    const [githubData, setGithubData] = useState<{ stargazers_count: number, forks_count: number } | null>(null);

    const [page, setPage] = useState(!isNaN(defaultPage) && defaultPage > 0 ? defaultPage : 1);
    const { clearFlashes, clearAndAddHttpError } = useFlash();
    const uuid = useStoreState((state) => state.user.data!.uuid);
    const rootAdmin = useStoreState((state) => state.user.data!.rootAdmin);
    const [showOnlyAdmin, setShowOnlyAdmin] = usePersistedState(`${uuid}:show_all_servers`, false);
    const githubBox = useStoreState((state: ApplicationStore) => state.settings.data!.arix.githubBox);
    const whatsapp = useStoreState((state: ApplicationStore) => state.settings.data!.arix.whatsapp);
    const billing = useStoreState((state: ApplicationStore) => state.settings.data!.arix.billing);
    const support = useStoreState((state: ApplicationStore) => state.settings.data!.arix.support);
    const status = useStoreState((state: ApplicationStore) => state.settings.data!.arix.status);
    const socialButtons = useStoreState((state: ApplicationStore) => state.settings.data!.arix.socialButtons);
    const serverRow = useStoreState((state: ApplicationStore) => state.settings.data!.arix.serverRow);

    const { data: servers, error } = useSWR<PaginatedResult<Server>>(
        ['/api/client/servers', showOnlyAdmin && rootAdmin, page],
        () => getServers({ page, type: showOnlyAdmin && rootAdmin ? 'admin' : undefined })
    );

    useEffect(() => {
        if (!servers) return;
        if (servers.pagination.currentPage > 1 && !servers.items.length) {
            setPage(1);
        }
    }, [servers?.pagination.currentPage]);

    useEffect(() => {
        // Don't use react-router to handle changing this part of the URL, otherwise it
        // triggers a needless re-render. We just want to track this in the URL incase the
        // user refreshes the page.
        window.history.replaceState(null, document.title, `/${page <= 1 ? '' : `?page=${page}`}`);
    }, [page]);

    useEffect(() => {
        if (error) clearAndAddHttpError({ key: 'dashboard', error });
        if (!error) clearFlashes('dashboard');
    }, [error]);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const response = await fetch('https://api.github.com/repos/miuujs/miuujs');

                if (!response.ok) {
                    throw new Error('Failed to fetch GitHub data');
                }

            const data = await response.json();
                setGithubData(data);
            } catch (error) {
                console.error('Error fetching GitHub data:', error);
            }
        };

        fetchData();
    }, []);

    return (
        <PageContentBlock title={'Dashboard'} showFlashKey={'dashboard'}>
            {String(socialButtons) == 'true' &&
            <div className={'flex lg:gap-4 gap-2 lg:flex-row flex-col mb-4'}>
                {whatsapp &&
                    <a href={whatsapp} target="_blank" className={'group w-full bg-gray-700 backdrop rounded-box flex items-center justify-between px-6 py-5'}>
                        <div>
                            <p className={'font-medium text-gray-100 flex items-center'}>
                                WhatsApp
                                <LuChevronRight className={'opacity-0 ml-0 group-hover:opacity-75 group-hover:ml-2 duration-300'} />
                            </p>
                            <span className={'font-light text-sm text-gray-200'}>{t('join-our-whatsapp')}</span>
                        </div>
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="text-[2.5rem] text-arix">
                            <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
                        </svg>
                    </a>
                }
                {billing &&
                    <a href={billing} target="_blank" className={'group w-full bg-gray-700 backdrop rounded-box flex items-center justify-between px-6 py-5'}>
                        <div>
                            <p className={'font-medium text-gray-100 flex items-center'}>
                                {t('billing-area')}
                                <LuChevronRight className={'opacity-0 ml-0 group-hover:opacity-75 group-hover:ml-2 duration-300'} />
                            </p>
                            <span className={'font-light text-sm text-gray-200'}>{t('manage-your-services')}</span>
                        </div>
                        <LuCreditCard className={'text-[2.5rem] text-arix'}/>
                    </a>
                }
                {support &&
                    <a href={support} target="_blank" className={'group w-full bg-gray-700 backdrop rounded-box flex items-center justify-between px-6 py-5'}>
                        <div>
                            <p className={'font-medium text-gray-100 flex items-center'}>
                                {t('supportcenter')}
                                <LuChevronRight className={'opacity-0 ml-0 group-hover:opacity-75 group-hover:ml-2 duration-300'} />
                            </p>
                            <span className={'font-light text-sm text-gray-200'}>{t('get-support')}</span>
                        </div>
                        <LuLifeBuoy className={'text-[2.5rem] text-arix'}/>
                    </a>
                }
                {status &&
                    <a href={status} target="_blank" className={'group w-full bg-gray-700 backdrop rounded-box flex items-center justify-between px-6 py-5'}>
                        <div>
                            <p className={'font-medium text-whgray-100ite flex items-center'}>
                                {t('server-status')}
                                <LuChevronRight className={'opacity-0 ml-0 group-hover:opacity-75 group-hover:ml-2 duration-300'} />
                            </p>
                            <span className={'font-light text-sm text-gray-200'}>{t('check-server-status')}</span>
                        </div>
                        <LuRouter className={'text-[2.5rem] text-arix'}/>
                    </a>
                }
            </div>}
            <div className={'flex gap-4 md:flex-nowrap flex-wrap mb-6'}>
                <div className={'bg-gray-700 backdrop rounded-box px-6 py-5 w-full flex items-center justify-between'}>
                    <div>
                        <p className={'text-gray-50'}>{t('welcome-back')}</p>
                        <p className={'font-light'}>{t('all-servers-you-have-access-to')}</p>
                    </div>
                    {rootAdmin && (
                        <div css={tw`flex justify-end items-center`}>
                            <p css={tw`uppercase text-xs text-neutral-400 mr-2`}>
                                {showOnlyAdmin ? t('others-servers') : t('your-servers')}
                            </p>
                            <Switch
                                name={'show_all_servers'}
                                defaultChecked={showOnlyAdmin}
                                onChange={() => setShowOnlyAdmin((s) => !s)}
                            />
                        </div>
                    )}
                </div>
                {String(githubBox) == 'true' &&
                <a href="https://github.com/miuujs/miuujs" target="_blank" className={'group max-w-[275px] w-full border border-[#333] hover:border-[#666] rounded-box flex items-center justify-between px-6 py-5 duration-300'} css={'background-image:radial-gradient(circle, rgba(29,29,55,1) 0%, rgba(4,5,25,1) 100%);'}>
                    <div>
                        <span className={'font-light text-sm text-white/70'}>{githubData ? githubData.stargazers_count : '0'} stars</span>
                        <p className={'font-medium text-white'}>{t('view-on-github')}</p>
                    </div>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-8 h-8 text-white/70 group-hover:text-white duration-300">
                        <path d="M12 0C5.374 0 0 5.373 0 12c0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z"/>
                    </svg>
                </a>}
            </div>
            {!servers ? (
                <Spinner centered size={'large'} />
            ) : (
                <div className="grid lg:grid-cols-2 gap-4">
                    <Pagination data={servers} onPageSelect={setPage}>
                            {({ items }) =>
                                items.length > 0 ? (
                                    items.map((server, index) => (
                                        serverRow == 1 
                                            ? <ServerCardGradient key={server.uuid} server={server} css={index > 0 ? tw`mt-2` : undefined} />
                                            : serverRow == 2
                                            ? <ServerCardBanner key={server.uuid} server={server} css={index > 0 ? tw`mt-2` : undefined} />
                                            : serverRow == 3
                                            && <ServerCard key={server.uuid} server={server} css={index > 0 ? tw`mt-2` : undefined} />
                                    ))
                                ) : (
                                    <p css={tw`text-center text-sm text-neutral-400 lg:col-span-2 col-span-1`}>
                                        {showOnlyAdmin
                                            ? t('there-are-no-servers')
                                            : t('there-are-no-servers-associated')}
                                    </p>
                                )
                            }
                    </Pagination>
                </div>
            )}
        </PageContentBlock>
    );
};
