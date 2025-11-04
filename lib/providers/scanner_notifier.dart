import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerNotifier extends ChangeNotifier {
  late MobileScannerController controller;
  String? _lastScannedBarcode;
  String? _error;

  String? get lastScannedBarcode => _lastScannedBarcode;
  String? get error => _error;
  MobileScannerController get scannerController => controller;

  ScannerNotifier() {
    try {
      controller = MobileScannerController();
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize scanner: $e';
      controller = MobileScannerController();
    }
  }

  void handleDetection(BarcodeCapture capture) {
    if (_lastScannedBarcode != null) return;

    try {
      final List<Barcode> barcodes = capture.barcodes;
      if (barcodes.isNotEmpty) {
        final String barcode = barcodes.first.rawValue ?? '';
        if (barcode.isNotEmpty) {
          _lastScannedBarcode = barcode;
          controller.stop();
          _error = null;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to process barcode: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
