<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mustikapay_products', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->decimal('price', 16, 2);
            $table->integer('cpu');
            $table->integer('ram');
            $table->integer('disk');
            $table->integer('egg_id')->default(1);
            $table->integer('nest_id')->default(1);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mustikapay_products');
    }
};
