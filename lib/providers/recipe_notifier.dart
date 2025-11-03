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
  bool _isLoadingMore = false;
  String? _error;
  
  int _offset = 0;
  final int _itemsPerPage = 10;
  bool _hasMoreRecipes = true;
  List<Food>? _currentFoods;

  List<Recipe>? get recipes => _recipes;

  List<Recipe>? get filteredRecipes {
    if (_recipes == null) return null;

    List<Recipe> filtered = _recipes!;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (recipe) =>
                recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasMoreRecipes => _hasMoreRecipes;

  Future<void> loadRecipes(List<Food> foods) async {
    if (foods.isEmpty) {
      _recipes = [];
      _offset = 0;
      _hasMoreRecipes = false;
      notifyListeners();
      return;
    }

    _currentFoods = foods;
    _offset = 0;
    _hasMoreRecipes = true;

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
      final recipes = await _recipeService.findByIngredients(
        ingredients,
        offset: _offset,
        number: _itemsPerPage,
      );

      recipes.sort((a, b) => b.possessedCount.compareTo(a.possessedCount));

      _recipes = recipes;
      _offset += _itemsPerPage;
      _hasMoreRecipes = recipes.length == _itemsPerPage;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreRecipes() async {
    if (_isLoadingMore || !_hasMoreRecipes || _currentFoods == null) {
      return;
    }

    if (!await hasInternetConnection()) {
      _error = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final ingredients = _currentFoods!.map((f) => f.name).toList();
      final moreRecipes = await _recipeService.findByIngredients(
        ingredients,
        offset: _offset,
        number: _itemsPerPage,
      );

      if (moreRecipes.isEmpty) {
        _hasMoreRecipes = false;
      } else {
        _recipes!.addAll(moreRecipes);
        _offset += _itemsPerPage;
        _hasMoreRecipes = moreRecipes.length == _itemsPerPage;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
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
