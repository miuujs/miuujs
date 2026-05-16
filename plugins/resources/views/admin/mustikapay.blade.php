@extends('layouts.admin')

@section('title')
    MustikaPay Billing
@endsection

@section('content-header')
    <h1>MustikaPay Integration</h1>
@endsection

@section('content')
<style>
.product-card {
    border-radius: 8px;
    overflow: hidden;
    background: #fff;
    box-shadow: 0 1px 3px rgba(0,0,0,.08);
    transition: box-shadow .2s;
    margin-bottom: 16px;
}
.product-card:hover {
    box-shadow: 0 4px 12px rgba(0,0,0,.12);
}
.product-card .card-banner {
    height: 60px;
    background: linear-gradient(135deg, #4f46e5 0%, #3b82f6 100%);
    position: relative;
}
.product-card .card-avatar {
    width: 52px;
    height: 52px;
    border-radius: 8px;
    border: 3px solid #fff;
    overflow: hidden;
    position: absolute;
    bottom: -26px;
    left: 16px;
    background: #f3f4f6;
    box-shadow: 0 2px 6px rgba(0,0,0,.12);
}
.product-card .card-avatar img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}
.product-card .card-body {
    padding: 32px 16px 16px;
}
.product-card .card-body h4 {
    margin: 0 0 2px;
    font-size: 15px;
    font-weight: 600;
}
.product-card .card-body .desc {
    font-size: 12px;
    color: #6b7280;
    margin-bottom: 8px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}
