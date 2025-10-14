<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory;

    protected $fillable = [
        'id',
        'name',
        'email',
        'password',
        'phone',
        'avatar_url',
        'institution',
        'major',
        'subscription_type',
        'storage_used',
        'storage_limit',
        'is_active',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'storage_used' => 'integer',
        'storage_limit' => 'integer',
        'is_active' => 'boolean',
    ];

    // Relationships
    public function categories()
    {
        return $this->hasMany(Category::class);
    }

    public function lectures()
    {
        return $this->hasMany(Lecture::class);
    }

    public function tags()
    {
        return $this->hasMany(Tag::class);
    }

    public function studySessions()
    {
        return $this->hasMany(StudySession::class);
    }

    public function settings()
    {
        return $this->hasOne(UserSetting::class);
    }

    // Helper methods
    public function hasStorageSpace($fileSize)
    {
        return ($this->storage_used + $fileSize) <= $this->storage_limit;
    }

    public function updateStorageUsed($fileSize)
    {
        $this->storage_used += $fileSize;
        $this->save();
    }
}
