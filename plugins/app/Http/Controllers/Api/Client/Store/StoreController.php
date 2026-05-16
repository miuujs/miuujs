<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Store;

use Carbon\Carbon;
use Illuminate\Http\Request;
use MustikaPay\MustikaPay;
use Pterodactyl\Models\User;
use Pterodactyl\Models\Server;
use Pterodactyl\Models\Nest;
use Pterodactyl\Models\Egg;
use Illuminate\Http\JsonResponse;
use Pterodactyl\Models\MustikaPayTransaction;
use Pterodactyl\Models\MustikaPayProduct;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Services\Servers\ServerCreationService;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Illuminate\Support\Facades\Log;

class StoreController extends ClientApiController
{
    public function index(Request $request, SettingsRepositoryInterface $settings): JsonResponse
    {
        $user = $request->user();
        
        // Fetch nests and their eggs for user selection
        $nests = Nest::with('eggs')->get()->map(function($nest) {
            return [
                'id' => $nest->id,
                'name' => $nest->name,
                'eggs' => $nest->eggs->map(function($egg) {
                    return ['id' => $egg->id, 'name' => $egg->name];
                })
            ];
        });

        return new JsonResponse([
            'balance' => (float) $user->balance,
            'products' => MustikaPayProduct::all(),
            'nests' => $nests,
            'transactions' => MustikaPayTransaction::where('user_id', $user->id)->orderBy('created_at', 'desc')->limit(5)->get(),
            'servers' => Server::where('owner_id', $user->id)->where('is_billed', true)->get(),
        ]);
    }

    public function pay(Request $request, SettingsRepositoryInterface $settings): JsonResponse
    {
        $request->validate(['amount' => 'required|numeric|min:1', 'method' => 'required|string']);
        $user = $request->user();
        $apiKey = $settings->get('mustikapay:api_key');
        if (empty($apiKey)) return new JsonResponse(['error' => 'Gateway not configured.'], 500);

        $mp = new MustikaPay($apiKey);
        try {
            $paymentData = $request->input('method') === 'QRIS' ? $mp->createQRIS($request->input('amount')) : $mp->createVA($request->input('amount'), $request->input('method'), $user->username);
            
            MustikaPayTransaction::create([
                'user_id' => $user->id,
                'reference' => $paymentData['ref_no'] ?? 'TOPUP-' . time(),
                'amount' => $request->input('amount'),
                'status' => 'pending',
                'payment_method' => $request->input('method'),
                'payment_code' => $paymentData['qr_content'] ?? ($paymentData['va_number'] ?? null),
            ]);

            return new JsonResponse(['payment_data' => $paymentData]);
        } catch (\Exception $e) { return new JsonResponse(['error' => $e->getMessage()], 500); }
    }

    public function buy(Request $request, ServerCreationService $creationService): JsonResponse
    {
        $request->validate([
            'product_id' => 'required|integer',
            'egg_id' => 'required|integer|exists:eggs,id',
        ]);

        $user = $request->user();
        $product = MustikaPayProduct::findOrFail($request->input('product_id'));
        $egg = Egg::with('variables')->findOrFail($request->input('egg_id'));

        if ($user->balance < $product->price) return new JsonResponse(['error' => 'Insufficient balance'], 400);

        try {
            $allocation = \Pterodactyl\Models\Allocation::whereNull('server_id')->first();
            if (!$allocation) return new JsonResponse(['error' => 'No allocations available.'], 500);

            $environment = [];
            foreach ($egg->variables as $variable) {
                $environment[$variable->env_variable] = $variable->default_value;
            }

            $images = $egg->docker_images;
            $image = reset($images);

            $server = $creationService->handle([
                'name' => $product->name . ' - ' . $user->username,
                'owner_id' => $user->id,
                'egg_id' => $egg->id,
                'nest_id' => $egg->nest_id,
                'node_id' => $allocation->node_id,
                'allocation_id' => $allocation->id,
                'memory' => $product->ram,
                'swap' => 0,
                'disk' => $product->disk,
                'cpu' => $product->cpu,
                'io' => 500,
                'startup' => $egg->startup,
                'image' => $image,
                'environment' => $environment,
                'database_limit' => 1, 'allocation_limit' => 1, 'backup_limit' => 1,
            ]);

            $user->decrement('balance', $product->price);
            $server->update(['is_billed' => true, 'expires_at' => Carbon::now()->addDays(30)]);
            return new JsonResponse(['status' => 'success']);
        } catch (\Exception $e) { return new JsonResponse(['error' => $e->getMessage()], 500); }
    }

    public function webhook(Request $request): JsonResponse
    {
        $data = $request->all();
        Log::info('MustikaPay webhook received', $data);
        $status = strtoupper($data['status'] ?? ($data['data']['status'] ?? ''));
        if ($status === 'SUCCESS' || $status === 'PAID') {
            $ref = $data['reference'] ?? ($data['data']['ref_no'] ?? ($data['data']['reference'] ?? null));
            $transaction = MustikaPayTransaction::where('reference', $ref)->first();
            if ($transaction && $transaction->status === 'pending') {
                $transaction->update(['status' => 'success']);
                $transaction->user->increment('balance', $transaction->amount);
                Log::info("MustikaPay: transaction {$ref} confirmed, balance updated");
                return new JsonResponse(['status' => 'OK']);
            }
            Log::warning("MustikaPay: transaction {$ref} not found or already processed");
        }
        return new JsonResponse(['status' => 'ignored'], 200);
    }
}
