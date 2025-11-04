import 'package:flutter/material.dart';
import '../theme/theme.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                'Welcome to foodly',
                'Manage your kitchen pantry and discover recipes based on the ingredients you have available.',
              ),
              SizedBox(height: AppSpacing.xl),
              _buildSection(
                context,
                'Pantry Management',
                'Use the Pantry tab to manage your food items.',
              ),
              SizedBox(height: AppSpacing.md),
              _buildInstructionItem(
                context,
                Icons.add_circle,
                'Add Food',
                'Tap the + button to add a new item to your pantry. You can scan barcodes or search by name.',
              ),
              SizedBox(height: AppSpacing.md),
              _buildInstructionItem(
                context,
                Icons.search,
                'Search Items',
                'Use the search bar to filter items in your pantry by name.',
              ),
              SizedBox(height: AppSpacing.md),
              _buildInstructionItem(
                context,
                Icons.arrow_back,
                'Swipe Left to Delete',
                'Swipe a food card to the left to remove it from your pantry.',
              ),
              SizedBox(height: AppSpacing.md),
              _buildInstructionItem(
                context,
                Icons.arrow_forward,
                'Swipe Right to Edit',
                'Swipe a food card to the right to edit its details.',
              ),
              SizedBox(height: AppSpacing.xl),
              _buildSection(
                context,
                'Recipes',
                'Switch to the Recipes tab to discover recipes based on the ingredients in your pantry.',
              ),
              SizedBox(height: AppSpacing.md),
              _buildInstructionItem(
                context,
                Icons.restaurant_menu,
                'Browse Recipes',
                'Recipes are automatically suggested based on your pantry items. Search and filter recipes to find what you like.',
              ),
              SizedBox(height: AppSpacing.xl),
              _buildSection(
                context,
                'Expiry Tracking',
                'Monitor your food expiry dates. Items are highlighted based on their expiry status:',
              ),
              SizedBox(height: AppSpacing.md),
              _buildExpiryStatus(
                context,
                'Green',
                'Not expiring soon',
                Colors.green,
              ),
              SizedBox(height: AppSpacing.sm),
              _buildExpiryStatus(
                context,
                'Orange',
                'Expiring within 3 days',
                Colors.orange,
              ),
              SizedBox(height: AppSpacing.sm),
              _buildExpiryStatus(context, 'Red', 'Already expired', Colors.red),
              SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it!'),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(description, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildInstructionItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryStatus(
    BuildContext context,
    String label,
    String description,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label - ',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
