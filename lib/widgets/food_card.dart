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
    if (food.expiryDate == null) return '';
    if (food.isExpired) return 'EXPIRED';
    if (food.expiringSoon) {
      final daysLeft = food.expiryDate!.difference(DateTime.now()).inDays;
      return 'EXPIRES IN $daysLeft D';
    }
    return '';
  }

  Color get _expiryColor {
    if (food.isExpired) return Colors.red;
    if (food.expiringSoon) return Colors.orange;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (food.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      food.imageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  food.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${food.quantity} ${food.unit}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (food.expiryDate != null)
                      Text(
                        food.expiryDate!.toString().split(' ')[0],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_expiryStatus.isNotEmpty)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _expiryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  _expiryStatus,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
