<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="_token" content="{{ csrf_token() }}">
    <title>MiuuJS Config</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>
    <style>
        .miuujs-loader {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: #0b0d2a; z-index: 9999;
            display: flex; align-items: center; justify-content: center;
            flex-direction: column; gap: 20px;
        }
        .miuujs-loader .dots { display: flex; gap: 8px; }
        .miuujs-loader .dot {
            width: 12px; height: 12px; border-radius: 50%;
            background: #4A35CF; display: inline-block;
        }
        .miuujs-loader p {
            color: #8282a4; font-size: 13px; font-family: 'Rubik', sans-serif;
            letter-spacing: 2px; text-transform: uppercase;
        }
        .miuujs-loader.hidden { opacity: 0; pointer-events: none; transition: opacity .4s; }
    </style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Rubik', -apple-system, sans-serif;
            background: #0b0d2a; color: #b2b2c1;
            min-height: 100vh;
        }
        .navbar {
            background: #1d1d37; border-bottom: 1px solid #42425b;
            padding: 12px 24px; display: flex; align-items: center;
            justify-content: space-between;
        }
        .navbar h1 { color: #f4f4f4; font-size: 18px; font-weight: 600; }
        .navbar a {
            color: #8282a4; text-decoration: none; font-size: 14px;
            display: flex; align-items: center; gap: 6px;
            transition: color .2s;
        }
        .navbar a:hover { color: #f4f4f4; }
        .container { max-width: 900px; margin: 0 auto; padding: 30px 20px; }
        .card {
            background: #1d1d37; border: 1px solid #42425b;
            border-radius: 10px; padding: 24px; margin-bottom: 20px;
        }
        .card h2 {
            color: #f4f4f4; font-size: 16px; font-weight: 600;
            margin-bottom: 16px; padding-bottom: 10px;
            border-bottom: 1px solid #42425b;
        }
        .form-group { margin-bottom: 14px; }
        .form-group label {
            display: block; color: #8282a4; font-size: 13px;
            margin-bottom: 4px; font-weight: 500;
        }
        .form-group input, .form-group select {
            width: 100%; padding: 10px 12px;
            background: #2b2b40; border: 1px solid #42425b;
            border-radius: 6px; color: #f4f4f4; font-size: 14px;
            outline: none; transition: border-color .2s;
        }
        .form-group input:focus { border-color: #4A35CF; }
        .form-group .hint {
            color: #5e5e7f; font-size: 11px; margin-top: 3px;
        }
        .row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        .btn {
            padding: 10px 24px; border: none; border-radius: 6px;
            font-size: 14px; font-weight: 500; cursor: pointer;
            transition: opacity .2s;
        }
        .btn-primary { background: #4A35CF; color: #fff; }
        .btn-primary:hover { opacity: .9; }
        .btn-secondary {
            background: #42425b; color: #b2b2c1; text-decoration: none;
            display: inline-flex; align-items: center; gap: 6px;
        }
        .btn-secondary:hover { opacity: .9; }
        .alert {
            padding: 12px 16px; border-radius: 6px; margin-bottom: 16px;
            font-size: 14px;
        }
        .alert-success { background: #3D8F1F; color: #E1FFD8; border: 1px solid #56AA2B; }
        .flex { display: flex; align-items: center; gap: 10px; }
        @media (max-width: 600px) { .row { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <div class="miuujs-loader" id="miuujsLoader">
        <div class="dots">
            <div class="dot"></div>
            <div class="dot"></div>
            <div class="dot"></div>
        </div>
        <p>MiuuJS</p>
    </div>
    <nav class="navbar">
        <h1><i class="fa fa-paint-brush"></i> MiuuJS Config</h1>
        <div class="flex">
            <a href="{{ route('index') }}"><i class="fa fa-server"></i> Back to Panel</a>
            <a href="{{ route('admin.index') }}"><i class="fa fa-cog"></i> Admin</a>
        </div>
    </nav>
    <div class="container">
        @if(session('success'))
            <div class="alert alert-success">{{ session('success') }}</div>
        @endif

        <form method="POST">
            @csrf

            <div class="card">
                <h2>Logo & Branding</h2>
                <div class="row">
                    <div class="form-group">
                        <label>Logo URL</label>
                        <input name="logo" value="{{ $config['logo'] ?? '' }}">
                        <div class="hint">Path or URL to your logo image</div>
                    </div>
                    <div class="form-group">
                        <label>Logo Height</label>
                        <input name="logoHeight" value="{{ $config['logoHeight'] ?? '32px' }}">
                    </div>
                </div>
                <div class="row">
                    <div class="form-group">
                        <label>Full Logo (text only)</label>
                        <select name="fullLogo">
                            <option value="1" {{ ($config['fullLogo'] ?? false) ? 'selected' : '' }}>Yes</option>
                            <option value="0" {{ !($config['fullLogo'] ?? false) ? 'selected' : '' }}>No</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Primary Color</label>
                        <input name="primary" value="{{ $config['primary'] ?? '#4A35CF' }}">
                    </div>
                </div>
            </div>

            <div class="card">
                <h2>Social Links</h2>
                <div class="row">
                    <div class="form-group">
                        <label>WhatsApp URL</label>
                        <input name="whatsapp" value="{{ $config['whatsapp'] ?? '' }}">
                        <div class="hint">WhatsApp channel or group URL</div>
                    </div>
                    <div class="form-group">
                        <label>Support URL</label>
                        <input name="support" value="{{ $config['support'] ?? '' }}">
                        <div class="hint">Support link (GitHub Issues, etc.)</div>
                    </div>
                </div>
            </div>

            <div class="card">
                <h2>Dashboard</h2>
                <div class="row">
                    <div class="form-group">
                        <label>Server Card Style</label>
                        <select name="serverRow">
                            <option value="1" {{ ($config['serverRow'] ?? 1) == 1 ? 'selected' : '' }}>Gradient</option>
                            <option value="2" {{ ($config['serverRow'] ?? 1) == 2 ? 'selected' : '' }}>Banner</option>
                            <option value="3" {{ ($config['serverRow'] ?? 1) == 3 ? 'selected' : '' }}>Default</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Layout Style</label>
                        <select name="layout">
                            <option value="1" {{ ($config['layout'] ?? 1) == 1 ? 'selected' : '' }}>Sidebar</option>
                            <option value="3" {{ ($config['layout'] ?? 1) == 3 ? 'selected' : '' }}>Top Nav</option>
                            <option value="5" {{ ($config['layout'] ?? 1) == 5 ? 'selected' : '' }}>Icon Sidebar</option>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="form-group">
                        <label>Show GitHub Box</label>
                        <select name="githubBox">
                            <option value="1" {{ ($config['githubBox'] ?? true) ? 'selected' : '' }}>Yes</option>
                            <option value="0" {{ !($config['githubBox'] ?? true) ? 'selected' : '' }}>No</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Show Social Buttons</label>
                        <select name="socialButtons">
                            <option value="1" {{ ($config['socialButtons'] ?? false) ? 'selected' : '' }}>Yes</option>
                            <option value="0" {{ !($config['socialButtons'] ?? false) ? 'selected' : '' }}>No</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="card">
                <h2>Login Page</h2>
                <div class="row">
                    <div class="form-group">
                        <label>Login Layout</label>
                        <select name="loginLayout">
                            <option value="1" {{ ($config['loginLayout'] ?? 1) == 1 ? 'selected' : '' }}>Centered + Background</option>
                            <option value="2" {{ ($config['loginLayout'] ?? 1) == 2 ? 'selected' : '' }}>Split Screen</option>
                            <option value="3" {{ ($config['loginLayout'] ?? 1) == 3 ? 'selected' : '' }}>Split Rounded</option>
                            <option value="4" {{ ($config['loginLayout'] ?? 1) == 4 ? 'selected' : '' }}>Centered No Box</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Login Background</label>
                        <input name="loginBackground" value="{{ $config['loginBackground'] ?? '/miuujs/background-login.png' }}">
                    </div>
                </div>
                <div class="row">
                    <div class="form-group">
                        <label>Enable Login Gradient</label>
                        <select name="loginGradient">
                            <option value="1" {{ ($config['loginGradient'] ?? false) ? 'selected' : '' }}>Yes</option>
                            <option value="0" {{ !($config['loginGradient'] ?? false) ? 'selected' : '' }}>No</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Logo Position (Login)</label>
                        <select name="logoPosition">
                            <option value="1" {{ ($config['logoPosition'] ?? 1) == 1 ? 'selected' : '' }}>Inside Form</option>
                            <option value="2" {{ ($config['logoPosition'] ?? 1) == 2 ? 'selected' : '' }}>Top Bar</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="card">
                <h2>Meta & Announcement</h2>
                <div class="row">
                    <div class="form-group">
                        <label>Meta Title</label>
                        <input name="meta_title" value="{{ $config['meta_title'] ?? '' }}">
                    </div>
                    <div class="form-group">
                        <label>Meta Description</label>
                        <input name="meta_description" value="{{ $config['meta_description'] ?? '' }}">
                    </div>
                </div>
                <div class="form-group">
                    <label>Announcement Message</label>
                    <input name="announcementMessage" value="{{ $config['announcementMessage'] ?? '' }}">
                    <div class="hint">BBCode supported</div>
                </div>
                <div class="row">
                    <div class="form-group">
                        <label>Announcement Type</label>
                        <select name="announcementType">
                            <option value="disabled" {{ ($config['announcementType'] ?? 'disabled') == 'disabled' ? 'selected' : '' }}>Disabled</option>
                            <option value="info" {{ ($config['announcementType'] ?? 'disabled') == 'info' ? 'selected' : '' }}>Info</option>
                            <option value="success" {{ ($config['announcementType'] ?? 'disabled') == 'success' ? 'selected' : '' }}>Success</option>
                            <option value="alert" {{ ($config['announcementType'] ?? 'disabled') == 'alert' ? 'selected' : '' }}>Alert</option>
                            <option value="warning" {{ ($config['announcementType'] ?? 'disabled') == 'warning' ? 'selected' : '' }}>Warning</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Copyright Text</label>
                        <input name="copyright" value="{{ $config['copyright'] ?? 'Powered by MiuuJS' }}">
                    </div>
                </div>
            </div>

            <div class="flex" style="justify-content: flex-end;">
                <button type="submit" class="btn btn-primary"><i class="fa fa-save"></i> Save Settings</button>
            </div>
        </form>
    </div>
    <script>
        var loader = document.getElementById('miuujsLoader');
        var dots = loader.querySelectorAll('.dot');
        anime({
            targets: dots,
            scale: [{ value: 1.5, duration: 400 }, { value: 1, duration: 400 }],
            translateY: [{ value: -8, duration: 400 }, { value: 0, duration: 400 }],
            delay: anime.stagger(120),
            loop: true,
            easing: 'easeInOutSine'
        });
        window.addEventListener('load', function() {
            anime({
                targets: loader,
                opacity: [1, 0],
                duration: 400,
                easing: 'easeOutCubic',
                complete: function() { loader.classList.add('hidden'); }
            });
        });
        setTimeout(function() {
            if (!loader.classList.contains('hidden')) {
                loader.classList.add('hidden');
            }
        }, 5000);
    </script>
</body>
</html>