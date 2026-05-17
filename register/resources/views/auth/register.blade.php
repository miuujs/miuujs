<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ config('app.name', 'Pterodactyl') }} - Register</title>
    <link rel="icon" type="image/png" href="/favicons/favicon-32x32.png" sizes="32x32">
    <link rel="icon" type="image/png" href="/favicons/favicon-16x16.png" sizes="16x16">
    <link rel="shortcut icon" href="/favicons/favicon.ico">
    <link href="https://fonts.googleapis.com/css?family=Karla:400,700" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
    <link href="/themes/pterodactyl/css/pterodactyl.css" rel="stylesheet">
    <link href="/themes/pterodactyl/css/miuujs.css" rel="stylesheet">
    <style>
        :root {
            --primary: #4A35CF;
            --gray50: #f4f4f4; --gray100: #d5d5db; --gray200: #b2b2c1;
            --gray300: #8282a4; --gray400: #5e5e7f; --gray500: #42425b;
            --gray600: #2b2b40; --gray700: #1d1d37; --gray800: #0b0d2a; --gray900: #040519;
        }
        body {
            background: var(--gray800);
            font-family: 'Karla', sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .register-container {
            width: 100%;
            max-width: 420px;
        }
        .register-header {
            text-align: center;
            margin-bottom: 32px;
        }
        .register-header h1 {
            color: var(--gray50);
            font-size: 28px;
            font-weight: 700;
            margin: 0 0 8px;
        }
        .register-header p {
            color: var(--gray300);
            font-size: 14px;
            margin: 0;
        }
        .register-box {
            background: var(--gray700);
            border-radius: 12px;
            padding: 32px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.3);
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            color: var(--gray200);
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .form-group input {
            width: 100%;
            padding: 10px 14px;
            background: var(--gray600);
            border: 1px solid var(--gray500);
            border-radius: 6px;
            color: var(--gray50);
            font-size: 14px;
            transition: border-color 0.2s;
        }
        .form-group input:focus {
            outline: none;
            border-color: var(--primary);
        }
        .form-group input::placeholder {
            color: var(--gray400);
        }
        .form-row {
            display: flex;
            gap: 12px;
        }
        .form-row .form-group {
            flex: 1;
        }
        .btn-register {
            width: 100%;
            padding: 12px;
            background: var(--primary);
            color: #fff;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
            margin-top: 8px;
        }
        .btn-register:hover {
            background: #3d2bb8;
        }
        .btn-register:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
        .login-link {
            text-align: center;
            margin-top: 24px;
            color: var(--gray300);
            font-size: 14px;
        }
        .login-link a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
        }
        .login-link a:hover {
            text-decoration: underline;
        }
        .alert {
            padding: 12px 16px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 14px;
            display: none;
        }
        .alert-error {
            background: rgba(170, 42, 42, 0.2);
            border: 1px solid #aa2a2a;
            color: #ffd8d8;
        }
        .alert-success {
            background: rgba(61, 143, 31, 0.2);
            border: 1px solid #56aa2b;
            color: #e1ffd8;
        }
        .spinner {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid rgba(255,255,255,0.3);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
            margin-right: 8px;
            vertical-align: middle;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        @media (max-width: 480px) {
            .register-box {
                padding: 24px;
            }
            .form-row {
                flex-direction: column;
                gap: 0;
            }
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="register-header">
            <h1>Create Account</h1>
            <p>Join {{ config('app.name', 'Pterodactyl') }} today</p>
        </div>
        <div class="register-box">
            <div id="alert-error" class="alert alert-error"></div>
            <div id="alert-success" class="alert alert-success"></div>
            <form id="register-form" method="POST">
                <div class="form-row">
                    <div class="form-group">
                        <label for="name_first">First Name</label>
                        <input type="text" id="name_first" name="name_first" required placeholder="John">
                    </div>
                    <div class="form-group">
                        <label for="name_last">Last Name</label>
                        <input type="text" id="name_last" name="name_last" required placeholder="Doe">
                    </div>
                </div>
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" required placeholder="johndoe" pattern="[a-zA-Z0-9]+" title="Only letters and numbers allowed">
                </div>
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" required placeholder="john@example.com">
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required placeholder="Min. 8 characters" minlength="8">
                </div>
                <div class="form-group">
                    <label for="password_confirmation">Confirm Password</label>
                    <input type="password" id="password_confirmation" name="password_confirmation" required placeholder="Repeat password" minlength="8">
                </div>
                <button type="submit" id="submit-btn" class="btn-register">
                    Create Account
                </button>
            </form>
            <div class="login-link">
                Already have an account? <a href="{{ route('auth.login') }}">Sign in</a>
            </div>
        </div>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script>
        $(document).ready(function() {
            $('#register-form').on('submit', function(e) {
                e.preventDefault();
                var btn = $('#submit-btn');
                var errorAlert = $('#alert-error');
                var successAlert = $('#alert-success');
                errorAlert.hide();
                successAlert.hide();

                var data = {
                    name_first: $('#name_first').val().trim(),
                    name_last: $('#name_last').val().trim(),
                    username: $('#username').val().trim(),
                    email: $('#email').val().trim(),
                    password: $('#password').val(),
                    password_confirmation: $('#password_confirmation').val(),
                };

                if (data.password !== data.password_confirmation) {
                    errorAlert.text('Passwords do not match.').show();
                    return;
                }

                btn.prop('disabled', true).html('<span class="spinner"></span> Creating account...');

                $.ajax({
                    url: '/auth/register',
                    method: 'POST',
                    headers: { 'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content') },
                    data: JSON.stringify(data),
                    contentType: 'application/json',
                    success: function(res) {
                        successAlert.text(res.message).show();
                        btn.html('Account Created!');
                        setTimeout(function() {
                            window.location.href = '{{ route("auth.login") }}';
                        }, 2000);
                    },
                    error: function(xhr) {
                        var msg = xhr.responseJSON && xhr.responseJSON.error ? xhr.responseJSON.error : 'Registration failed. Please try again.';
                        errorAlert.text(msg).show();
                        btn.prop('disabled', false).html('Create Account');
                    }
                });
            });
        });
    </script>
</body>
</html>
