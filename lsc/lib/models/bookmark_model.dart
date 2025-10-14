import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class BookmarkModel {
  final String bookmarkId;
  final String lectureId;
  final int timestamp;
  final String? title;
  final String? note;
  final String priority;
  final String? color;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookmarkModel({
    required this.bookmarkId,
    required this.lectureId,
    required this.timestamp,
    this.title,
    this.note,
    required this.priority,
    this.color,
    required this.isResolved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      bookmarkId:
          json['bookmark_id']?.toString() ?? json['id']?.toString() ?? '',
      lectureId:
          json['lecture_id']?.toString() ?? json['lectureId']?.toString() ?? '',
      timestamp: json['timestamp'] ?? 0,
      title: json['title'],
      note: json['note'],
      priority: json['priority'] ?? 'medium',
      color: json['color'],
      isResolved:
          json['is_resolved'] == 1 ||
          json['is_resolved'] == true ||
          json['isResolved'] == true,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookmark_id': bookmarkId,
      'lecture_id': lectureId,
      'timestamp': timestamp,
      'title': title,
      'note': note,
      'priority': priority,
      'color': color,
      'is_resolved': isResolved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedTimestamp {
    final duration = Duration(seconds: timestamp);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get formattedCreatedAt {
    return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(createdAt);
  }

  Color get colorValue {
    if (color != null) {
      try {
        String hexColor = color!.replaceAll('#', '');
        if (hexColor.length == 6) {
          hexColor = 'FF$hexColor';
        }
        return Color(int.parse(hexColor, radix: 16));
      } catch (e) {
        // Fall through to default colors
      }
    }

    switch (priority) {
      case 'high':
        return const Color(0xFFFF6B6B);
      case 'medium':
        return const Color(0xFFFFD700);
      case 'low':
        return const Color(0xFF87CEEB);
      default:
        return const Color(0xFFD3D3D3);
    }
  }

  // Copy with method for updates
  BookmarkModel copyWith({
    String? title,
    String? note,
    String? priority,
    String? color,
    bool? isResolved,
  }) {
    return BookmarkModel(
      bookmarkId: bookmarkId,
      lectureId: lectureId,
      timestamp: timestamp,
      title: title ?? this.title,
      note: note ?? this.note,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      isResolved: isResolved ?? this.isResolved,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookmarkModel && other.bookmarkId == bookmarkId;
  }

  @override
  int get hashCode => bookmarkId.hashCode;
}
