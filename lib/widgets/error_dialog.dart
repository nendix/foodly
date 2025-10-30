import 'package:flutter/material.dart';
import '../services/api_service.dart';

void showErrorDialog(BuildContext context, dynamic error) {
  String message = 'An unexpected error occurred';

  if (error is ApiException) {
    message = error.message;
  } else if (error is Exception) {
    message = error.toString();
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}
