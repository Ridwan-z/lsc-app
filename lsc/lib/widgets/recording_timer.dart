import 'package:flutter/material.dart';

class RecordingTimer extends StatelessWidget {
  final Duration duration;
  final bool isRecording;

  const RecordingTimer({
    super.key,
    required this.duration,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF87CEEB).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Recording Indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isRecording ? Colors.red : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Timer Text
          Text(
            hours > 0
                ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
