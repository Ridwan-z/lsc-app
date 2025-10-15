import 'package:flutter/material.dart'; // ADD THIS IMPORT
import 'package:intl/intl.dart';
import 'category_model.dart'; // IMPORT FROM SEPARATE FILE
import 'bookmark_model.dart';
import 'tag_model.dart';

class LectureModel {
  final String lectureId;
  final String userId;
  final String? categoryId;
  final String title;
  final String? description;
  final String audioUrl;
  final String audioFormat;
  final int fileSize;
  final int duration;
  final DateTime recordingDate;
  final String recordingQuality;
  final String status;
  final int processingProgress;
  final String? notes;
  final bool isFavorite;
  final int playCount;
  final int? playbackPosition;
  final DateTime? lastPlayedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final CategoryModel? category; // NOW USING IMPORTED CategoryModel
  final List<BookmarkModel>? bookmarks;
  final List<TagModel>? tags;

  LectureModel({
    required this.lectureId,
    required this.userId,
    this.categoryId,
    required this.title,
    this.description,
    required this.audioUrl,
    required this.audioFormat,
    required this.fileSize,
    required this.duration,
    required this.recordingDate,
    required this.recordingQuality,
    required this.status,
    required this.processingProgress,
    this.notes,
    required this.isFavorite,
    required this.playCount,
    this.playbackPosition,
    this.lastPlayedAt,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.bookmarks,
    this.tags,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      lectureId: json['lecture_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      categoryId: json['category_id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'],
      audioUrl: json['audio_url'] ?? json['audioUrl'] ?? '',
      audioFormat: json['audio_format'] ?? json['audioFormat'] ?? 'mp3',
      fileSize: json['file_size'] ?? json['fileSize'] ?? 0,
      duration: json['duration'] ?? 0,
      recordingDate: json['recording_date'] != null
          ? DateTime.parse(json['recording_date'])
          : (json['recordingDate'] != null
                ? DateTime.parse(json['recordingDate'])
                : DateTime.now()),
      recordingQuality:
          json['recording_quality'] ?? json['recordingQuality'] ?? 'auto',
      status: json['status'] ?? 'completed',
      processingProgress:
          json['processing_progress'] ?? json['processingProgress'] ?? 100,
      notes: json['notes'],
      isFavorite:
          json['is_favorite'] == 1 ||
          json['is_favorite'] == true ||
          json['isFavorite'] == true,
      playCount: json['play_count'] ?? json['playCount'] ?? 0,
      playbackPosition: json['playback_position'] ?? json['playbackPosition'],
      lastPlayedAt: json['last_played_at'] != null
          ? DateTime.parse(json['last_played_at'])
          : (json['lastPlayedAt'] != null
                ? DateTime.parse(json['lastPlayedAt'])
                : null),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : (json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'])
                : DateTime.now()),
      category: json['category'] != null
          ? CategoryModel.fromJson(
              json['category'],
            ) // USING IMPORTED CategoryModel
          : null,
      bookmarks: json['bookmarks'] != null
          ? (json['bookmarks'] as List)
                .map((item) => BookmarkModel.fromJson(item))
                .toList()
          : null,
      tags: json['tags'] != null
          ? (json['tags'] as List)
                .map((item) => TagModel.fromJson(item))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lecture_id': lectureId,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'audio_url': audioUrl,
      'audio_format': audioFormat,
      'file_size': fileSize,
      'duration': duration,
      'recording_date': recordingDate.toIso8601String(),
      'recording_quality': recordingQuality,
      'status': status,
      'processing_progress': processingProgress,
      'notes': notes,
      'is_favorite': isFavorite,
      'play_count': playCount,
      'playback_position': playbackPosition,
      'last_played_at': lastPlayedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedDuration {
    final duration = Duration(seconds: this.duration);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get formattedDate {
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(recordingDate);
    } catch (e) {
      // Fallback ke format default jika locale error
      return DateFormat('dd MMM yyyy').format(recordingDate);
    }
  }

  String get formattedDateTime {
    try {
      return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(recordingDate);
    } catch (e) {
      // Fallback ke format default jika locale error
      return DateFormat('dd MMM yyyy HH:mm').format(recordingDate);
    }
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  bool get isProcessing => status == 'processing';
  bool get isRecording => status == 'recording';
  bool get isCompleted => status == 'completed';

  // Copy with method for updates
  LectureModel copyWith({
    String? title,
    String? description,
    String? categoryId,
    String? notes,
    bool? isFavorite,
    int? playbackPosition,
  }) {
    return LectureModel(
      lectureId: lectureId,
      userId: userId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl,
      audioFormat: audioFormat,
      fileSize: fileSize,
      duration: duration,
      recordingDate: recordingDate,
      recordingQuality: recordingQuality,
      status: status,
      processingProgress: processingProgress,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount,
      playbackPosition: playbackPosition ?? this.playbackPosition,
      lastPlayedAt: lastPlayedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      category: category,
      bookmarks: bookmarks,
      tags: tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LectureModel && other.lectureId == lectureId;
  }

  @override
  int get hashCode => lectureId.hashCode;
}
