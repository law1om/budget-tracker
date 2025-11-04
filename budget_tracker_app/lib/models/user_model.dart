/// User Model
class UserModel {
  final int id;
  final String name;
  final String email;
  final double balance;
  final String currency;
  final String themePreference;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
    required this.currency,
    this.themePreference = 'system',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      themePreference: json['themePreference'] ?? 'system',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'balance': balance,
      'currency': currency,
      'themePreference': themePreference,
    };
  }
}
