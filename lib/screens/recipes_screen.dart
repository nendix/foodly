import 'package:flutter/material.dart';
import '../models/food.dart';
import '../models/recipe.dart';
import '../services/spoonacular_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/recipe_card.dart';
import '../services/connectivity_service.dart';
import '../widgets/snackbar_helper.dart';

class RecipesScreen extends StatefulWidget {
  final List<Food> foods;

  const RecipesScreen({super.key, required this.foods});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  late SpoonacularService _recipeService;
  List<Recipe>? _recipes;
  List<Recipe>? _filteredRecipes;
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recipeService = SpoonacularService();
    _loadRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    if (widget.foods.isEmpty) return;

    if (!await hasInternetConnection()) {
      if (mounted) {
        showErrorSnackbar(
          context,
          'No internet connection. Please check your connection and try again.',
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ingredients = widget.foods.map((f) => f.name).toList();
      final recipes = await _recipeService.findByIngredients(ingredients);
      if (mounted) {
        recipes.sort((a, b) => b.possessedCount.compareTo(a.possessedCount));
        setState(() {
          _recipes = recipes;
          _applySearch();
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applySearch() {
    if (_recipes == null) return;

    List<Recipe> filtered = _recipes!;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (recipe) =>
                recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    setState(() => _filteredRecipes = filtered);
  }

  void _updateSearch(String query) {
    _searchQuery = query;
    _applySearch();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.foods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add foods to get recipe suggestions',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const LoadingWidget(message: 'Finding recipes...');
    }

    if (_recipes == null || _recipes!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.no_meals,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No recipes found',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadRecipes,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
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
        if (_filteredRecipes == null || _filteredRecipes!.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No recipes match your search',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
         else
           Expanded(
             child: ListView.separated(
               padding: const EdgeInsets.all(16),
               itemCount: _filteredRecipes!.length,
               separatorBuilder: (context, index) => const SizedBox(height: 12),
               itemBuilder: (context, index) {
                 final recipe = _filteredRecipes![index];
                 return RecipeCard(
                   recipe: recipe,
                   onTap: () => showRecipeDetails(context, recipe),
                 );
               },
             ),
           ),
      ],
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
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 16),
                Text(
                  recipe.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                if (recipe.possessedIngredients.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Possessed Ingredients (${recipe.possessedIngredients.length})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...recipe.possessedIngredients.map(
                        (ing) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
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
                              const SizedBox(width: 10),
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
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 12),
                      ...recipe.missingIngredients.map(
                        (ing) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
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
                              const SizedBox(width: 10),
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
