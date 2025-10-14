<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Lecture extends Model
{
    use HasFactory, SoftDeletes;

    protected $primaryKey = 'lecture_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'lecture_id',
        'user_id',
        'category_id',
        'title',
        'description',
        'audio_url',
        'audio_format',
        'file_size',
        'duration',
        'recording_date',
        'recording_quality',
        'status',
        'processing_progress',
        'thumbnail_url',
        'is_favorite',
        'play_count',
        'last_played_at',
        'playback_position',
        'notes',
        'is_public',
        'share_token',
    ];

    protected $casts = [
        'file_size' => 'integer',
        'duration' => 'integer',
        'recording_date' => 'date',
        'processing_progress' => 'integer',
        'is_favorite' => 'boolean',
        'play_count' => 'integer',
        'last_played_at' => 'datetime',
        'playback_position' => 'integer',
        'is_public' => 'boolean',
        'deleted_at' => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            if (empty($model->lecture_id)) {
                $model->lecture_id = (string) Str::uuid();
            }
            if (empty($model->share_token)) {
                $model->share_token = Str::random(32);
            }
        });
    }

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id', 'category_id');
    }

    public function bookmarks()
    {
        return $this->hasMany(Bookmark::class, 'lecture_id', 'lecture_id');
    }

    public function transcript()
    {
        return $this->hasOne(Transcript::class, 'lecture_id', 'lecture_id');
    }

    public function summaries()
    {
        return $this->hasMany(Summary::class, 'lecture_id', 'lecture_id');
    }

    public function flashcards()
    {
        return $this->hasMany(Flashcard::class, 'lecture_id', 'lecture_id');
    }

    public function quizzes()
    {
        return $this->hasMany(Quiz::class, 'lecture_id', 'lecture_id');
    }

    public function tags()
    {
        return $this->belongsToMany(Tag::class, 'lecture_tags', 'lecture_id', 'tag_id');
    }

    public function studySessions()
    {
        return $this->hasMany(StudySession::class, 'lecture_id', 'lecture_id');
    }

    // Scopes
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    public function scopeFavorites($query)
    {
        return $query->where('is_favorite', true);
    }

    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    // Helper methods
    public function incrementPlayCount()
    {
        $this->play_count++;
        $this->last_played_at = now();
        $this->save();
    }

    public function toggleFavorite()
    {
        $this->is_favorite = !$this->is_favorite;
        $this->save();
    }
}
