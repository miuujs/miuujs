@extends('layouts.admin')

@section('title')
    Plugins
@endsection

@section('content-header')
    <h1>Plugin Manager<small>Install and manage theme plugins</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li class="active">Plugins</li>
    </ol>
@endsection

@section('content')
<style>
.plugin-card {
    border-radius: 6px;
    overflow: hidden;
    margin-bottom: 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    transition: box-shadow 0.2s, transform 0.2s;
}
.plugin-card:hover {
    box-shadow: 0 4px 12px rgba(0,0,0,0.12);
    transform: translateY(-2px);
}
.plugin-card .box-header {
    background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
    border-bottom: 1px solid #bbf7d0;
    padding: 12px 16px;
}
.plugin-card .box-header h3 {
    font-size: 16px;
    margin: 0;
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
}
.plugin-card .box-header .label {
    font-size: 11px;
    padding: 2px 8px;
}
.plugin-card .box-body {
    padding: 16px;
}
.plugin-card .box-body p {
    margin: 0 0 12px;
    font-size: 14px;
    line-height: 1.5;
    color: #4b5563;
}
.plugin-card .features {
    list-style: none;
    padding: 0;
    margin: 0 0 12px;
}
.plugin-card .features li {
    font-size: 13px;
    padding: 4px 0;
    color: #374151;
}
.plugin-card .installed-at {
    font-size: 12px;
    color: #9ca3af;
    margin: 0;
}
.plugin-card .box-footer {
    background: #f9fafb;
    border-top: 1px solid #e5e7eb;
    padding: 12px 16px;
}
.plugin-card .box-footer .btn {
    width: 100%;
    font-weight: 500;
}
.empty-state {
    text-align: center;
    padding: 60px 20px;
}
.empty-state i {
    font-size: 64px;
    color: #d1d5db;
    margin-bottom: 16px;
}
.empty-state h4 {
    color: #6b7280;
    margin: 0 0 8px;
    font-size: 18px;
}
.empty-state p {
    color: #9ca3af;
    margin: 0;
    font-size: 14px;
}
.log-output {
    background: #0f172a;
    color: #e2e8f0;
    padding: 16px;
    border-radius: 6px;
    font-family: 'SF Mono', 'Fira Code', 'Consolas', monospace;
    font-size: 13px;
    max-height: 500px;
    overflow-y: auto;
    white-space: pre-wrap;
    line-height: 1.6;
    word-break: break-word;
}
@media (max-width: 767px) {
    .plugin-card .box-header h3 {
        font-size: 15px;
    }
    .plugin-card .box-body {
        padding: 12px;
    }
    .plugin-card .box-footer {
        padding: 10px 12px;
    }
    .modal-dialog {
        margin: 10px;
    }
    .log-output {
        max-height: 350px;
        font-size: 12px;
        padding: 12px;
    }
}
@media (max-width: 480px) {
    .content-header h1 {
        font-size: 22px;
    }
    .content-header small {
        display: block;
        font-size: 13px;
        margin-top: 4px;
    }
    .breadcrumb {
        margin-top: 8px;
    }
}
</style>

<div class="row">
    <div class="col-xs-12">
        <div class="box box-default">
            <div class="box-header with-border">
                <h3 class="box-title">Installed Plugins</h3>
                <div class="box-tools pull-right">
                    <button class="btn btn-primary btn-sm" onclick="showAddPlugin()">
                        <i class="fa fa-plus"></i> <span class="hidden-xs">Add Plugin</span>
                    </button>
                </div>
            </div>
            <div class="box-body">
                @if(count($plugins) > 0)
                <div class="row">
                    @foreach($plugins as $plugin)
                    <div class="col-xs-12 col-sm-6 col-md-4 col-lg-3">
                        <div class="plugin-card box box-solid box-success">
                            <div class="box-header with-border">
                                <h3 class="box-title">
                                    <i class="fa {{ $plugin['icon'] }}"></i>
                                    <span>{{ $plugin['name'] }}</span>
                                    <span class="label label-success pull-right" style="margin-top: 2px;">v{{ $plugin['version'] }}</span>
                                </h3>
                            </div>
                            <div class="box-body">
                                <p>{{ $plugin['desc'] }}</p>
                                @if(count($plugin['features']) > 0)
                                <ul class="features">
                                    @foreach($plugin['features'] as $feature)
                                    <li><i class="fa fa-check text-success"></i> {{ $feature }}</li>
                                    @endforeach
                                </ul>
                                @endif
                                <p class="installed-at"><i class="fa fa-clock-o"></i> {{ $plugin['installed_at'] }}</p>
                            </div>
                            <div class="box-footer">
                                <button class="btn btn-danger btn-sm" onclick="uninstallPlugin('{{ $plugin['id'] }}')">
                                    <i class="fa fa-trash"></i> Uninstall
                                </button>
                            </div>
                        </div>
                    </div>
                    @endforeach
                </div>
                @else
                <div class="empty-state">
                    <i class="fa fa-puzzle-piece"></i>
                    <h4>No plugins installed</h4>
                    <p>Click "Add Plugin" to install a plugin from a URL.</p>
                </div>
                @endif
            </div>
        </div>
    </div>