.product-card .price-tag {
    font-size: 18px;
    font-weight: 700;
    color: #059669;
    margin-bottom: 8px;
}
.product-card .specs {
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
    margin-bottom: 10px;
}
.product-card .specs .badge {
    font-size: 11px;
    padding: 2px 8px;
    border-radius: 4px;
    background: #f3f4f6;
    color: #374151;
    font-weight: 500;
    display: inline-flex;
    align-items: center;
    gap: 3px;
}
.product-card .card-actions {
    display: flex;
    gap: 6px;
    padding: 0 16px 12px;
}
.product-card .card-actions .btn {
    flex: 1;
    font-size: 12px;
    padding: 4px 8px;
}
</style>

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
                <h3 class="box-title">Products</h3>
                <div class="box-tools pull-right">
                    <button type="button" class="btn btn-success btn-xs" data-toggle="modal" data-target="#addModal">
                        <i class="fa fa-plus"></i> Add Product
                    </button>
                </div>
            </div>
            <div class="box-body">
                @if($products->isEmpty())
                    <div class="text-center text-muted py-4" style="padding:40px 0">
                        <i class="fa fa-cube" style="font-size:48px;color:#d1d5db;display:block;margin-bottom:12px"></i>
                        No products yet. Click "Add Product" to create one.
                    </div>
                @else
                    <div class="row">
                        @foreach($products as $product)
                        <div class="col-sm-6 col-lg-4">
                            <div class="product-card">
                                <div class="card-banner" style="background:linear-gradient(135deg, #4f46e5 0%, #6366f1 100%)"></div>
                                <div class="card-avatar">
                                    <img src="{{ $product->image ?? 'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61' }}" alt="">
                                </div>
                                <div class="card-body">
                                    <h4>{{ $product->name }}</h4>
                                    @if($product->description)
                                        <div class="desc">{{ $product->description }}</div>
                                    @endif
                                    <div class="price-tag">Rp {{ number_format($product->price) }}</div>
                                    <div class="specs">
                                        @if($product->cpu > 0) <span class="badge"><i class="fa fa-microchip"></i> {{ $product->cpu }}%</span> @endif
                                        @if($product->ram > 0) <span class="badge"><i class="fa fa-memory"></i> {{ $product->ram }}MB</span> @endif
                                        @if($product->disk > 0) <span class="badge"><i class="fa fa-hdd-o"></i> {{ $product->disk }}MB</span> @endif
                                    </div>
                                </div>
                                <div class="card-actions">
                                    <button type="button" class="btn btn-warning btn-xs" data-toggle="modal" data-target="#editModal{{ $product->id }}">
                                        <i class="fa fa-pencil"></i> Edit
                                    </button>
                                    <form action="{{ route('admin.mustikapay.product.delete', $product->id) }}" method="POST" style="flex:1">
                                        @csrf @method('DELETE')
                                        <button type="submit" class="btn btn-danger btn-xs" style="width:100%" onclick="return confirm('Delete this product?')">
                                            <i class="fa fa-trash"></i> Delete
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>

                        {{-- Edit Modal --}}
                        <div class="modal fade" id="editModal{{ $product->id }}" tabindex="-1">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <form action="{{ route('admin.mustikapay.product.update', $product->id) }}" method="POST">
                                        @csrf
                                        <div class="modal-header">
                                            <button type="button" class="close" data-dismiss="modal">&times;</button>
                                            <h4 class="modal-title">Edit: {{ $product->name }}</h4>
                                        </div>
                                        <div class="modal-body">
                                            <div class="form-group">
                                                <label>Product Name</label>
                                                <input type="text" name="name" class="form-control" required value="{{ $product->name }}">
                                            </div>
                                            <div class="form-group">
                                                <label>Image URL</label>
                                                <input type="text" name="image" class="form-control" value="{{ $product->image }}" placeholder="https://...">
                                                @if($product->image)
                                                <div style="margin-top:6px"><img src="{{ $product->image }}" style="width:60px;height:60px;border-radius:6px;object-fit:cover"></div>
                                                @endif
                                            </div>
                                            <div class="form-group">
                                                <label>Description</label>
                                                <input type="text" name="description" class="form-control" value="{{ $product->description }}" placeholder="Product description">
                                            </div>
                                            <div class="row">
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>Price (Rp)</label>
                                                        <input type="number" name="price" class="form-control" required value="{{ $product->price }}">
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>CPU (%)</label>
                                                        <input type="number" name="cpu" class="form-control" required value="{{ $product->cpu }}">
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-sm-6">
                                                    <div class="form-group">
                                                        <label>RAM (MB)</label>
                                                        <input type="number" name="ram" class="form-control" required value="{{ $product->ram }}">
                                                    </div>
                                                </div>
                                                <div class="col-sm-6">
                                                    <div class="form-group">
                                                        <label>Disk (MB)</label>
                                                        <input type="number" name="disk" class="form-control" required value="{{ $product->disk }}">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                                            <button type="submit" class="btn btn-warning">Save Changes</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                @endif
            </div>
        </div>
    </div>
</div>

{{-- Add Product Modal --}}
<div class="modal fade" id="addModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="{{ route('admin.mustikapay.product.add') }}" method="POST">
                @csrf
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Add New Product</h4>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label>Product Name</label>
                        <input type="text" name="name" class="form-control" required placeholder="e.g. Hemat 1GB">
                    </div>
                    <div class="form-group">
                        <label>Image URL</label>
                        <input type="text" name="image" class="form-control" placeholder="https://... (optional)">
                    </div>
                    <div class="form-group">
                        <label>Description</label>
                        <input type="text" name="description" class="form-control" placeholder="Perfect for small projects">
                    </div>
                    <div class="row">
                        <div class="col-sm-4">
                            <div class="form-group">
                                <label>Price (Rp)</label>
                                <input type="number" name="price" class="form-control" required placeholder="5000">
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="form-group">
                                <label>CPU (%)</label>
                                <input type="number" name="cpu" class="form-control" required value="100">
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-6">
                            <div class="form-group">
                                <label>RAM (MB)</label>
                                <input type="number" name="ram" class="form-control" required value="1024">
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="form-group">
                                <label>Disk (MB)</label>
                                <input type="number" name="disk" class="form-control" required value="5120">
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-success">Add Product</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
