import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/storage_service.dart';

class PantryNotifier extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Food> _items = [];
  String _searchQuery = '';
  String? _error;

  List<Food> get items {
    return _getFilteredItems();
  }

  String get searchQuery => _searchQuery;

  String? get error => _error;

  PantryNotifier() {
    _loadItems();
  }

  void _loadItems() {
    try {
      _items = _storageService.getAllFoods();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load items: $e';
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Food> _getFilteredItems() {
    List<Food> filtered = _items;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return _sortByExpiryDate(filtered);
  }

  List<Food> _sortByExpiryDate(List<Food> items) {
    return items
      ..sort((a, b) {
        final aExpiry = a.expiryDate;
        final bExpiry = b.expiryDate;

        if (aExpiry == null && bExpiry == null) {
          return a.name.compareTo(b.name);
        }
        if (aExpiry == null) return 1;
        if (bExpiry == null) return -1;

        final comparison = aExpiry.compareTo(bExpiry);
        if (comparison != 0) return comparison;

        return a.name.compareTo(b.name);
      });
  }

  void addItem(Food item) {
    try {
      _storageService.addFood(item);
      _error = null;
      _loadItems();
    } catch (e) {
      _error = 'Failed to add item: $e';
      notifyListeners();
    }
  }

  void updateItem(Food item) {
    try {
      _storageService.updateFood(item);
      _error = null;
      _loadItems();
    } catch (e) {
      _error = 'Failed to update item: $e';
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    try {
      _storageService.deleteFood(id);
      _error = null;
      _loadItems();
    } catch (e) {
      _error = 'Failed to delete item: $e';
      notifyListeners();
    }
  }
}
