 import 'package:flutter/foundation.dart';
 import 'package:dio/dio.dart';
 import '../services/local_storage_service.dart';

 class AuthProvider with ChangeNotifier {
   final LocalStorageService _storage = LocalStorageService();
   final Dio _dio = Dio(); // used to simulate network delay

   bool _initialized = false;
   bool _onboardingSeen = false;
   bool _isLoggedIn = false;
   String _username = '';
   String _currencyCode = 'KZT';

   bool get initialized => _initialized;
   bool get onboardingSeen => _onboardingSeen;
   bool get isLoggedIn => _isLoggedIn;
   String get username => _username;
   String get currencyCode => _currencyCode;

   Future<void> initialize() async {
     await _storage.init();
     _onboardingSeen = _storage.onboardingSeen;
     _isLoggedIn = _storage.isLoggedIn;
     _username = _storage.username;
     _currencyCode = _storage.currencyCode;
     _initialized = true;
     notifyListeners();
   }

   Future<void> setOnboardingSeen() async {
     _onboardingSeen = true;
     await _storage.setOnboardingSeen(true);
     notifyListeners();
   }

   Future<void> setCurrency(String code) async {
     _currencyCode = code;
     await _storage.setCurrencyCode(code);
     notifyListeners();
   }

   Future<void> register(String username, String password) async {
     // Fake network delay using Dio; ignore failures
     try {
       await _dio.get('https://example.com');
     } catch (_) {}
     _username = username;
     _isLoggedIn = true;
     await _storage.setUsername(username);
     await _storage.setLoggedIn(true);
     notifyListeners();
   }

   Future<void> login(String username, String password) async {
     // Fake auth: accept any non-empty username/password
     await Future.delayed(const Duration(milliseconds: 500));
     _username = username;
     _isLoggedIn = true;
     await _storage.setUsername(username);
     await _storage.setLoggedIn(true);
     notifyListeners();
   }

   Future<void> logout() async {
     _isLoggedIn = false;
     _username = '';
     await _storage.setLoggedIn(false);
     await _storage.setUsername('');
     notifyListeners();
   }
 }

