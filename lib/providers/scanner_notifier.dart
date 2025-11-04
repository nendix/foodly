import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerNotifier extends ChangeNotifier {
  late MobileScannerController controller;
  bool _isScannerInitialized = false;
  String? _lastScannedBarcode;
  String? _error;

  bool get isScannerInitialized => _isScannerInitialized;
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
    if (!_isScannerInitialized) {
      try {
        _isScannerInitialized = true;
        final List<Barcode> barcodes = capture.barcodes;
        if (barcodes.isNotEmpty) {
          final String barcode = barcodes.first.rawValue ?? '';
          if (barcode.isNotEmpty) {
            _lastScannedBarcode = barcode;
            _error = null;
            notifyListeners();
          }
        }
      } catch (e) {
        _error = 'Failed to process barcode: $e';
        notifyListeners();
      }
    }
  }

  void resetScanner() {
    _isScannerInitialized = false;
    _lastScannedBarcode = null;
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
