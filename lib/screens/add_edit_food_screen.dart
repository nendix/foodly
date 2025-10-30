import 'dart:async';
import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/open_food_facts_service.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_widget.dart';
import 'barcode_scanner_screen.dart';

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
    _quantityController = TextEditingController(text: widget.food?.quantity.toString() ?? '1');
    _barcodeController = TextEditingController(text: widget.food?.barcode ?? '');
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
    final barcode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );
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
        showSuccessSnackbar(context, 'Product found!');
      } else if (mounted) {
        showErrorDialog(context, Exception('Product not found'));
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchByName() async {
    if (_nameController.text.isEmpty) {
      showErrorDialog(context, Exception('Enter a product name'));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final products = await _apiService.searchByName(_nameController.text);
      if (mounted && products.isNotEmpty) {
        _showProductSelection(products);
      } else if (mounted) {
        showErrorDialog(context, Exception('No products found'));
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showProductSelection(products) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text(product.brand ?? 'Unknown brand'),
            onTap: () {
              _nameController.text = product.name;
              if (product.barcode != null) {
                _barcodeController.text = product.barcode!;
              }
              Navigator.pop(context);
              setState(() {});
            },
          );
        },
      ),
    );
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
      showErrorDialog(context, Exception('Food name is required'));
      return;
    }

    if (int.tryParse(_quantityController.text) == null || int.parse(_quantityController.text) <= 0) {
      showErrorDialog(context, Exception('Quantity must be a positive number'));
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
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Food Name *',
                      hintText: 'Enter food name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: ['pcs', 'kg', 'g', 'l', 'ml']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                   const SizedBox(height: 16),
                   TextField(
                     controller: _barcodeController,
                     decoration: InputDecoration(
                       labelText: 'Barcode',
                       hintText: 'Enter or scan barcode',
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(8),
                       ),
                       suffixIcon: IconButton(
                         icon: const Icon(Icons.qr_code_scanner),
                         onPressed: _scanBarcode,
                       ),
                     ),
                   ),
                   const SizedBox(height: 16),
                   ListTile(
                    title: Text(
                      _expiryDate == null
                          ? 'Set Expiry Date (Optional)'
                          : 'Expires: ${_expiryDate!.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectExpiryDate,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _searchByName,
                          child: const Text('Search Product'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveFoodItem,
                          child: Text(widget.food == null ? 'Add Food' : 'Update Food'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
