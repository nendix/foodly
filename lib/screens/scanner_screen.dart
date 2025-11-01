import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/scanner_notifier.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScannerNotifier(),
      child: const _ScannerScreenContent(),
    );
  }
}

class _ScannerScreenContent extends StatelessWidget {
  const _ScannerScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<ScannerNotifier>(
      builder: (context, notifier, _) {
        return Stack(
          children: [
            MobileScanner(
              controller: notifier.scannerController,
              onDetect: (capture) {
                notifier.handleDetection(capture);
                if (notifier.isScannerInitialized &&
                    notifier.lastScannedBarcode != null) {
                  Navigator.pop(context, notifier.lastScannedBarcode);
                }
              },
              errorBuilder: (context, error, child) {
                return Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.errorContainer,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 32,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xl),
                        Text(
                          'Camera Error',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          error.errorCode.toString(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                );
              },

              placeholderBuilder: (context, child) {
                return Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: AppSpacing.lg),
                        Text(
                          'Initializing camera...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
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
                    Text(
                      'Scan Barcode',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ValueListenableBuilder<TorchState>(
                      valueListenable: notifier.scannerController.torchState,
                      builder: (context, torchState, _) {
                        return IconButton(
                          icon: Icon(
                            color: Colors.white,
                            torchState == TorchState.on
                                ? Icons.flash_on
                                : Icons.flash_off,
                          ),
                          onPressed: () =>
                              notifier.scannerController.toggleTorch(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: AppSpacing.paddingXl,
                  child: Center(
                    child: Text(
                      'Point camera at barcode',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
