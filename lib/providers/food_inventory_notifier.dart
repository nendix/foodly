import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/storage_service.dart';

class FoodInventoryNotifier extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Food> _foods = [];
  String _searchQuery = '';
  String? _error;

  List<Food> get foods {
    return _getFilteredFoods();
  }

  String get searchQuery => _searchQuery;

  String? get error => _error;

  FoodInventoryNotifier() {
    _loadFoods();
  }

  void _loadFoods() {
    try {
      _foods = _storageService.getAllFoods();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load foods: $e';
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Food> _getFilteredFoods() {
    List<Food> filtered = _foods;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (food) =>
                food.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  void addFood(Food food) {
    try {
      _storageService.addFood(food);
      _error = null;
      _loadFoods();
    } catch (e) {
      _error = 'Failed to add food: $e';
      notifyListeners();
    }
  }

  void updateFood(Food food) {
    try {
      _storageService.updateFood(food);
      _error = null;
      _loadFoods();
    } catch (e) {
      _error = 'Failed to update food: $e';
      notifyListeners();
    }
  }

  void deleteFood(String id) {
    try {
      _storageService.deleteFood(id);
      _error = null;
      _loadFoods();
    } catch (e) {
      _error = 'Failed to delete food: $e';
      notifyListeners();
    }
  }
}
