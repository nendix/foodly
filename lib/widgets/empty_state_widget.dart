import 'package:flutter/material.dart';
import '../theme/theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final String searchQuery;

  const EmptyStateWidget({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
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
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.accentOrange.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? 'No foods match your search'
                  : 'No foods added yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textGreyLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a food item',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
