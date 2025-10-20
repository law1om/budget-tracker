/// API Configuration
class ApiConfig {
  // Измените этот URL на адрес вашего сервера
  // Для Android эмулятора: 'http://10.0.2.2:8080'
  // Для iOS симулятора: 'http://localhost:8080'
  // Для реального устройства: 'http://YOUR_IP:8080'
  static const String baseUrl = 'http://localhost:8080';
  
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
