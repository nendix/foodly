import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> hasInternetConnection() async {
  final connectivity = Connectivity();
  final connectivityResult = await connectivity.checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

void showNoConnectionSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('No internet connection. Please check your connection and try again.'),
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
