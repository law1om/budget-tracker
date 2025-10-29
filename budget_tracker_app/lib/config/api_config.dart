/// API Configuration
class ApiConfig {
  // Для iOS симулятора: 'http://localhost:8080'
  // Для реального устройства: 'http://YOUR_IP:8080'
  static const String baseUrl = 'http://192.168.0.102:8080';
  
  // Endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String userMe = '/api/users/me';
  static const String userUpdate = '/api/users/me';
  static const String currencyConvert = '/api/currency/convert';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
