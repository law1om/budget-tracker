import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/currency_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  const BudgetTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = context.watch<ThemeProvider>();
          
          return MaterialApp(
            title: 'Личный финансовый помощник',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (_) => const _Root(),
              '/onboarding': (_) => const OnboardingScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/home': (_) => const HomeScreen(),
              '/add': (_) => const AddTransactionScreen(),
              '/history': (_) => const HistoryScreen(),
              '/stats': (_) => const StatsScreen(),
              '/currency': (_) => const CurrencyScreen(),
              '/settings': (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _initStarted = false;

  Future<void> _init(BuildContext context) async {
    if (_initStarted) return;
    _initStarted = true;
    final theme = context.read<ThemeProvider>();
    final auth = context.read<AuthProvider>();
    final txProvider = context.read<TransactionProvider>();
    
    // Initialize theme and auth in parallel
    await Future.wait([
      theme.initialize(),
      auth.initialize(),
    ]);
    
    // Initialize transaction provider with userId if logged in
    if (auth.user != null) {
      await txProvider.initialize(auth.user!.id);
      txProvider.setInitialBalance(auth.user!.balance);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _init(context);

    if (!auth.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.onboardingSeen) {
      return const OnboardingScreen();
    }
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }
    return const HomeScreen();
  }
}
