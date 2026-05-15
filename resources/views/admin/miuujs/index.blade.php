@extends('layouts.admin')

@section('title')
    MiuuJS Theme Configuration
@endsection

@section('content-header')
    <h1>MiuuJS Theme<small>Configure your theme settings</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li class="active">MiuuJS Theme</li>
    </ol>
@endsection

@section('content')
    <div class="row">
        <div class="col-xs-12">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Theme Configuration</h3>
                </div>
                <div class="box-body table-responsive no-padding">
                    <table class="table table-hover">
                        <tbody>
                            <tr><th>Setting</th><th>Value</th></tr>
                            @foreach($config as $key => $value)
                                <tr>
                                    <td><code>{{ $key }}</code></td>
                                    <td>
                                        @if(is_bool($value))
                                            <span class="label label-{{ $value ? 'success' : 'danger' }}">{{ $value ? 'true' : 'false' }}</span>
                                        @elseif(is_null($value) || $value === '')
                                            <span class="label label-default">empty</span>
                                        @else
                                            {{ $value }}
                                        @endif
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
@endsection