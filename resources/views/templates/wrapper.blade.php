<!DOCTYPE html>
<html>
    <head>
        <title>{{ config('app.name', 'Pterodactyl') }}</title>

        @section('meta')
            <meta charset="utf-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
            <meta name="csrf-token" content="{{ csrf_token() }}">

            @if(!empty($siteConfiguration['miuujs']))
            <meta name="theme-color" content="{{ $siteConfiguration['miuujs']['meta_color'] }}"/>
            <link rel="icon" type="image/x-icon" href="{{ $siteConfiguration['miuujs']['meta_favicon'] }}">
            <meta name="title" content="{{ $siteConfiguration['miuujs']['meta_title'] }}" />
            <meta name="description" content="{{ $siteConfiguration['miuujs']['meta_description'] }}" />
            <meta property="og:type" content="website" />
            <meta property="og:url" content="{{config('app.url', 'https://localhost')}}" />
            <meta property="og:title" content="{{ $siteConfiguration['miuujs']['meta_title'] }}" />
            <meta property="og:description" content="{{ $siteConfiguration['miuujs']['meta_description'] }}" />
            <meta property="og:image" content="{{ $siteConfiguration['miuujs']['meta_image'] }}" />
            <meta property="twitter:card" content="summary_large_image" />
            <meta property="twitter:url" content="{{config('app.url', 'https://localhost')}}" />
            <meta property="twitter:title" content="{{ $siteConfiguration['miuujs']['meta_title'] }}" />
            <meta property="twitter:description" content="{{ $siteConfiguration['miuujs']['meta_description'] }}" />
            <meta property="twitter:image" content="{{ $siteConfiguration['miuujs']['meta_image'] }}" />
            @endif

            <link rel="apple-touch-icon" sizes="180x180" href="/favicons/apple-touch-icon.png">
            <link rel="icon" type="image/png" href="/favicons/favicon-32x32.png" sizes="32x32">
            <link rel="icon" type="image/png" href="/favicons/favicon-16x16.png" sizes="16x16">
            <link rel="manifest" href="/favicons/manifest.json">
            <link rel="mask-icon" href="/favicons/safari-pinned-tab.svg" color="#bc6e3c">
            <link rel="shortcut icon" href="/favicons/favicon.ico">
            <meta name="msapplication-config" content="/favicons/browserconfig.xml">
        @show

        @section('user-data')
            @if(!is_null(Auth::user()))
                <script>
                    window.PterodactylUser = {!! json_encode(Auth::user()->toVueObject()) !!};
                </script>
            @endif
            @if(!empty($siteConfiguration))
                <script>
                    window.SiteConfiguration = {!! json_encode($siteConfiguration) !!};
                </script>
            @endif
        @show
        @if(!empty($siteConfiguration['miuujs']))
        <style>
            :root{
                <?php if ($siteConfiguration['miuujs']['borderInput']) {
                    echo '--borderInput: 1px solid;
';  }?>
                --radiusBox: {{ $siteConfiguration['miuujs']['radiusBox'] }};
                --radiusInput: {{ $siteConfiguration['miuujs']['radiusInput'] }};
            }

            <?php if ($siteConfiguration['miuujs']['defaultMode'] === 'darkmode') {
                echo ':root';
            } else {
                echo '.lightmode';
            }?>{
                --image: url({{ $siteConfiguration['miuujs']['backgroundImage'] }});
                --primary: {{ $siteConfiguration['miuujs']['primary'] }};
                --successText: {{ $siteConfiguration['miuujs']['successText'] }};
                --successBorder: {{ $siteConfiguration['miuujs']['successBorder'] }};
                --successBackground: {{ $siteConfiguration['miuujs']['successBackground'] }};
                --dangerText: {{ $siteConfiguration['miuujs']['dangerText'] }};
                --dangerBorder: {{ $siteConfiguration['miuujs']['dangerBorder'] }};
                --dangerBackground: {{ $siteConfiguration['miuujs']['dangerBackground'] }};
                --secondaryText: {{ $siteConfiguration['miuujs']['secondaryText'] }};
                --secondaryBorder: {{ $siteConfiguration['miuujs']['secondaryBorder'] }};
                --secondaryBackground: {{ $siteConfiguration['miuujs']['secondaryBackground'] }};
                --gray50: {{ $siteConfiguration['miuujs']['gray50'] }};
                --gray100: {{ $siteConfiguration['miuujs']['gray100'] }};
                --gray200: {{ $siteConfiguration['miuujs']['gray200'] }};
                --gray300: {{ $siteConfiguration['miuujs']['gray300'] }};
                --gray400: {{ $siteConfiguration['miuujs']['gray400'] }};
                --gray500: {{ $siteConfiguration['miuujs']['gray500'] }};
                --gray600: {{ $siteConfiguration['miuujs']['gray600'] }};
                --gray700: color-mix(in srgb, {{ $siteConfiguration['miuujs']['gray700'] }} {{ $siteConfiguration['miuujs']['backdropPercentage'] }}, transparent);
                --gray800: {{ $siteConfiguration['miuujs']['gray800'] }};
                --gray900: {{ $siteConfiguration['miuujs']['gray900'] }};
                --gray700-default: {{ $siteConfiguration['miuujs']['gray700'] }};
            }
            <?php if ($siteConfiguration['miuujs']['defaultMode'] !== 'darkmode') {
                echo ':root';
            } else {
                echo '.lightmode';
            }?>{
                --image: url({{ $siteConfiguration['miuujs']['backgroundImageLight'] }});
                --primary: {{ $siteConfiguration['miuujs']['lightmode_primary'] }};
                --successText: {{ $siteConfiguration['miuujs']['lightmode_successText'] }};
                --successBorder: {{ $siteConfiguration['miuujs']['lightmode_successBorder'] }};
                --successBackground: {{ $siteConfiguration['miuujs']['lightmode_successBackground'] }};
                --dangerText: {{ $siteConfiguration['miuujs']['lightmode_dangerText'] }};
                --dangerBorder: {{ $siteConfiguration['miuujs']['lightmode_dangerBorder'] }};
                --dangerBackground: {{ $siteConfiguration['miuujs']['lightmode_dangerBackground'] }};
                --secondaryText: {{ $siteConfiguration['miuujs']['lightmode_secondaryText'] }};
                --secondaryBorder: {{ $siteConfiguration['miuujs']['lightmode_secondaryBorder'] }};
                --secondaryBackground: {{ $siteConfiguration['miuujs']['lightmode_secondaryBackground'] }};
                --gray50: {{ $siteConfiguration['miuujs']['lightmode_gray50'] }};
                --gray100: {{ $siteConfiguration['miuujs']['lightmode_gray100'] }};
                --gray200: {{ $siteConfiguration['miuujs']['lightmode_gray200'] }};
                --gray300: {{ $siteConfiguration['miuujs']['lightmode_gray300'] }};
                --gray400: {{ $siteConfiguration['miuujs']['lightmode_gray400'] }};
                --gray500: {{ $siteConfiguration['miuujs']['lightmode_gray500'] }};
                --gray600: {{ $siteConfiguration['miuujs']['lightmode_gray600'] }};
                --gray700: color-mix(in srgb, {{ $siteConfiguration['miuujs']['lightmode_gray700'] }} {{ $siteConfiguration['miuujs']['backdropPercentage'] }}, transparent);
                --gray800: {{ $siteConfiguration['miuujs']['lightmode_gray800'] }};
                --gray900: {{ $siteConfiguration['miuujs']['lightmode_gray900'] }};
                --gray700-default: {{ $siteConfiguration['miuujs']['lightmode_gray700'] }};
            }

            <?php if ($siteConfiguration['miuujs']['backdrop']) {
                echo '.backdrop{border:1px solid;border-color:var(--gray600)!important;backdrop-filter:blur(16px);}';
            }?>
            @import url('//fonts.googleapis.com/css?family=Rubik:300,400,500&display=swap');
            @import url('//fonts.googleapis.com/css?family=IBM+Plex+Mono|IBM+Plex+Sans:500&display=swap');
        </style>
        <style>
            @media (min-width: 1400px) {
                [class*="ContentContainer"] { max-width: 1400px !important; }
                [class*="PageContentBlock___StyledContentContainer"],
                [class*="PageContentBlock"] > div { padding-left: 32px !important; padding-right: 32px !important; }
            }
            @media (min-width: 1920px) {
                [class*="ContentContainer"] { max-width: 1600px !important; }
            }
            @media (min-width: 2560px) {
                [class*="ContentContainer"] { max-width: 1800px !important; }
            }
            [class*="ServerRow___StyledDiv"] { max-width: 100%; }
            [class*="App___StyledDiv"] > div { width: 100%; }
        </style>
        @endif

        @yield('assets')

        @include('layouts.scripts')
    </head>
    <body class="{{ $css['body'] ?? 'bg-neutral-50' }}">
        @section('content')
            @yield('above-container')
            @yield('container')
            @yield('below-container')
        @show
        @section('scripts')
            {!! $asset->js('main.js') !!}
        @show
    </body>
</html>