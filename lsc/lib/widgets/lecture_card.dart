import 'dart:ffi';

import 'package:flutter/material.dart';
import '../models/lecture_model.dart';

class LectureCard extends StatelessWidget {
  final LectureModel lecture;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onMoreOptions;

  const LectureCard({
    super.key,
    required this.lecture,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Icon

                  // Category
                  if (lecture.category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF87CEEB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lecture.category!.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2C5F77),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  const Spacer(),
                  IconButton(
                    onPressed: onMoreOptions,
                    icon: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Colors.grey,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  // Favorite Button
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                lecture.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C5F77),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (lecture.description != null &&
                  lecture.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  lecture.description!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Metadata Row
              Row(
                children: [
                  // Duration
                  _buildMetadata(
                    Icons.timer_outlined,
                    lecture.formattedDuration,
                  ),
                  const SizedBox(width: 16),
                  // Date
                  _buildMetadata(
                    Icons.calendar_today_outlined,
                    lecture.formattedDate,
                  ),
                  const SizedBox(width: 16),
                  // File Size
                  _buildMetadata(
                    Icons.storage_outlined,
                    lecture.formattedFileSize,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      lecture.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: lecture.isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Progress Bar (if processing)
              if (lecture.isProcessing) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: lecture.processingProgress / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                ),
                const SizedBox(height: 4),
                Text(
                  'Processing: ${lecture.processingProgress}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadata(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Color _getStatusColor() {
    switch (lecture.status) {
      case 'recording':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
