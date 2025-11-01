import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerNotifier extends ChangeNotifier {
  late MobileScannerController controller;
  bool _isScannerInitialized = false;
  String? _lastScannedBarcode;

  bool get isScannerInitialized => _isScannerInitialized;
  String? get lastScannedBarcode => _lastScannedBarcode;
  MobileScannerController get scannerController => controller;

  ScannerNotifier() {
    controller = MobileScannerController();
  }

  void handleDetection(BarcodeCapture capture) {
    if (!_isScannerInitialized) {
      _isScannerInitialized = true;
      final List<Barcode> barcodes = capture.barcodes;
      if (barcodes.isNotEmpty) {
        final String barcode = barcodes.first.rawValue ?? '';
        if (barcode.isNotEmpty) {
          _lastScannedBarcode = barcode;
          notifyListeners();
        }
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
