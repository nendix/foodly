import 'package:flutter/material.dart';
import '../models/food.dart';
import '../models/recipe.dart';
import '../services/spoonacular_service.dart';
import '../services/connectivity_service.dart';

class RecipeNotifier extends ChangeNotifier {
  final SpoonacularService _recipeService = SpoonacularService();

  List<Recipe>? _recipes;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  List<Recipe>? get recipes => _recipes;

  List<Recipe>? get filteredRecipes {
    if (_recipes == null) return null;

    List<Recipe> filtered = _recipes!;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((recipe) =>
              recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadRecipes(List<Food> foods) async {
    if (foods.isEmpty) {
      _recipes = [];
      notifyListeners();
      return;
    }

    if (!await hasInternetConnection()) {
      _error =
          'No internet connection. Please check your connection and try again.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ingredients = foods.map((f) => f.name).toList();
      final recipes = await _recipeService.findByIngredients(ingredients);

      recipes.sort((a, b) => b.possessedCount.compareTo(a.possessedCount));

      _recipes = recipes;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
