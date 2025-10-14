import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  final String categoryId;
  final String userId;
  final String name;
  final String? color;
  final String? icon;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int lecturesCount;

  CategoryModel({
    required this.categoryId,
    required this.userId,
    required this.name,
    this.color,
    this.icon,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.lecturesCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId:
          json['category_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      name: json['name'] ?? '',
      color: json['color'],
      icon: json['icon'],
      description: json['description'],
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
      lecturesCount: json['lectures_count'] ?? json['lecturesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'user_id': userId,
      'name': name,
      'color': color,
      'icon': icon,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'lectures_count': lecturesCount,
    };
  }

  String get formattedCreatedAt {
    return DateFormat('dd MMM yyyy', 'id_ID').format(createdAt);
  }

  String get formattedUpdatedAt {
    return DateFormat('dd MMM yyyy', 'id_ID').format(updatedAt);
  }

  Color get colorValue {
    if (color == null) return const Color(0xFF87CEEB);

    try {
      String hexColor = color!.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFF87CEEB);
    }
  }

  String get displayIcon {
    return icon ?? _getDefaultIcon();
  }

  String _getDefaultIcon() {
    switch (name.toLowerCase()) {
      case 'matematika':
        return '➕';
      case 'fisika':
        return '⚛️';
      case 'kimia':
        return '🧪';
      case 'biologi':
        return '🧬';
      case 'sejarah':
        return '📜';
      case 'bahasa':
        return '🔤';
      case 'pemrograman':
        return '💻';
      case 'ekonomi':
        return '💹';
      case 'seni':
        return '🎨';
      case 'musik':
        return '🎵';
      default:
        return '📁';
    }
  }

  // Copy with method for updates
  CategoryModel copyWith({
    String? name,
    String? color,
    String? icon,
    String? description,
  }) {
    return CategoryModel(
      categoryId: categoryId,
      userId: userId,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lecturesCount: lecturesCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.categoryId == categoryId;
  }

  @override
  int get hashCode => categoryId.hashCode;
}
