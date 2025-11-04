 import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';

class TransactionProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final ApiService _apiService = ApiService();

  List<TransactionModel> _transactions = [];
  double _initialBalance = 0.0;
  int? _userId;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  Future<void> initialize(int userId) async {
    await _storage.init();
    _userId = userId;
    
    // Try to load from server first
    try {
      debugPrint('📡 Loading transactions from server...');
      _transactions = await _apiService.getTransactions();
      debugPrint('✅ Loaded ${_transactions.length} transactions from server');
      
      // Save to local storage as backup
      await _persist();
    } catch (e) {
      debugPrint('⚠️ Failed to load from server, using local storage: $e');
      // Fallback to local storage
      final json = _storage.getTransactionsJson(userId);
      _transactions = TransactionModel.decodeList(json);
    }
    
    debugPrint('📊 TransactionProvider initialized for user $userId with ${_transactions.length} transactions');
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_userId == null) {
      debugPrint('⚠️ Cannot persist transactions: userId is null');
      return;
    }
    await _storage.saveTransactionsJson(TransactionModel.encodeList(_transactions), _userId!);
  }

  /// Sync calculated balance to server
  Future<void> _syncBalanceToServer() async {
    try {
      debugPrint('🔄 Syncing balance to server: $balance');
      final result = await _apiService.updateUser(balance: balance);
      debugPrint('✅ Balance synced successfully. Server returned: ${result.balance}');
    } catch (e) {
      debugPrint('❌ Failed to sync balance to server: $e');
      rethrow; // Re-throw to see the error in UI
    }
  }

  Future<void> add(TransactionModel tx) async {
    try {
      // Create on server
      final created = await _apiService.createTransaction(tx);
      _transactions.insert(0, created);
      debugPrint('✅ Transaction created on server with ID: ${created.id}');
    } catch (e) {
      debugPrint('⚠️ Failed to create on server, saving locally: $e');
      _transactions.insert(0, tx);
    }
    
    await _persist();
    await _syncBalanceToServer();
    notifyListeners();
  }

  Future<void> update(TransactionModel tx) async {
    final index = _transactions.indexWhere((e) => e.id == tx.id);
    if (index == -1) return;
    
    try {
      // Update on server if it has an ID
      if (tx.id != null) {
        final updated = await _apiService.updateTransaction(tx.id!, tx);
        _transactions[index] = updated;
        debugPrint('✅ Transaction updated on server');
      } else {
        _transactions[index] = tx;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to update on server, saving locally: $e');
      _transactions[index] = tx;
    }
    
    await _persist();
    await _syncBalanceToServer();
    notifyListeners();
  }

  Future<void> remove(int? id) async {
    if (id == null) return;
    
    try {
      // Delete on server
      await _apiService.deleteTransaction(id);
      debugPrint('✅ Transaction deleted on server');
    } catch (e) {
      debugPrint('⚠️ Failed to delete on server: $e');
    }
    
    _transactions.removeWhere((e) => e.id == id);
    await _persist();
    await _syncBalanceToServer();
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

  /// Clear all data when switching accounts
  void clear() {
    _transactions = [];
    _initialBalance = 0.0;
    _userId = null;
    debugPrint('🧹 TransactionProvider cleared');
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
