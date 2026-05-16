<?php

namespace Pterodactyl\Models;

use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MustikaPayTransaction extends Model
{
    protected $table = 'mustikapay_transactions';

    protected $fillable = [
        'user_id',
        'reference',
        'external_id',
        'amount',
        'status',
        'payment_method',
        'payment_code',
        'payment_url',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
