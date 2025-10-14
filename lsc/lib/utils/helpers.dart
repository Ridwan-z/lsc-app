import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Format duration (seconds to HH:MM:SS)
  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
  
  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }
  
  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(date);
  }
  
  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? ThemeConfig.errorColor : ThemeConfig.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  // Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  // Get priority color
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return const Color(0xFFFF6B6B);
      case 'medium':
        return const Color(0xFFFFD700);
      case 'low':
        return const Color(0xFF87CEEB);
      default:
        return Colors.grey;
    }
  }
}

class ThemeConfig {
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF4CAF50);
}