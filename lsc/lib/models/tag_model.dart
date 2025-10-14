import 'package:flutter/material.dart';

class TagModel {
  final String tagId;
  final String name;
  final String? color;

  TagModel({required this.tagId, required this.name, this.color});

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      tagId: json['tag_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'tag_id': tagId, 'name': name, 'color': color};
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
        return const Color(0xFF87CEEB);
      }
    }
    return const Color(0xFF87CEEB);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagModel && other.tagId == tagId;
  }

  @override
  int get hashCode => tagId.hashCode;
}
