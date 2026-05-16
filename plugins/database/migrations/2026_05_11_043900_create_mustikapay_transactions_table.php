<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('mustikapay_transactions')) {
            Schema::create('mustikapay_transactions', function (Blueprint $table) {
                $table->id();
                $table->integer('user_id');
                $table->string('reference');
                $table->decimal('amount', 16, 2);
                $table->string('status')->default('pending');
                $table->string('payment_method')->nullable();
                $table->text('payment_code')->nullable();
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('mustikapay_transactions');
    }
};
