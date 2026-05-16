import React, { useState, useEffect } from 'react';
import ContentBox from '@/components/elements/ContentBox';
import PageContentBlock from '@/components/elements/PageContentBlock';
import http from '@/api/http';
import Spinner from '@/components/elements/Spinner';
import Button from '@/components/elements/Button';
import Input from '@/components/elements/Input';
import Label from '@/components/elements/Label';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCoins, faServer, faCalendarTimes, faTimes, faPlus, faWallet, faMicrochip, faMemory, faHdd } from '@fortawesome/free-solid-svg-icons';
import styled from 'styled-components/macro';
import tw from 'twin.macro';
import { useStoreActions } from 'easy-peasy';
import { Actions, ApplicationStore } from '@/state';

const ProductCard = styled.div`
    ${tw`bg-gray-700 rounded-box overflow-hidden transition-all duration-200`};
    &:hover {
        ${tw`shadow-lg transform -translate-y-0.5`};
    }

    .card-banner {
        ${tw`w-full relative px-4 pt-3 z-10`};

        .banner-bg {
            height: 48px;
            ${tw`w-full absolute top-0 left-0 z-[-1]`};
        }

        .card-avatar {
            ${tw`w-[44px] h-[44px] rounded-component border-4 border-gray-700 overflow-hidden bg-gray-700`};
            
            img, svg {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
        }
    }

    .card-body {
        ${tw`px-4 py-3`};
    }
`;

const SpecBadge = styled.div`
    ${tw`inline-flex items-center gap-1 text-xs text-neutral-400 bg-neutral-900 px-2 py-0.5 rounded`};
    
    svg {
        ${tw`text-cyan-500 text-[10px]`};
    }
`;

const ModalOverlay = styled.div`
    ${tw`fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4`};
`;

const ModalBox = styled.div<{ maxW?: string }>`
    ${tw`bg-neutral-800 border border-neutral-700 rounded-box p-6 shadow-2xl w-full`};
    max-width: ${props => props.maxW || '28rem'};
    max-height: 90vh;
    overflow-y: auto;
`;

const DEFAULT_PRODUCT_IMAGE = 'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61';

const ProductAvatar = ({ image, seed }: { image?: string; seed: string }) => {
    const src = image || DEFAULT_PRODUCT_IMAGE;
    return <img src={src} alt={seed} />;
};

