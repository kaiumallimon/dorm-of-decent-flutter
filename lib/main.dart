import 'package:dorm_of_decents/configs/router.dart';
import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/data/services/client/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize ApiClient and load tokens from storage
  final apiClient = ApiClient();
  await apiClient.loadTokensFromStorage();

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Dorm of Decents",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
