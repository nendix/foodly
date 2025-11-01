import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/open_food_facts_service.dart';

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
    barcodeController = TextEditingController(
      text: initialFood?.barcode ?? '',
    );
    expiryDate = initialFood?.expiryDate;
    selectedUnit = initialFood?.unit ?? 'g';
  }

  Future<void> fetchFoodFromBarcode(String barcode) async {
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
      error = 'Failed to fetch food info: $e';
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
