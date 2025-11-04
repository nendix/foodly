import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/open_food_facts_service.dart';
import '../services/connectivity_service.dart';

class FoodFormNotifier extends ChangeNotifier {
  final OpenFoodFactsService _apiService = OpenFoodFactsService();
  final Food? initialFood;

  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController barcodeController;

  DateTime? expiryDate;
  String selectedUnit = 'g';
  bool isLoading = false;
  String? error;

  FoodFormNotifier({this.initialFood}) {
    _initializeControllers();
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: initialFood?.name ?? '');
    quantityController = TextEditingController(
      text: initialFood?.quantity.toString() ?? '1',
    );
    barcodeController = TextEditingController(text: initialFood?.barcode ?? '');
    expiryDate = initialFood?.expiryDate;
    selectedUnit = initialFood?.unit ?? 'g';
  }

  Future<void> fetchFoodFromBarcode(String barcode) async {
    if (!await hasInternetConnection()) {
      error = 'No internet connection. Please check your network and try again.';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final food = await _apiService.searchByBarcode(barcode);
      if (food != null) {
        nameController.text = food.name;
        error = null;
      } else {
        error = 'Food not found';
      }
    } catch (e) {
      if (e.toString().contains('Network Error')) {
        error = e.toString().replaceFirst('Network Error: ', '');
      } else if (e.toString().contains('Server Error')) {
        error = 'Server error. Please try again later.';
      } else {
        error = 'Failed to fetch food information. Please try again.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setExpiryDate(DateTime? date) {
    expiryDate = date;
    notifyListeners();
  }

  void setUnit(String unit) {
    selectedUnit = unit;
    notifyListeners();
  }

  Food? buildFood() {
    if (nameController.text.isEmpty) {
      error = 'Please enter food name';
      notifyListeners();
      return null;
    }

    final quantity = int.tryParse(quantityController.text) ?? 1;

    return Food(
      id: initialFood?.id ?? DateTime.now().toString(),
      name: nameController.text,
      quantity: quantity,
      unit: selectedUnit,
      barcode: barcodeController.text.isEmpty ? null : barcodeController.text,
      expiryDate: expiryDate,
      addedDate: initialFood?.addedDate ?? DateTime.now(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    barcodeController.dispose();
    super.dispose();
  }
}
