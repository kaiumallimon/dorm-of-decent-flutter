import 'package:dorm_of_decents/configs/router.dart';
import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';
import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/logic/expense_cubit.dart';
import 'package:dorm_of_decents/logic/login_cubit.dart';
import 'package:dorm_of_decents/logic/meal_cubit.dart';
import 'package:dorm_of_decents/logic/splash_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await SupabaseService.initialize();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Create AuthCubit instance once
    _authCubit = AuthCubit();
    _router = createRouter(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider(create: (_) => SplashCubit()..startSplash()),
        BlocProvider(create: (_) => LoginCubit()),
        BlocProvider(create: (_) => MealCubit()),
        BlocProvider(create: (_) => ExpenseCubit()),
      ],
      child: MaterialApp.router(
        title: "Dorm of Decents",
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
