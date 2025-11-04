import 'package:flutter/material.dart';
import '../theme/theme.dart';

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.snackbarError,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void showDeleteSnackbar(
  BuildContext context,
  String itemName,
  VoidCallback onUndo,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$itemName deleted'),
      backgroundColor: Theme.of(context).colorScheme.snackbarInfo,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      action: SnackBarAction(
        label: 'UNDO',
        textColor: AppColors.accentOrange,
        onPressed: onUndo,
      ),
    ),
  );
}
