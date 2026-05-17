<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\Models\MustikaPayProduct;
use Pterodactyl\Models\Nest;

class MustikaPayController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected SettingsRepositoryInterface $settings
    ) {}

    public function index()
    {
        return view('admin.mustikapay', [
            'api_key' => $this->settings->get('mustikapay:api_key', ''),
            'products' => MustikaPayProduct::with('egg.nest')->get(),
            'nests' => Nest::with('eggs')->get(),
        ]);
    }

    public function update(Request $request)
    {
        $this->settings->set('mustikapay:api_key', $request->input('api_key'));
        $this->alert->success('MustikaPay settings updated.')->flash();
        return redirect()->route('admin.mustikapay');
    }

    public function addProduct(Request $request)
    {
        $data = $request->only(['name', 'image', 'description', 'price', 'cpu', 'ram', 'disk']);

        MustikaPayProduct::create($data);
        $this->alert->success('Product added successfully.')->flash();
        return redirect()->route('admin.mustikapay');
    }

    public function updateProduct($id, Request $request)
    {
        $product = MustikaPayProduct::findOrFail($id);
        $data = $request->only(['name', 'image', 'description', 'price', 'cpu', 'ram', 'disk']);

        $product->update($data);
        $this->alert->success('Product updated successfully.')->flash();
        return redirect()->route('admin.mustikapay');
    }

    public function deleteProduct($id)
    {
        MustikaPayProduct::findOrFail($id)->delete();
        $this->alert->success('Product deleted.')->flash();
        return redirect()->route('admin.mustikapay');
    }
}
