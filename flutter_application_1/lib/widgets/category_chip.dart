
import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF4F46E5);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? azul : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? azul
              : const Color(0xFFE5E8F0),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: azul.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 11,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(0xFF626B80),
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
