@extends('layouts.admin')

@section('title')
    MustikaPay Billing
@endsection

@section('content-header')
    <h1>MustikaPay Integration</h1>
@endsection

@section('content')
<div class="row">
    <div class="col-md-4">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">General Settings</h3>
            </div>
            <form action="{{ route('admin.mustikapay.update') }}" method="POST">
                @csrf
                <div class="box-body">
                    <div class="form-group">
                        <label>MustikaPay API Key</label>
                        <input type="text" name="api_key" class="form-control" value="{{ $api_key }}" placeholder="MP-xxxx-xxxx">
                    </div>
                </div>
                <div class="box-footer">
                    <button type="submit" class="btn btn-primary btn-sm pull-right">Save API Key</button>
                </div>
            </form>
        </div>
    </div>
    
    <div class="col-md-8">
        <div class="box box-success">
            <div class="box-header with-border">
                <h3 class="box-title">Product List</h3>
            </div>
            <div class="box-body table-responsive no-padding">
                <table class="table table-hover">
                    <tr>
                        <th>ID</th>
                        <th>Image</th>
                        <th>Name</th>
                        <th>Description</th>
                        <th>Price</th>
                        <th>CPU</th>
                        <th>RAM</th>
                        <th>Disk</th>
                        <th>Action</th>
                    </tr>
                    @foreach($products as $product)
                    <tr>
                        <td>{{ $product->id }}</td>
                        <td><img src="{{ $product->image ?? 'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61' }}" alt="img" style="width:40px;height:40px;border-radius:6px;object-fit:cover;"></td>
                        <td>{{ $product->name }}</td>
                        <td>{{ Str::limit($product->description, 40) }}</td>
                        <td>Rp {{ number_format($product->price) }}</td>
                        <td>{{ $product->cpu }}%</td>
                        <td>{{ $product->ram }}MB</td>
                        <td>{{ $product->disk }}MB</td>
                        <td>
                            <form action="{{ route('admin.mustikapay.product.delete', $product->id) }}" method="POST">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn btn-danger btn-xs"><i class="fa fa-trash"></i></button>
                            </form>
                        </td>
                    </tr>
                    @endforeach
                </table>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-xs-12">
        <div class="box box-success">
            <div class="box-header with-border">
                <h3 class="box-title">Add New Product</h3>
            </div>
            <form action="{{ route('admin.mustikapay.product.add') }}" method="POST">
                @csrf
                <div class="box-body row">
                    <div class="form-group col-md-3">
                        <label>Product Name</label>
                        <input type="text" name="name" class="form-control" required placeholder="Hemat 1GB">
                    </div>
                    <div class="form-group col-md-2">
                        <label>Image URL</label>
                        <input type="text" name="image" class="form-control" placeholder="https://...">
                    </div>
                    <div class="form-group col-md-3">
                        <label>Description</label>
                        <input type="text" name="description" class="form-control" placeholder="Perfect for small projects">
                    </div>
                    <div class="form-group col-md-1">
                        <label>Price (Rp)</label>
                        <input type="number" name="price" class="form-control" required placeholder="5000">
                    </div>
                    <div class="form-group col-md-1">
                        <label>CPU (%)</label>
                        <input type="number" name="cpu" class="form-control" required value="100">
                    </div>
                    <div class="form-group col-md-1">
                        <label>RAM (MB)</label>
                        <input type="number" name="ram" class="form-control" required value="1024">
                    </div>
                    <div class="form-group col-md-1">
                        <label>Disk (MB)</label>
                        <input type="number" name="disk" class="form-control" required value="5120">
                    </div>
                </div>
                <div class="box-footer">
                    <button type="submit" class="btn btn-success btn-block">ADD PRODUCT</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
