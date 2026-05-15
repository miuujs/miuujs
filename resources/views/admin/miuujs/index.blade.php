<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="_token" content="{{ csrf_token() }}">
    <title>MiuuJS Config</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Rubik', -apple-system, sans-serif; background: #0b0d2a; color: #b2b2c1; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .card { background: #1d1d37; border: 1px solid #42425b; border-radius: 16px; padding: 48px; text-align: center; max-width: 500px; width: 90%; }
        .icon { font-size: 48px; color: #4A35CF; margin-bottom: 20px; }
        h1 { color: #f4f4f4; font-size: 24px; font-weight: 700; margin-bottom: 12px; }
        p { color: #8282a4; font-size: 15px; line-height: 1.7; }
        .links { margin-top: 24px; display: flex; justify-content: center; gap: 12px; flex-wrap: wrap; }
        .links a { color: #8282a4; text-decoration: none; font-size: 13px; padding: 8px 16px; border: 1px solid #42425b; border-radius: 8px; transition: all .2s; display: inline-flex; align-items: center; gap: 6px; }
        .links a:hover { color: #f4f4f4; border-color: #4A35CF; background: #2b2b40; }
    </style>
</head>
<body>
    <div class="card">
        <div class="icon"><i class="fa fa-cogs"></i></div>
        <h1>Coming Soon</h1>
        <p>The MiuuJS configuration panel is currently under development. Full real-time settings will be available soon.</p>
        <div class="links">
            <a href="{{ route('index') }}"><i class="fa fa-server"></i> Back to Panel</a>
            <a href="{{ route('admin.index') }}"><i class="fa fa-cog"></i> Admin</a>
        </div>
    </div>
</body>
</html>