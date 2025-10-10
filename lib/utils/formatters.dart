import 'package:intl/intl.dart';

String currencySymbol(String code) {
  switch (code) {
    case 'USD':
      return '\$'; // $
    case 'EUR':
      return '€';
    case 'KZT':
    default:
      return '₸';
  }
}

String formatCurrency(double amount, String code) {
  final symbol = currencySymbol(code);
  return '$symbol ${amount.toStringAsFixed(2)}';
}

String formatDateShort(DateTime date) {
  return DateFormat('dd MMM, HH:mm').format(date);
}
