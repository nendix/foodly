import 'dart:async';
import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/open_food_facts_service.dart';
import '../widgets/loading_widget.dart';
import '../utils/connectivity_helper.dart';
import '../utils/snackbar_helper.dart';
import 'scanner_screen.dart';

class AddEditFoodScreen extends StatefulWidget {
  final Food? food;

  const AddEditFoodScreen({super.key, this.food});

  @override
  State<AddEditFoodScreen> createState() => _AddEditFoodScreenState();
}

class _AddEditFoodScreenState extends State<AddEditFoodScreen> {
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

  Future<void> _scanBarcode() async {
    if (!await hasInternetConnection()) {
      if (mounted) {
        showErrorSnackbar(
          context,
          'No internet connection. Please check your connection and try again.',
        );
      }
      return;
    }

    if (!mounted) return;

    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );

    if (!mounted) return;

    if (barcode != null) {
      _barcodeController.text = barcode;
      _fetchProductFromBarcode(barcode);
    }
  }

  Future<void> _fetchProductFromBarcode(String barcode) async {
    setState(() => _isLoading = true);
    try {
      final product = await _apiService.searchByBarcode(barcode);
      if (product != null && mounted) {
        setState(() {
          _nameController.text = product.name;
        });
      } else if (mounted) {
        showErrorSnackbar(context, 'Product not found');
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

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _expiryDate = date);
    }
  }

  void _saveFoodItem() {
    if (_nameController.text.isEmpty) {
      showErrorSnackbar(context, 'Food name is required');
      return;
    }

    if (int.tryParse(_quantityController.text) == null ||
        int.parse(_quantityController.text) <= 0) {
      showErrorSnackbar(context, 'Quantity must be a positive number');
      return;
    }

    final food = Food(
      id: widget.food?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      quantity: int.parse(_quantityController.text),
      unit: _selectedUnit,
      barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
      expiryDate: _expiryDate,
      addedDate: widget.food?.addedDate ?? DateTime.now(),
    );

    Navigator.pop(context, food);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.food == null ? 'Add Food' : 'Edit Food'),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Basic Information'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Food Name *',
                      hintText: 'Enter food name',
                      prefixIcon: const Icon(Icons.restaurant_menu),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity *',
                            prefixIcon: const Icon(Icons.scale),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            prefixIcon: const Icon(Icons.straighten),
                          ),
                          items: ['pcs', 'kg', 'g', 'l', 'ml']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedUnit = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Additional Details'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _barcodeController,
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
                        color: Color(0xFFFF9800),
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
        color: const Color(0xFFFF9800),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