export default () => {
    const [loading, setLoading] = useState(true);
    const [balance, setBalance] = useState(0);
    const [products, setProducts] = useState<any[]>([]);
    const [eggs, setEggs] = useState<Record<string, any[]>>({});
    const [selectedEggId, setSelectedEggId] = useState<number | null>(null);
    const [myServers, setMyServers] = useState<any[]>([]);
    const [confirmProduct, setConfirmProduct] = useState<any>(null);
    const [topUpOpen, setTopUpOpen] = useState(false);
    const [topUpAmount, setTopUpAmount] = useState(10000);
    const [topUpMethod, setTopUpMethod] = useState('QRIS');
    const [paymentData, setPaymentData] = useState<any>(null);

    const { addFlash } = useStoreActions((actions: Actions<ApplicationStore>) => actions.flashes);

    const fetchData = () => {
        setLoading(true);
        http.get('/api/client/products')
            .then(({ data }) => {
                setBalance(data.balance);
                setProducts(data.products);
                setEggs(data.eggs || {});
                setMyServers(data.servers);
                setLoading(false);
            })
            .catch(console.error);
    };

    useEffect(() => { fetchData(); }, []);

    const confirmBuy = () => {
        if (!confirmProduct || !selectedEggId) return;
        setLoading(true);
        setConfirmProduct(null);
        http.post('/api/client/products/buy', { product_id: confirmProduct.id, egg_id: selectedEggId })
            .then(() => {
                addFlash({ type: 'success', title: 'Success', message: 'Server ordered successfully! Check your dashboard.' });
                fetchData();
            })
            .catch(error => {
                addFlash({ type: 'error', title: 'Error', message: error.response?.data?.error || 'Failed to order server.' });
                setLoading(false);
            });
    };

    const onTopUp = () => {
        setLoading(true);
        setTopUpOpen(false);
        http.post('/api/client/products/pay', { amount: topUpAmount, method: topUpMethod })
            .then(({ data }) => { setPaymentData(data.payment_data); setLoading(false); })
            .catch(error => {
                addFlash({ type: 'error', title: 'Error', message: error.response?.data?.error || 'Payment failed' });
                setLoading(false);
            });
    };

    const eggCount = Object.values(eggs).reduce((sum, arr) => sum + arr.length, 0);

    if (loading && balance === 0 && products.length === 0) return <Spinner centered />;

    return (
        <PageContentBlock title={'Products'}>
            <div className={'grid grid-cols-1 md:grid-cols-3 gap-6'}>
                <div className={'md:col-span-1 space-y-6'}>
                    <ContentBox title={'My Balance'}>
                        <div className={'flex items-center justify-between'}>
                            <div>
                                <p className={'text-sm text-neutral-400 uppercase'}>Current Balance</p>
                                <p className={'text-3xl font-bold text-yellow-500'}>Rp {Number(balance).toLocaleString()}</p>
                            </div>
                            <FontAwesomeIcon icon={faCoins} className={'text-4xl text-neutral-600'} />
                        </div>
                        <Button className={'w-full mt-4'} onClick={() => setTopUpOpen(true)}>
                            <FontAwesomeIcon icon={faPlus} className={'mr-2'} /> Top Up Balance
                        </Button>
                    </ContentBox>

                    <ContentBox title={'My Active Servers'}>
                        {myServers.length === 0 ? <p className={'text-center text-neutral-400 py-4'}>No servers purchased yet.</p> : (
                            <div className={'space-y-2'}>
                                {myServers.map(s => (
                                    <div key={s.id} className={'flex items-center justify-between bg-neutral-900 p-3 rounded'}>
                                        <div className={'flex items-center'}>
                                            <FontAwesomeIcon icon={faServer} className={'mr-3 text-neutral-500'} />
                                            <div><p className={'font-bold'}>{s.name}</p><p className={'text-xs text-neutral-400'}>{s.uuidShort}</p></div>
                                        </div>
                                        <div className={'text-right'}>
                                            <p className={'text-xs text-neutral-400 uppercase'}>Expires On</p>
                                            <p className={'text-sm text-red-400'}><FontAwesomeIcon icon={faCalendarTimes} className={'mr-1'} />{new Date(s.expires_at).toLocaleDateString()}</p>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </ContentBox>
                </div>

                <div className={'md:col-span-2 space-y-6'}>
                    <ContentBox title={'Available Products'}>
                        {products.length === 0 ? <p className={'text-center text-neutral-400 py-8'}>No products available.</p> : (
                            <div className={'grid lg:grid-cols-2 gap-4'}>
                                {products.map(p => (
                                    <ProductCard key={p.id}>
                                        <div className={'card-banner'}>
                                            <div className={'banner-bg'} style={{ background: p.image ? `url(${p.image}) center/cover` : `linear-gradient(90deg, var(--primary) 0%, color-mix(in srgb, var(--primary) 25%, transparent) 100%)` }} />
                                            <div className={'card-avatar'}>
                                                <ProductAvatar image={p.image} seed={p.name} />
                                            </div>
                                        </div>
                                        <div className={'card-body'}>
                                            <h3 className={'text-gray-300 font-medium'}>{p.name}</h3>
                                            {p.description && <p className={'text-xs text-neutral-400 mt-0.5'}>{p.description}</p>}
                                            <p className={'text-lg text-cyan-500 font-bold mt-1 mb-2'}>Rp {Number(p.price).toLocaleString()}</p>
                                            <div className={'flex flex-wrap gap-1.5 mb-3'}>
                                                {p.ram > 0 && <SpecBadge><FontAwesomeIcon icon={faMemory} /> {p.ram}MB</SpecBadge>}
                                                {p.disk > 0 && <SpecBadge><FontAwesomeIcon icon={faHdd} /> {p.disk}MB</SpecBadge>}
                                                {p.cpu > 0 && <SpecBadge><FontAwesomeIcon icon={faMicrochip} /> {p.cpu}%</SpecBadge>}
                                            </div>
                                            <Button className={'w-full'} onClick={() => { setConfirmProduct(p); setSelectedEggId(null); }}>Buy Now</Button>
                                        </div>
                                    </ProductCard>
                                ))}
                            </div>
                        )}
                    </ContentBox>
                </div>
            </div>

            {confirmProduct && (
                <ModalOverlay>
                    <ModalBox maxW={'32rem'}>
                        <div className={'flex items-start gap-4 mb-5'}>
                            <div className={'w-16 h-16 rounded-lg overflow-hidden bg-neutral-700 flex-shrink-0'}>
                                <ProductAvatar image={confirmProduct.image} seed={confirmProduct.name} />
                            </div>
                            <div className={'flex-1 min-w-0'}>
                                <div className={'flex items-center justify-between'}>
                                    <h3 className={'text-xl font-bold truncate'}>{confirmProduct.name}</h3>
                                    <button onClick={() => setConfirmProduct(null)} className={'text-neutral-400 hover:text-white ml-2 flex-shrink-0'}><FontAwesomeIcon icon={faTimes} /></button>
                                </div>
                                {confirmProduct.description && <p className={'text-sm text-neutral-400 mt-0.5'}>{confirmProduct.description}</p>}
                                <p className={'text-2xl text-yellow-500 font-bold mt-1'}>Rp {Number(confirmProduct.price).toLocaleString()}</p>
                                <div className={'flex flex-wrap gap-1.5 mt-2'}>
                                    {confirmProduct.cpu > 0 && <SpecBadge><FontAwesomeIcon icon={faMicrochip} /> {confirmProduct.cpu}%</SpecBadge>}
                                    {confirmProduct.ram > 0 && <SpecBadge><FontAwesomeIcon icon={faMemory} /> {confirmProduct.ram}MB</SpecBadge>}
                                    {confirmProduct.disk > 0 && <SpecBadge><FontAwesomeIcon icon={faHdd} /> {confirmProduct.disk}MB</SpecBadge>}
                                </div>
                            </div>
                        </div>

                        <div className={'border-t border-neutral-700 pt-4'}>
                            <Label className={'text-sm mb-1.5 block'}>Choose Server Type</Label>
                            {eggCount === 0 ? (
                                <p className={'text-sm text-red-400'}>No server types available.</p>
                            ) : (
                                <select
                                    className={'w-full p-2.5 bg-neutral-900 border border-neutral-700 rounded text-neutral-200 text-sm'}
                                    value={selectedEggId ?? ''}
                                    onChange={(e: any) => setSelectedEggId(Number(e.target.value))}
                                >
                                    <option value={''} disabled>Select a server type...</option>
                                    {Object.entries(eggs).map(([nestName, nestEggs]) => (
                                        <optgroup key={nestName} label={nestName}>
                                            {nestEggs.map((egg: any) => (
                                                <option key={egg.id} value={egg.id}>{egg.name}</option>
                                            ))}
                                        </optgroup>
                                    ))}
                                </select>
                            )}
                        </div>

                        <div className={'flex gap-3 mt-5'}>
                            <Button isSecondary className={'flex-1'} onClick={() => setConfirmProduct(null)}>Cancel</Button>
                            <Button className={'flex-1'} onClick={confirmBuy} disabled={!selectedEggId}>Confirm Purchase</Button>
                        </div>
                    </ModalBox>
                </ModalOverlay>
            )}

            {topUpOpen && (
                <ModalOverlay>
                    <ModalBox>
                        <div className={'flex items-center justify-between mb-4'}>
                            <h3 className={'text-xl font-bold'}>Top Up Balance</h3>
                            <button onClick={() => setTopUpOpen(false)} className={'text-neutral-400 hover:text-white'}><FontAwesomeIcon icon={faTimes} /></button>
                        </div>
                        <div className={'space-y-4'}>
                            <div>
                                <Label>Amount (Rp)</Label>
                                <Input type={'number'} value={topUpAmount} onChange={(e: any) => setTopUpAmount(Number(e.target.value))} />
                            </div>
                            <div>
                                <Label>Payment Method</Label>
                                <select className={'w-full p-2.5 bg-neutral-900 border border-neutral-700 rounded text-neutral-200 text-sm'} value={topUpMethod} onChange={(e: any) => setTopUpMethod(e.target.value)}>
                                    <option value={'QRIS'}>QRIS (OVO, Dana, Shopee, etc)</option>
                                    <option value={'BCA'}>BCA Virtual Account</option>
                                    <option value={'BNI'}>BNI Virtual Account</option>
                                    <option value={'BRI'}>BRI Virtual Account</option>
                                </select>
                            </div>
                            <Button className={'w-full'} onClick={onTopUp}>
                                <FontAwesomeIcon icon={faWallet} className={'mr-2'} /> Proceed to Payment
                            </Button>
                        </div>
                    </ModalBox>
                </ModalOverlay>
            )}

            {paymentData && (
                <ModalOverlay>
                    <ModalBox>
                        <div className={'text-center space-y-4'}>
                            <h3 className={'text-xl font-bold'}>Complete Payment</h3>
                            {topUpMethod === 'QRIS'
                                ? <div className={'bg-white p-4 rounded-lg inline-block'}><img src={'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=' + encodeURIComponent(paymentData.qr_content)} alt={'QR Code'} /></div>
                                : <><p className={'text-neutral-400'}>Transfer to Virtual Account:</p><p className={'text-3xl font-mono font-bold text-cyan-500 break-all'}>{paymentData.va_number}</p><p className={'text-sm text-neutral-400'}>Bank: {topUpMethod}</p></>}
                            <p className={'text-xs text-yellow-500 italic'}>Balance will be added automatically after payment is confirmed.</p>
                            <Button isSecondary className={'w-full'} onClick={() => { setPaymentData(null); fetchData(); }}>Close</Button>
                        </div>
                    </ModalBox>
                </ModalOverlay>
            )}
        </PageContentBlock>
    );
};
