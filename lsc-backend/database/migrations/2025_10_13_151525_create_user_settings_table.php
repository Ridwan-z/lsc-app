<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('user_settings', function (Blueprint $table) {
            $table->char('setting_id', 36)->primary();
            $table->char('user_id', 36)->unique();
            $table->enum('default_recording_quality', ['auto', 'standard', 'high'])->default('auto');
            $table->boolean('auto_backup')->default(true);
            $table->boolean('auto_transcribe')->default(true);
            $table->decimal('default_playback_speed', 2, 1)->default(1.0); // 0.5-3.0
            $table->boolean('skip_silence')->default(true);
            $table->boolean('notification_enabled')->default(true);
            $table->enum('theme', ['light', 'dark', 'auto'])->default('auto');
            $table->string('language', 10)->default('id');
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_settings');
    }
};
