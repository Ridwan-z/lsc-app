import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? const Color(0xFF87CEEB))
              : (color ?? const Color(0xFF87CEEB)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? const Color(0xFF87CEEB))
                : (color ?? const Color(0xFF87CEEB)).withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (color ?? const Color(0xFF87CEEB)),
          ),
        ),
      ),
    );
  }
}
