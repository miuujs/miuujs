import React, { useState, useEffect } from 'react';
import ContentBox from '@/components/elements/ContentBox';
import PageContentBlock from '@/components/elements/PageContentBlock';
import http from '@/api/http';
import Spinner from '@/components/elements/Spinner';
import Button from '@/components/elements/Button';
import Input from '@/components/elements/Input';
import Label from '@/components/elements/Label';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCoins, faServer, faCalendarTimes, faCubes, faCheckCircle, faExclamationCircle, faTimes } from '@fortawesome/free-solid-svg-icons';
import styled from 'styled-components/macro';
import tw from 'twin.macro';

const PlanCard = styled.div`
    ${tw`bg-neutral-800 border-2 border-neutral-700 rounded-lg p-6 transition-all duration-200 hover:border-cyan-500`};
`;

const Toast = styled.div<{ $type: 'success' | 'error' }>`
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem 1.25rem;
    margin-bottom: 1rem;
    border-radius: var(--rounded-box, 0.5rem);
    font-size: 0.875rem;
    font-weight: 500;
    background: ${props => props.$type === 'success' ? 'color-mix(in srgb, var(--green) 20%, transparent)' : 'color-mix(in srgb, var(--red) 20%, transparent)'};
    color: ${props => props.$type === 'success' ? 'var(--green)' : 'var(--red)'};
    border: 1px solid ${props => props.$type === 'success' ? 'color-mix(in srgb, var(--green) 40%, transparent)' : 'color-mix(in srgb, var(--red) 40%, transparent)'};
`;

const ConfirmOverlay = styled.div`
    ${tw`fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4`};
`;

const ConfirmBox = styled.div`
    background: var(--bg-secondary, #262626);
    border: 1px solid var(--border, #404040);
    border-radius: var(--rounded-box, 0.5rem);
    padding: 1.5rem;
    max-width: 24rem;
    width: 100%;
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
`;

