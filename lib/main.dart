import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/storage_service.dart';
import 'theme/theme.dart';
import 'screens/inventory_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await StorageService().init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'foodly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      themeMode: ThemeMode.dark,
      home: const InventoryScreen(),
    );
  }
}