</div>

<div id="add-plugin-modal" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Add Plugin</h4>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>Plugin URL</label>
                    <input type="text" id="plugin-url" class="form-control" placeholder="https://github.com/username/repo/tree/branch/plugin">
                    <p class="help-block" style="margin-top: 8px; font-size: 12px; color: #6b7280;">
                        Enter a GitHub tree URL pointing to the plugin directory.
                    </p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" onclick="installFromUrl()">Install</button>
            </div>
        </div>
    </div>
</div>

<div id="install-modal" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title" id="modal-title">Installing Plugin...</h4>
            </div>
            <div class="modal-body">
                <div id="install-output" class="log-output"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" id="modal-refresh" style="display:none;" onclick="location.reload()">Refresh Page</button>
            </div>
        </div>
    </div>
</div>
@endsection

@section('footer-scripts')
@parent
<script>
function showAddPlugin() {
    $('#plugin-url').val('');
    $('#add-plugin-modal').modal('show');
}

function appendLine(output, text) {
    output.append(document.createTextNode(text + '\n'));
    output.scrollTop = output.scrollHeight;
}

function streamRequest(url, method, body) {
    return new Promise(function(resolve, reject) {
        var output = document.getElementById('install-output');
        output.innerHTML = '';

        fetch(url, {
            method: method,
            headers: {
                'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content'),
                'Accept': 'text/event-stream',
                'Content-Type': 'application/json'
            },
            body: body ? JSON.stringify(body) : null
        }).then(function(response) {
            if (!response.ok) {
                reject(new Error('HTTP ' + response.status));
                return;
            }

            var reader = response.body.getReader();
            var decoder = new TextDecoder();
            var buffer = '';

            function read() {
                return reader.read().then(function(result) {
                    if (result.done) {
                        resolve();
                        return;
                    }

                    buffer += decoder.decode(result.value, { stream: true });
                    var lines = buffer.split('\n\n');
                    buffer = lines.pop();

                    for (var i = 0; i < lines.length; i++) {
                        var line = lines[i];
                        if (line.startsWith('data: ')) {
                            var data = JSON.parse(line.substring(6));
                            if (data === '__DONE__') {
                                resolve('done');
                                return;
                            }
                            if (data === '__ERROR__') {
                                reject(new Error('Operation failed'));
                                return;
                            }
                            appendLine(output, data);
                        }
                    }

                    return read();
                });
            }

            return read();
        }).catch(function(err) {
            reject(err);
        });
    });
}

function installFromUrl() {
    var url = $('#plugin-url').val().trim();
    if (!url) {
        alert('Please enter a plugin URL.');
        return;
    }

    $('#add-plugin-modal').modal('hide');

    setTimeout(function() {
        $('#modal-title').text('Installing Plugin...');
        $('#install-modal').modal('show');
        $('#modal-refresh').hide();

        streamRequest('/admin/plugins/install', 'POST', { url: url })
            .then(function() {
                var output = document.getElementById('install-output');
                appendLine(output, '\nInstallation completed successfully!');
                $('#modal-title').text('Installation Complete');
                $('#modal-refresh').show();
            })
            .catch(function(err) {
                var output = document.getElementById('install-output');
                appendLine(output, '\nInstallation failed: ' + err.message);
                $('#modal-title').text('Installation Failed');
            });
    }, 300);
}

function uninstallPlugin(name) {
    $('#modal-title').text('Uninstalling ' + name + '...');
    $('#install-modal').modal('show');
    $('#modal-refresh').hide();

    streamRequest('/admin/plugins/uninstall/' + name, 'POST', null)
        .then(function() {
            var output = document.getElementById('install-output');
            appendLine(output, '\nUninstall completed successfully!');
            $('#modal-title').text('Uninstall Complete');
            $('#modal-refresh').show();
        })
        .catch(function(err) {
            var output = document.getElementById('install-output');
            appendLine(output, '\nUninstall failed: ' + err.message);
            $('#modal-title').text('Uninstall Failed');
        });
}
</script>
@endsection
