import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late MobileScannerController controller;
  bool _isScannerInitialized = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            if (!_isScannerInitialized) {
              _isScannerInitialized = true;
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String barcode = barcodes.first.rawValue ?? '';
                if (barcode.isNotEmpty) {
                  Navigator.pop(context, barcode);
                }
              }
            }
          },
          errorBuilder: (context, error, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Camera Error: ${error.errorCode}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('go back'),
                  ),
                ],
              ),
            );
          },
          placeholderBuilder: (context, child) {
            return const Center(child: CircularProgressIndicator());
          },
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                ValueListenableBuilder<TorchState>(
                  valueListenable: controller.torchState,
                  builder: (context, torchState, _) {
                    return IconButton(
                      icon: Icon(
                        color: Colors.white,
                        torchState == TorchState.on
                            ? Icons.flash_on
                            : Icons.flash_off,
                      ),
                      onPressed: () => controller.toggleTorch(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