export default () => {
    const [loading, setLoading] = useState(true);
    const [balance, setBalance] = useState(0);
    const [products, setProducts] = useState<any[]>([]);
    const [nests, setNests] = useState<any[]>([]);
    const [selectedEgg, setSelectedEgg] = useState<number>(0);
    const [amount, setAmount] = useState(10000);
    const [method, setMethod] = useState('QRIS');
    const [paymentData, setPaymentData] = useState<any>(null);
    const [myServers, setMyServers] = useState<any[]>([]);
    const [confirmProduct, setConfirmProduct] = useState<any>(null);
    const [toast, setToast] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

    const showToast = (type: 'success' | 'error', message: string) => {
        setToast({ type, message });
        setTimeout(() => setToast(null), 4000);
    };

    const fetchStoreData = () => {
        setLoading(true);
        http.get('/api/client/store')
            .then(({ data }) => {
                setBalance(data.balance);
                setProducts(data.products);
                setNests(data.nests);
                setMyServers(data.servers);
                if (data.nests.length > 0 && data.nests[0].eggs.length > 0) {
                    setSelectedEgg(data.nests[0].eggs[0].id);
                }
                setLoading(false);
            })
            .catch(console.error);
    };

    useEffect(() => { fetchStoreData(); }, []);

    const onPay = () => {
        setLoading(true);
        http.post('/api/client/store/pay', { amount, method })
            .then(({ data }) => { setPaymentData(data.payment_data); setLoading(false); })
            .catch(error => { showToast('error', error.response?.data?.error || 'Payment failed'); setLoading(false); });
    };

    const onBuy = (product: any) => {
        if (selectedEgg === 0) return showToast('error', 'Silakan pilih tipe server (Egg) terlebih dahulu.');
        setConfirmProduct(product);
    };

    const confirmBuy = () => {
        if (!confirmProduct) return;
        setConfirmProduct(null);
        setLoading(true);
        http.post('/api/client/store/buy', { product_id: confirmProduct.id, egg_id: selectedEgg })
            .then(() => { showToast('success', 'Server berhasil dipesan! Silakan cek dashboard.'); fetchStoreData(); })
            .catch(error => { showToast('error', error.response?.data?.error || 'Gagal memesan server.'); setLoading(false); });
    };

    if (loading && !paymentData && balance === 0) return <Spinner centered />;

    return (
        <PageContentBlock title={'Store & Billing'}>
            <div className={'grid grid-cols-1 md:grid-cols-3 gap-6'}>
                <div className={'md:col-span-1 space-y-6'}>
                    <ContentBox title={'Saldo Saya'}>
                        <div className={'flex items-center justify-between'}>
                            <div>
                                <p className={'text-sm text-neutral-400 uppercase'}>Saldo Saat Ini</p>
                                <p className={'text-3xl font-bold font-header text-yellow-500'}>Rp {Number(balance).toLocaleString()}</p>
                            </div>
                            <FontAwesomeIcon icon={faCoins} className={'text-4xl text-neutral-600'} />
                        </div>
                    </ContentBox>

                    <ContentBox title={'Tipe Server'}>
                        <div className={'space-y-4'}>
                            <Label>Pilih Jenis Server</Label>
                            <select 
                                className={'w-full p-2 bg-neutral-900 border border-neutral-700 rounded text-neutral-200'}
                                value={selectedEgg}
                                onChange={(e) => setSelectedEgg(Number(e.target.value))}
                            >
                                {nests.map(nest => (
                                    <optgroup key={nest.id} label={nest.name}>
                                        {nest.eggs.map((egg: any) => (
                                            <option key={egg.id} value={egg.id}>{egg.name}</option>
                                        ))}
                                    </optgroup>
                                ))}
                            </select>
                            <p className={'text-xs text-neutral-400 italic'}>Tipe server ini menentukan software yang akan diinstal (misal: Minecraft, NodeJS, dll).</p>
                        </div>
                    </ContentBox>

                    <ContentBox title={'Top Up Saldo'}>
                        <div className={'space-y-4'}>
                            <Label>Nominal</Label>
                            <Input type={'number'} value={amount} onChange={(e: any) => setAmount(Number(e.target.value))} />
                            <Label>Metode Pembayaran</Label>
                            <select className={'w-full p-2 bg-neutral-900 border border-neutral-700 rounded text-neutral-200'} value={method} onChange={(e: any) => setMethod(e.target.value)}>
                                <option value={'QRIS'}>QRIS (OVO, Dana, Shopee, dll)</option>
                                <option value={'BCA'}>BCA Virtual Account</option>
                                <option value={'BNI'}>BNI Virtual Account</option>
                                <option value={'BRI'}>BRI Virtual Account</option>
                            </select>
                            <Button className={'w-full'} onClick={onPay}>Deposit Sekarang</Button>
                        </div>
                    </ContentBox>
                </div>

                <div className={'md:col-span-2 space-y-6'}>
                    <div className={'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4'}>
                        {products.map(p => (
                            <PlanCard key={p.id}>
                                <h3 className={'text-xl font-bold'}>{p.name}</h3>
                                <p className={'text-2xl text-cyan-500 font-header mb-4'}>Rp {Number(p.price).toLocaleString()}</p>
                                <ul className={'text-sm text-neutral-400 space-y-2 mb-6'}>
                                    <li>{p.ram}MB RAM</li>
                                    <li>{p.disk}MB SSD</li>
                                    <li>{p.cpu}% CPU</li>
                                </ul>
                                <Button className={'w-full'} onClick={() => onBuy(p)}>Beli</Button>
                            </PlanCard>
                        ))}
                    </div>
                    <ContentBox title={'Server Aktif Saya'}>
                        {myServers.length === 0 ? <p className={'text-center text-neutral-400 py-4'}>Belum ada server yang dibeli.</p> : (
                            <div className={'space-y-2'}>
                                {myServers.map(s => (
                                    <div key={s.id} className={'flex items-center justify-between bg-neutral-900 p-3 rounded'}>
                                        <div className={'flex items-center'}>
                                            <FontAwesomeIcon icon={faServer} className={'mr-3 text-neutral-500'} />
                                            <div><p className={'font-bold'}>{s.name}</p><p className={'text-xs text-neutral-400'}>{s.uuidShort}</p></div>
                                        </div>
                                        <div className={'text-right'}>
                                            <p className={'text-xs text-neutral-400 uppercase'}>Berakhir Pada</p>
                                            <p className={'text-sm text-red-400'}><FontAwesomeIcon icon={faCalendarTimes} className={'mr-1'} />{new Date(s.expires_at).toLocaleDateString()}</p>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </ContentBox>
                </div>
            </div>
            {toast && (
                <div className={'fixed top-5 right-5 z-50 animate__animated animate__fadeIn'}>
                    <Toast $type={toast.type}>
                        <FontAwesomeIcon icon={toast.type === 'success' ? faCheckCircle : faExclamationCircle} />
                        <span className={'flex-1'}>{toast.message}</span>
                        <button onClick={() => setToast(null)} className={'text-current opacity-60 hover:opacity-100'}><FontAwesomeIcon icon={faTimes} /></button>
                    </Toast>
                </div>
            )}

            {confirmProduct && (
                <ConfirmOverlay>
                    <ConfirmBox>
                        <div className={'text-center space-y-4'}>
                            <FontAwesomeIcon icon={faCubes} className={'text-4xl text-cyan-500'} />
                            <h3 className={'text-xl font-bold font-header'}>{confirmProduct.name}</h3>
                            <p className={'text-2xl text-yellow-500 font-header'}>Rp {Number(confirmProduct.price).toLocaleString()}</p>
                            <p className={'text-sm text-neutral-400'}>Saldo akan dipotong setelah konfirmasi.</p>
                            <div className={'flex gap-3'}>
                                <Button isSecondary className={'flex-1'} onClick={() => setConfirmProduct(null)}>Batal</Button>
                                <Button className={'flex-1'} onClick={confirmBuy}>Konfirmasi</Button>
                            </div>
                        </div>
                    </ConfirmBox>
                </ConfirmOverlay>
            )}

            {paymentData && (
                <div className={'fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4'}>
                    <div className={'max-w-md w-full'}>
                        <ContentBox title={'Selesaikan Pembayaran'}>
                            <div className={'text-center space-y-4'}>
                                {method === 'QRIS' ? <div className={'bg-white p-4 inline-block rounded'}><img src={'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=' + encodeURIComponent(paymentData.qr_content)} /></div> :
                                    <><p>Transfer ke Virtual Account:</p><p className={'text-4xl font-mono font-bold text-cyan-500'}>{paymentData.va_number}</p><p className={'text-sm text-neutral-400'}>Bank: {method}</p></>}
                                <p className={'text-xs text-yellow-500 italic'}>Saldo akan bertambah otomatis.</p>
                                <Button isSecondary className={'w-full'} onClick={() => setPaymentData(null)}>Tutup</Button>
                            </div>
                        </ContentBox>
                    </div>
                </div>
            )}
        </PageContentBlock>
    );
};
