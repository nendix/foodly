import 'dart:async';
import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/open_food_facts_service.dart';
import '../widgets/loading_widget.dart';
import '../theme/theme.dart';
import '../services/connectivity_service.dart';
import '../widgets/snackbar_helper.dart';
import 'scanner_screen.dart';

class FoodScreen extends StatefulWidget {
  final Food? food;

  const FoodScreen({super.key, this.food});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _barcodeController;

  DateTime? _expiryDate;
  String _selectedUnit = 'g';
  bool _isLoading = false;
  final OpenFoodFactsService _apiService = OpenFoodFactsService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.food?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.food?.quantity.toString() ?? '1',
    );
    _barcodeController = TextEditingController(
      text: widget.food?.barcode ?? '',
    );
    _expiryDate = widget.food?.expiryDate;
    _selectedUnit = widget.food?.unit ?? 'g';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime(now.year, now.month + 1, now.day),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _scanBarcode() async {
    final hasConnection = await hasInternetConnection();
    if (!hasConnection) {
      if (!mounted) return;
      showErrorSnackbar(context, 'No internet connection');
      return;
    }

    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );

    if (result != null && result is String && result.isNotEmpty) {
      _barcodeController.text = result;
      await _fetchFoodFromBarcode(result);
    }
  }

  Future<void> _fetchFoodFromBarcode(String barcode) async {
    setState(() => _isLoading = true);
    try {
      final food = await _apiService.searchByBarcode(barcode);
      if (!mounted) return;
      if (food != null) {
        setState(() {
          _nameController.text = food.name;
        });
      } else {
        showErrorSnackbar(context, 'Food not found');
      }
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Failed to fetch food info: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _saveFoodItem() {
    if (_nameController.text.isEmpty) {
      showErrorSnackbar(context, 'Please enter food name');
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 1;

    final food = Food(
      id: widget.food?.id ?? DateTime.now().toString(),
      name: _nameController.text,
      quantity: quantity,
      unit: _selectedUnit,
      barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
      expiryDate: _expiryDate,
      addedDate: widget.food?.addedDate ?? DateTime.now(),
    );

    Navigator.pop(context, food);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget(message: 'Fetching food information...');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.food == null ? 'Add Food' : 'Edit Food'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Food Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Food name',
                hintText: 'Enter food name',
                prefixIcon: Icon(Icons.fastfood),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Quantity & Unit'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      hintText: '1',
                      prefixIcon: Icon(Icons.scale),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownMenu(
                    initialSelection: _selectedUnit,
                    onSelected: (value) {
                      setState(() => _selectedUnit = value ?? 'g');
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 'g', label: 'g'),
                      DropdownMenuEntry(value: 'kg', label: 'kg'),
                      DropdownMenuEntry(value: 'ml', label: 'ml'),
                      DropdownMenuEntry(value: 'L', label: 'L'),
                      DropdownMenuEntry(value: 'pcs', label: 'pcs'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Barcode'),
            const SizedBox(height: 8),
            TextField(
              controller: _barcodeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Barcode',
                hintText: 'Enter or scan barcode',
                prefixIcon: const Icon(Icons.barcode_reader),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanBarcode,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: AppColors.accentOrange,
                ),
                title: Text(
                  _expiryDate == null
                      ? 'Set Expiry Date (Optional)'
                      : 'Expires: ${_expiryDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _selectExpiryDate,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveFoodItem,
                icon: const Icon(Icons.save),
                label: Text(widget.food == null ? 'Add Food' : 'Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.accentOrange,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
