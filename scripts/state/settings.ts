import { action, Action } from 'easy-peasy';

export interface SiteSettings {
    name: string;
    locale: string;
    arix: {
        logo: string,
        fullLogo: boolean,
        logoHeight: string,
        announcementType: string,
        announcementCloseable: boolean,
        announcementMessage: string,
        serverRow: number,
        socialButtons: boolean,
        githubBox: boolean,
        statsCards: number,
        sideGraphs: number,
        graphs: number,
        slot1: string,
        slot2: string,
        slot3: string,
        slot4: string,
        slot5: string,
        slot6: string,
        slot7: string,
        whatsapp: string,
        discord: string,
        support: string,
        status: string,
        billing: string,
        layout: number,
        searchComponent: number,
        logoPosition: number,
        socialPosition: number,
        loginLayout: number,
        backgroundImage: string,
        backdrop: boolean,
        backdropPercentage: string,
        defaultMode: string,
        modeToggler: boolean,
        langSwitch: boolean,
        copyright: string,
        radiusInput: string,
        borderInput: boolean,
        radiusBox: string,
        flashMessage: number,
        pageTitle: boolean,
        loginBackground: string,
        loginGradient: boolean,
        profileType: string,
        ipFlag: boolean;
        lowResourcesAlert: boolean;
        primary: string,
    };
    recaptcha: {
        enabled: boolean;
        siteKey: string;
    };
}

export interface SettingsStore {
    data?: SiteSettings;
    setSettings: Action<SettingsStore, SiteSettings>;
}

const settings: SettingsStore = {
    data: undefined,

    setSettings: action((state, payload) => {
        state.data = payload;
    }),
};

export default settings;