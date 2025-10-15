<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\Lecture;

class LectureController extends Controller
{
    /**
     * Get all lectures for authenticated user
     */
    public function index(Request $request)
    {
        $lectures = Lecture::where('user_id', $request->user()->id)
            ->with(['category', 'bookmarks', 'tags'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $lectures
        ], 200);
    }

    /**
     * Store new lecture
     */
    public function create(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'nullable|exists:categories,category_id',
            'recording_date' => 'required|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Create lecture with status 'recording' (menunggu audio)
        $lecture = Lecture::create([
            'user_id' => $request->user()->id,
            'category_id' => $request->category_id,
            'title' => $request->title,
            'description' => $request->description,
            'audio_url' => '', // Temporary empty value
            'recording_date' => $request->recording_date,
            'status' => 'recording', // Status recording = belum ada audio
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Lecture created successfully. Please upload audio file.',
            'data' => $lecture
        ], 201);
    }

    /**
     * Step 2: Upload audio to existing lecture
     */
    public function uploadAudio(Request $request, $lectureId)
    {
        $lecture = Lecture::where('lecture_id', $lectureId)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        // Cek apakah lecture sudah punya audio
        if ($lecture->status !== 'recording') {
            return response()->json([
                'success' => false,
                'message' => 'This lecture already has an audio file'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'audio_file' => 'required|file|mimes:mp3,m4a,wav|max:512000', // Max 500MB
            'recording_quality' => 'nullable|in:auto,standard,high',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Check storage limit
        $fileSize = $request->file('audio_file')->getSize();
        if (!$request->user()->hasStorageSpace($fileSize)) {
            return response()->json([
                'success' => false,
                'message' => 'Storage limit exceeded'
            ], 403);
        }

        // Upload audio file
        $audioPath = $request->file('audio_file')->store('lectures/' . $request->user()->id, 'public');
        $audioUrl = asset('storage/' . $audioPath);

        // Get audio duration (you'll need getID3 library for this)
        $duration = 0; // Placeholder

        // Update lecture with audio information
        $lecture->update([
            'audio_url' => $audioUrl,
            'audio_format' => $request->file('audio_file')->extension(),
            'file_size' => $fileSize,
            'duration' => $duration,
            'recording_quality' => $request->recording_quality ?? 'auto',
            'status' => 'processing',
            'processing_progress' => 0,
        ]);

        // Update user storage
        $request->user()->updateStorageUsed($fileSize);

        // Dispatch processing job
        // ProcessAudioJob::dispatch($lecture);

        return response()->json([
            'success' => true,
            'message' => 'Audio uploaded successfully',
            'data' => $lecture->fresh()
        ], 200);
    }
    /**
     * Get specific lecture
     */
    public function show(Request $request, $id)
    {
        $lecture = Lecture::where('lecture_id', $id)
            ->where('user_id', $request->user()->id)
            ->with(['category', 'bookmarks', 'transcript', 'summaries', 'flashcards', 'quizzes', 'tags'])
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => $lecture
        ], 200);
    }

    /**
     * Update lecture
     */
    public function update(Request $request, $id)
    {
        $lecture = Lecture::where('lecture_id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $validator = Validator::make($request->all(), [
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'nullable|exists:categories,category_id',
            'notes' => 'nullable|string',
            'is_favorite' => 'nullable|boolean',
            'playback_position' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $lecture->update($request->only([
            'title',
            'description',
            'category_id',
            'notes',
            'is_favorite',
            'playback_position'
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Lecture updated successfully',
            'data' => $lecture
        ], 200);
    }

    /**
     * Delete lecture (soft delete)
     */
    public function destroy(Request $request, $id)
    {
        $lecture = Lecture::where('lecture_id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $lecture->delete();

        return response()->json([
            'success' => true,
            'message' => 'Lecture moved to trash'
        ], 200);
    }

    /**
     * Toggle favorite
     */
    public function toggleFavorite(Request $request, $id)
    {
        $lecture = Lecture::where('lecture_id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $lecture->toggleFavorite();

        return response()->json([
            'success' => true,
            'message' => 'Favorite status updated',
            'data' => ['is_favorite' => $lecture->is_favorite]
        ], 200);
    }

    /**
     * Increment play count
     */
    public function play(Request $request, $id)
    {
        $lecture = Lecture::where('lecture_id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $lecture->incrementPlayCount();

        return response()->json([
            'success' => true,
            'message' => 'Play count updated',
            'data' => ['play_count' => $lecture->play_count]
        ], 200);
    }
}
