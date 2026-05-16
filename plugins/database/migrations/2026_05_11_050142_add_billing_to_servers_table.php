<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('servers', 'is_billed')) {
            Schema::table('servers', function (Blueprint $table) {
                $table->boolean('is_billed')->default(false);
                $table->timestamp('expires_at')->nullable();
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('servers', 'is_billed')) {
            Schema::table('servers', function (Blueprint $table) {
                $table->dropColumn(['is_billed', 'expires_at']);
            });
        }
    }
};
