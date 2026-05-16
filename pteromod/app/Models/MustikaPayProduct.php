<?php

namespace Pterodactyl\Models;

class MustikaPayProduct extends Model
{
    protected $table = 'mustikapay_products';

    protected $fillable = [
        'name',
        'price',
        'cpu',
        'ram',
        'disk',
        'egg_id',
        'nest_id',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'cpu' => 'integer',
        'ram' => 'integer',
        'disk' => 'integer',
    ];
}
