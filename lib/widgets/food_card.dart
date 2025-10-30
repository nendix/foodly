import 'package:flutter/material.dart';
import '../models/food.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const FoodCard({
    super.key,
    required this.food,
    required this.onDelete,
    required this.onEdit,
  });

  String get _expiryStatus {
    if (food.expiryDate == null) return 'No expiry date';
    if (food.isExpired) return 'Expired';

    final daysLeft = food.daysUntilExpiry;

    if (daysLeft == 0) return 'Expires today';
    if (daysLeft == 1) return 'Expires tomorrow';

    return 'Expires in $daysLeft days';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onDoubleTap: onEdit,
                    child: Text(
                      food.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${food.quantity} ${food.unit}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _expiryStatus,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
