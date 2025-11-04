import 'package:flutter/material.dart';
import '../theme/theme.dart';

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
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
      backgroundColor: Colors.white,
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
