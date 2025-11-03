import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../models/recipe.dart';
import '../theme/theme.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/recipe_card.dart';
import '../providers/recipe_notifier.dart';

class RecipesScreen extends StatelessWidget {
  final List<Food> foods;

  const RecipesScreen({super.key, required this.foods});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeNotifier()..loadRecipes(foods),
      child: _RecipesScreenContent(foods: foods),
    );
  }
}

class _RecipesScreenContent extends StatefulWidget {
  final List<Food> foods;

  const _RecipesScreenContent({required this.foods});

  @override
  State<_RecipesScreenContent> createState() => _RecipesScreenContentState();
}

class _RecipesScreenContentState extends State<_RecipesScreenContent> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearch(String query) {
    context.read<RecipeNotifier>().setSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.foods.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.restaurant_menu,
        title: 'Add foods to get recipe suggestions',
        iconColor: Theme.of(context).colorScheme.primary,
        expanded: false,
      );
    }

    return Consumer<RecipeNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isLoading) {
          return const LoadingWidget(message: 'Finding recipes...');
        }

        if (notifier.recipes == null || notifier.recipes!.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.no_meals,
            title: 'No recipes found',
            iconColor: Theme.of(context).colorScheme.primary,
            actionLabel: 'Retry',
            actionIcon: Icons.refresh,
            onActionPressed: () => notifier.loadRecipes(widget.foods),
            expanded: false,
          );
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search recipes...',
                leading: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _updateSearch('');
                      },
                    ),
                ],
                onChanged: _updateSearch,
              ),
            ),
            if (notifier.filteredRecipes == null ||
                notifier.filteredRecipes!.isEmpty)
              Expanded(
                child: EmptyStateWidget(
                  icon: Icons.search_off,
                  title: 'No recipes match your search',
                  iconColor: Theme.of(context).colorScheme.primary,
                  expanded: false,
                ),
              )
             else
               Expanded(
                 child: NotificationListener<ScrollNotification>(
                   onNotification: (ScrollNotification scrollInfo) {
                     if (!notifier.isLoadingMore &&
                         notifier.hasMoreRecipes &&
                         scrollInfo.metrics.pixels >=
                             scrollInfo.metrics.maxScrollExtent * 0.8) {
                       notifier.loadMoreRecipes();
                     }
                     return false;
                   },
                   child: ListView.separated(
                     padding: EdgeInsets.all(AppSpacing.lg),
                     itemCount: notifier.filteredRecipes!.length +
                         (notifier.isLoadingMore ? 1 : 0),
                     separatorBuilder: (context, index) {
                       if (index == notifier.filteredRecipes!.length) {
                         return SizedBox.shrink();
                       }
                       return SizedBox(height: AppSpacing.md);
                     },
                     itemBuilder: (context, index) {
                       if (index == notifier.filteredRecipes!.length) {
                         return Padding(
                           padding: EdgeInsets.symmetric(
                             vertical: AppSpacing.lg,
                           ),
                           child: Center(
                             child: SizedBox(
                               width: 24,
                               height: 24,
                               child: CircularProgressIndicator(
                                 strokeWidth: 2,
                                 valueColor: AlwaysStoppedAnimation(
                                   Theme.of(context).colorScheme.primary,
                                 ),
                               ),
                             ),
                           ),
                         );
                       }
                       final recipe = notifier.filteredRecipes![index];
                       return RecipeCard(
                         recipe: recipe,
                         onTap: () => showRecipeDetails(context, recipe),
                       );
                     },
                   ),
                 ),
               ),
          ],
        );
      },
    );
  }

  void showRecipeDetails(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  recipe.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.lg),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    recipe.image,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                if (recipe.possessedIngredients.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Possessed Ingredients (${recipe.possessedIngredients.length})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: AppSpacing.md),
                      ...recipe.possessedIngredients.map(
                        (ing) => Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: AppSpacing.lg - 6),
                              Expanded(
                                child: Text(
                                  ing,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                if (recipe.missingIngredients.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Missing Ingredients (${recipe.missingIngredients.length})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: AppSpacing.md),
                      ...recipe.missingIngredients.map(
                        (ing) => Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  ing,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
