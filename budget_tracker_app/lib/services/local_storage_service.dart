 import 'package:shared_preferences/shared_preferences.dart';

 class LocalStorageService {
   static final LocalStorageService _instance = LocalStorageService._internal();
   factory LocalStorageService() => _instance;
   LocalStorageService._internal();

   SharedPreferences? _prefs;

   static const _kOnboardingSeen = 'onboarding_seen';
   static const _kIsLoggedIn = 'is_logged_in';
   static const _kUsername = 'username';
   static const _kCurrencyCode = 'currency_code'; // KZT/USD/EUR
   static const _kTransactions = 'transactions_json';

   Future<void> init() async {
     _prefs ??= await SharedPreferences.getInstance();
   }

   bool get isReady => _prefs != null;

   // Onboarding
   Future<void> setOnboardingSeen(bool value) async {
     await _prefs!.setBool(_kOnboardingSeen, value);
   }

   bool get onboardingSeen => _prefs!.getBool(_kOnboardingSeen) ?? false;

   // Auth
   Future<void> setLoggedIn(bool value) async {
     await _prefs!.setBool(_kIsLoggedIn, value);
   }

   bool get isLoggedIn => _prefs!.getBool(_kIsLoggedIn) ?? false;

   Future<void> setUsername(String username) async {
     await _prefs!.setString(_kUsername, username);
   }

   String get username => _prefs!.getString(_kUsername) ?? '';

   // Currency
   Future<void> setCurrencyCode(String code) async {
     await _prefs!.setString(_kCurrencyCode, code);
   }

   String get currencyCode => _prefs!.getString(_kCurrencyCode) ?? 'KZT';

   // Transactions
   Future<void> saveTransactionsJson(String json) async {
     await _prefs!.setString(_kTransactions, json);
   }

   String? get transactionsJson => _prefs!.getString(_kTransactions);
 }

