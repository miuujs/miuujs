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
<div class="row">
    <div class="col-xs-12">
        <div class="box box-default">
            <div class="box-header with-border">
                <h3 class="box-title">Installed Plugins</h3>
                <div class="box-tools pull-right">
                    <button class="btn btn-primary btn-sm" onclick="showAddPlugin()">
                        <i class="fa fa-plus"></i> Add Plugin
                    </button>
                </div>
            </div>
            <div class="box-body">
                @if(count($plugins) > 0)
                <div class="row">
                    @foreach($plugins as $plugin)
                    <div class="col-xs-12 col-sm-6 col-md-4">
                        <div class="box box-solid box-success">
                            <div class="box-header with-border">
                                <h3 class="box-title">
                                    <i class="fa {{ $plugin['icon'] }}"></i>
                                    {{ $plugin['name'] }}
                                    <span class="label label-success pull-right">v{{ $plugin['version'] }}</span>
                                </h3>
                            </div>
                            <div class="box-body">
                                <p>{{ $plugin['desc'] }}</p>
                                @if(count($plugin['features']) > 0)
                                <ul class="list-unstyled" style="margin-bottom: 16px;">
                                    @foreach($plugin['features'] as $feature)
                                    <li><i class="fa fa-check text-success"></i> {{ $feature }}</li>
                                    @endforeach
                                </ul>
                                @endif
                                <p class="text-muted text-sm"><i class="fa fa-clock-o"></i> Installed: {{ $plugin['installed_at'] }}</p>
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
                <div class="text-center" style="padding: 40px;">
                    <i class="fa fa-puzzle-piece" style="font-size: 48px; color: #42425b;"></i>
                    <h4 style="color: #8282a4; margin-top: 16px;">No plugins installed</h4>
                    <p style="color: #5e5e7f;">Click "Add Plugin" to install a plugin from a URL.</p>
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
                    <input type="text" id="plugin-url" class="form-control" placeholder="https://github.com/...">
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
                <div id="install-output" style="background: #1a1a2e; color: #e0e0e0; padding: 16px; border-radius: 4px; font-family: monospace; font-size: 13px; max-height: 500px; overflow-y: auto; white-space: pre-wrap; line-height: 1.6;"></div>
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
