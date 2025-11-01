import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../widgets/loading_widget.dart';
import '../theme/theme.dart';
import '../services/connectivity_service.dart';
import '../widgets/snackbar_helper.dart';
import '../providers/food_form_notifier.dart';
import 'scanner_screen.dart';

class FoodScreen extends StatefulWidget {
  final Food? food;

  const FoodScreen({super.key, this.food});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  late FoodFormNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = FoodFormNotifier(initialFood: widget.food);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
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
      _notifier.barcodeController.text = result;
      await _notifier.fetchFoodFromBarcode(result);
    }
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _notifier.expiryDate ?? DateTime(now.year, now.month + 1, now.day),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) {
      _notifier.setExpiryDate(picked);
    }
  }

  void _saveFoodItem() {
    final food = _notifier.buildFood();
    if (food == null) {
      if (_notifier.error != null) {
        showErrorSnackbar(context, _notifier.error!);
      }
      return;
    }
    Navigator.pop(context, food);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Consumer<FoodFormNotifier>(
        builder: (context, notifier, _) {
          if (notifier.isLoading) {
            return const LoadingWidget(message: 'Fetching food information...');
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.food == null ? 'Add Food' : 'Edit Food'),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Food Name'),
                  SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: notifier.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Food name',
                      hintText: 'Enter food name',
                      prefixIcon: Icon(Icons.fastfood),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle(context, 'Quantity & Unit'),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: notifier.quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            hintText: '1',
                            prefixIcon: Icon(Icons.scale),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      DropdownMenu(
                        initialSelection: notifier.selectedUnit,
                        onSelected: (value) {
                          notifier.setUnit(value ?? 'g');
                        },
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(value: 'g', label: 'g'),
                          DropdownMenuEntry(value: 'kg', label: 'kg'),
                          DropdownMenuEntry(value: 'ml', label: 'ml'),
                          DropdownMenuEntry(value: 'L', label: 'L'),
                          DropdownMenuEntry(value: 'pcs', label: 'pcs'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle(context, 'Barcode'),
                  SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: notifier.barcodeController,
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
                  SizedBox(height: AppSpacing.lg),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.calendar_today,
                        color: AppColors.accentOrange,
                      ),
                      title: Text(
                        notifier.expiryDate == null
                            ? 'Set Expiry Date (Optional)'
                            : 'Expires: ${notifier.expiryDate!.toLocal().toString().split(' ')[0]}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _selectExpiryDate,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),
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
        },
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
