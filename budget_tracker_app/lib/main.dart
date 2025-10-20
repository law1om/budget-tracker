import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/currency_screen.dart';

void main() {
  runApp(const BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  const BudgetTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'Личный финансовый помощник',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
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
    final auth = context.read<AuthProvider>();
    final txProvider = context.read<TransactionProvider>();
    
    await auth.initialize();
    await txProvider.initialize();
    
    // Sync user balance to transaction provider
    if (auth.user != null) {
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
