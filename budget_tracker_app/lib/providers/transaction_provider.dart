 import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../services/local_storage_service.dart';

class TransactionProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  List<TransactionModel> _transactions = [];
  double _initialBalance = 0.0;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  Future<void> initialize() async {
    await _storage.init();
    final json = _storage.transactionsJson;
    _transactions = TransactionModel.decodeList(json);
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.saveTransactionsJson(TransactionModel.encodeList(_transactions));
  }

  void add(TransactionModel tx) {
    _transactions.insert(0, tx);
    _persist();
    notifyListeners();
  }

  void update(TransactionModel tx) {
    final index = _transactions.indexWhere((e) => e.id == tx.id);
    if (index == -1) return;
    _transactions[index] = tx;
    _persist();
    notifyListeners();
  }

  void remove(String id) {
    _transactions.removeWhere((e) => e.id == id);
    _persist();
    notifyListeners();
  }

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (p, e) => p + e.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (p, e) => p + e.amount);

  double get balance => _initialBalance + totalIncome - totalExpense;

  /// Update initial balance (e.g., when currency changes)
  void setInitialBalance(double balance) {
    _initialBalance = balance;
    notifyListeners();
  }

  /// Convert all transactions from one currency to another
  Future<void> convertTransactions(double conversionRate) async {
    final converted = _transactions.map((tx) {
      return TransactionModel(
        id: tx.id,
        title: tx.title,
        amount: tx.amount * conversionRate,
        date: tx.date,
        categoryId: tx.categoryId,
        type: tx.type,
      );
    }).toList();
    
    _transactions = converted;
    await _persist();
    notifyListeners();
  }

  Map<CategoryModel, double> expenseByCategory() {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => t.type == TransactionType.expense)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    final result = <CategoryModel, double>{};
    for (final c in DefaultCategories.expenses) {
      if ((map[c.id] ?? 0) > 0) result[c] = map[c.id]!;
    }
    return result;
  }
}
