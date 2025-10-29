import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/auth_response.dart';

class AuthProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final ApiService _apiService = ApiService();

  bool _initialized = false;
  bool _onboardingSeen = false;
  bool _isLoggedIn = false;
  UserModel? _user;
  String _errorMessage = '';

  // Getters
  bool get initialized => _initialized;
  bool get onboardingSeen => _onboardingSeen;
  bool get isLoggedIn => _isLoggedIn;
  UserModel? get user => _user;
  String get username => _user?.name ?? '';
  String get userEmail => _user?.email ?? '';
  String get currencyCode => _user?.currency ?? 'KZT';
  String get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await _storage.init();
    _onboardingSeen = _storage.onboardingSeen;
    _isLoggedIn = _storage.isLoggedIn;
    
    // Restore token if exists
    final token = _storage.token;
    if (token != null && token.isNotEmpty) {
      _apiService.setToken(token);
      try {
        _user = await _apiService.getCurrentUser();
        _isLoggedIn = true;
      } catch (e) {
        // Token expired or invalid, clear it
        await logout();
      }
    }
    
    _initialized = true;
    notifyListeners();
  }

  Future<void> setOnboardingSeen() async {
    _onboardingSeen = true;
    await _storage.setOnboardingSeen(true);
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    if (_user == null) return;
    
    try {
      final oldCurrency = _user!.currency;
      final currentBalance = _user!.balance;
      
      // Convert balance to new currency if changing currency
      double newBalance = currentBalance;
      if (oldCurrency != code) {
        if (currentBalance != 0) {
          newBalance = await _apiService.convertCurrency(
            amount: currentBalance,
            from: oldCurrency,
            to: code,
          );
        }
      }
      
      // Update user with new currency and converted balance
      _user = await _apiService.updateUser(
        currency: code,
        balance: newBalance,
      );
      await _storage.setCurrencyCode(code);
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final AuthResponse response = await _apiService.register(
        name: name,
        email: email,
        password: password,
      );
      
      _user = response.user;
      _isLoggedIn = true;
      
      // Save to local storage
      await _storage.setToken(response.token);
      await _storage.setUsername(response.user.name);
      await _storage.setUserEmail(response.user.email);
      await _storage.setUserId(response.user.id);
      await _storage.setCurrencyCode(response.user.currency);
      await _storage.setLoggedIn(true);
      
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final AuthResponse response = await _apiService.login(
        email: email,
        password: password,
      );
      
      _user = response.user;
      _isLoggedIn = true;
      
      // Save to local storage
      await _storage.setToken(response.token);
      await _storage.setUsername(response.user.name);
      await _storage.setUserEmail(response.user.email);
      await _storage.setUserId(response.user.id);
      await _storage.setCurrencyCode(response.user.currency);
      await _storage.setLoggedIn(true);
      
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    // Clear user-specific transaction data if user exists
    if (_user != null) {
      await _storage.clearUserData(_user!.id);
    }
    
    _isLoggedIn = false;
    _user = null;
    _apiService.clearToken();
    
    await _storage.setLoggedIn(false);
    await _storage.clearToken();
    await _storage.setUsername('');
    await _storage.setUserEmail('');
    
    notifyListeners();
  }

  Future<void> updateProfile({String? name, double? balance}) async {
    if (_user == null) return;
    
    try {
      _user = await _apiService.updateUser(
        name: name,
        balance: balance,
      );
      
      if (name != null) {
        await _storage.setUsername(name);
      }
      
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    if (!_isLoggedIn) return;
    
    try {
      _user = await _apiService.getCurrentUser();
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}

