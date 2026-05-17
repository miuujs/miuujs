@extends('layouts.admin')

@section('title')
    Registration Settings
@endsection

@section('content-header')
    <h1>Registration Settings<small>Configure user registration options</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li class="active">Registration</li>
    </ol>
@endsection

@section('content')
<div class="row">
    <div class="col-md-6">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">General Settings</h3>
            </div>
            <form method="POST">
                @csrf
                <div class="box-body">
                    <div class="form-group">
                        <label>
                            <input type="checkbox" name="enabled" value="1" {{ $enabled == '1' ? 'checked' : '' }}>
                            Enable Public Registration
                        </label>
                        <p class="help-block">Allow users to create accounts from the login page.</p>
                    </div>
                    <div class="form-group">
                        <label>
                            <input type="checkbox" name="require_email_verification" value="1" {{ $require_email_verification == '1' ? 'checked' : '' }}>
                            Require Email Verification
                        </label>
                        <p class="help-block">Users must verify their email before logging in.</p>
                    </div>
                </div>
                <div class="box-footer">
                    <button type="submit" class="btn btn-primary pull-right">Save Settings</button>
                </div>
            </form>
        </div>
    </div>
    <div class="col-md-6">
        <div class="box box-info">
            <div class="box-header with-border">
                <h3 class="box-title">Registration URL</h3>
            </div>
            <div class="box-body">
                <p>Users can register at the following URL:</p>
                <div class="input-group">
                    <input type="text" class="form-control" value="{{ route('auth.register.page') }}" readonly>
                    <span class="input-group-btn">
                        <button class="btn btn-default" onclick="copyUrl()">Copy</button>
                    </span>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('footer-scripts')
@parent
<script>
function copyUrl() {
    var input = document.querySelector('.input-group input');
    input.select();
    document.execCommand('copy');
    alert('URL copied to clipboard!');
}
</script>
@endsection
