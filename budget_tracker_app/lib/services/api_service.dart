import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

/// Exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// API Service for backend communication
class ApiService {
  late final Dio _dio;
  String? _token;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptor for logging and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add JWT token to headers if available
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        return handler.next(_handleError(error));
      },
    ));
  }

  /// Set JWT token for authenticated requests
  void setToken(String? token) {
    _token = token;
  }

  /// Clear JWT token
  void clearToken() {
    _token = null;
  }

  /// Get current token
  String? get token => _token;

  /// Handle Dio errors
  DioException _handleError(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        message = _extractErrorMessage(error.response);
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      default:
        message = 'Network error. Please check your connection.';
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: ApiException(message, statusCode: statusCode),
    );
  }

  /// Extract error message from response
  String _extractErrorMessage(Response? response) {
    if (response == null) return 'Unknown error occurred';

    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] ?? data['error'] ?? 'Server error';
      }
      return 'Server error: ${response.statusCode}';
    } catch (_) {
      return 'Server error: ${response.statusCode}';
    }
  }

  /// Register new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);
      _token = authResponse.token;
      return authResponse;
    } on DioException catch (e) {
      throw e.error ?? ApiException('Registration failed');
    }
  }

  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);
      _token = authResponse.token;
      return authResponse;
    } on DioException catch (e) {
      throw e.error ?? ApiException('Login failed');
    }
  }

  /// Get current user data
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConfig.userMe);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error ?? ApiException('Failed to fetch user data');
    }
  }

  /// Update current user
  Future<UserModel> updateUser({
    String? name,
    double? balance,
    String? currency,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (balance != null) data['balance'] = balance;
      if (currency != null) data['currency'] = currency;

      print('📤 Sending update request to ${ApiConfig.userUpdate}');
      print('   Data: $data');
      print('   Token: ${_token != null ? "Present (${_token!.substring(0, 20)}...)" : "Missing!"}');

      final response = await _dio.put(
        ApiConfig.userUpdate,
        data: data,
      );

      print('📥 Received response: ${response.data}');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('   Response: ${e.response?.data}');
      throw e.error ?? ApiException('Failed to update user');
    }
  }

  /// Convert currency
  Future<double> convertCurrency({
    required double amount,
    required String from,
    required String to,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.currencyConvert,
        queryParameters: {
          'amount': amount,
          'from': from,
          'to': to,
        },
      );

      return (response.data['result'] ?? 0).toDouble();
    } on DioException catch (e) {
      throw e.error ?? ApiException('Currency conversion failed');
    }
  }
}
