 import 'package:shared_preferences/shared_preferences.dart';

 class LocalStorageService {
   static final LocalStorageService _instance = LocalStorageService._internal();
   factory LocalStorageService() => _instance;
   LocalStorageService._internal();

   SharedPreferences? _prefs;

  static const _kOnboardingSeen = 'onboarding_seen';
  static const _kIsLoggedIn = 'is_logged_in';
  static const _kUsername = 'username';
  static const _kToken = 'jwt_token';
  static const _kUserId = 'user_id';
  static const _kUserEmail = 'user_email';
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

  // JWT Token
  Future<void> setToken(String token) async {
    await _prefs!.setString(_kToken, token);
  }

  String? get token => _prefs!.getString(_kToken);

  Future<void> clearToken() async {
    await _prefs!.remove(_kToken);
  }

  // User ID
  Future<void> setUserId(int id) async {
    await _prefs!.setInt(_kUserId, id);
  }

  int? get userId => _prefs!.getInt(_kUserId);

  // User Email
  Future<void> setUserEmail(String email) async {
    await _prefs!.setString(_kUserEmail, email);
  }

  String? get userEmail => _prefs!.getString(_kUserEmail);

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

