@extends('templates/wrapper', [
    'css' => ['body' => '']
])

@section('container')
    @if(!Auth::check())
    <style id="miuujs-login-elements">
      .miuujs-watermark {
        position: fixed; z-index: 99999;
        left: 20px; bottom: 20px;
        background: rgba(29, 29, 55, 0.85);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        padding: 10px 20px;
        border-radius: 12px;
        color: var(--gray300, #8282a4);
        border: 1px solid var(--gray500, #42425b);
        font-size: 12px;
        font-family: 'Rubik', sans-serif;
      }
      .watermark-highlight { color: #fff; padding-left: 2px; }

      .miuujs-recaptcha {
        z-index: 999999; background-color: #0c090a;
        position: fixed; right: -172px; bottom: 10px;
        width: 240px; height: 50px;
        border-radius: 6px 0 0 6px;
        transition: right .5s; overflow: hidden; cursor: pointer;
      }
      .miuujs-recaptcha:hover { right: 0; }
      .miuujs-recaptcha-bar {
        float: left; background-color: #333;
        width: 6px; height: 50px;
        border-radius: 6px 0 0 6px;
        transition: width .25s, background-color .6s;
      }
      .miuujs-recaptcha:hover .miuujs-recaptcha-bar { width: 8px; background-color: #3457d5; }
      .miuujs-recaptcha-icon {
        background: url("https://i.imgur.com/LD3lZ9j.png") no-repeat center/cover;
        width: 50px; height: 50px; scale: 0.5;
        float: left;
        transition: rotate 1.2s cubic-bezier(0.1, 1.2, 1.5, 1.0);
      }
      .miuujs-recaptcha:hover .miuujs-recaptcha-icon { rotate: 360deg; }
      .miuujs-recaptcha-text {
        color: #fff; height: 50px; width: 175px;
        float: right; padding: 0; margin: 0;
        display: flex; flex-direction: column;
        justify-content: center;
        font-size: 11px; line-height: 1.3;
        font-family: 'Rubik', sans-serif;
      }
      .miuujs-recaptcha-text b { font-size: 12px; }
      .miuujs-recaptcha-text a { color: #4D4DFF; text-decoration: none; }
      .miuujs-recaptcha-text a:hover { text-decoration: underline; }

      .grecaptcha-badge { display: none !important; }

      @media screen and (max-width: 768px) {
        .miuujs-watermark { left: 10px; bottom: 10px; padding: 6px 12px; font-size: 10px; }
        .miuujs-recaptcha { bottom: 10px; width: 200px; right: -132px; }
        .miuujs-recaptcha-text { width: 140px; font-size: 10px; }
      }
      @media screen and (max-width: 480px) {
        .miuujs-watermark { left: 5px; bottom: 5px; padding: 5px 10px; font-size: 9px; }
        .miuujs-recaptcha { width: 180px; right: -112px; bottom: 5px; height: 44px; }
        .miuujs-recaptcha-text { width: 120px; font-size: 9px; }
        .miuujs-recaptcha-bar { height: 44px; }
        .miuujs-recaptcha-icon { height: 44px; width: 44px; }
      }
    </style>

    <div class="miuujs-watermark">Powered by <b class="watermark-highlight">MiuuJS</b></div>
    <div class="miuujs-recaptcha">
      <div class="miuujs-recaptcha-bar"></div>
      <div class="miuujs-recaptcha-icon"></div>
      <div class="miuujs-recaptcha-text">
        <b>reCAPTCHA</b>
        <span><a href="https://www.google.com/intl/en/policies/privacy/">Privacy</a> &amp; <a href="https://www.google.com/intl/en/policies/terms/">Terms</a></span>
      </div>
    </div>
    @endif

    <div id="app"></div>
@endsection