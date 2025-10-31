import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> hasInternetConnection() async {
  final connectivity = Connectivity();
  final connectivityResult = await connectivity.checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}
