import 'package:flutter/material.dart';
import '../theme/theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? searchQuery;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final IconData? actionIcon;
  final Color? iconColor;
  final double iconSize;
  final bool expanded;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.searchQuery,
    this.onActionPressed,
    this.actionLabel,
    this.actionIcon,
    this.iconColor,
    this.iconSize = 64,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.accentOrange.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textGreyLight,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onActionPressed != null && actionLabel != null) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onActionPressed,
              icon: Icon(actionIcon ?? Icons.refresh),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );

    return expanded ? Expanded(child: widget) : widget;
  }
}
