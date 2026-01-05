import 'package:flutter/material.dart';

class HomeActionButton extends StatelessWidget {
  const HomeActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.onPressed,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onPressed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextDirection direction = Directionality.of(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.surface.withOpacity(0.4),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: BorderSide(
          color: accentColor.withOpacity(0.8),
          width: 1.2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 26,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            direction == TextDirection.rtl
                ? Icons.chevron_left
                : Icons.chevron_right,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
