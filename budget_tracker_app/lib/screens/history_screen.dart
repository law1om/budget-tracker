 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/transaction_tile.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../utils/formatters.dart';
import 'add_transaction_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProv = context.watch<TransactionProvider>();
    final auth = context.watch<AuthProvider>();
    final symbol = currencySymbol(auth.currencyCode);

    return Scaffold(
      appBar: AppBar(title: const Text('История операций')),
      body: ListView.separated(
        itemCount: txProv.transactions.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final tx = txProv.transactions[index];
          final category = _resolveCategory(tx);
          return Dismissible(
            key: ValueKey(tx.id),
            background: Container(color: Colors.redAccent),
            onDismissed: (_) => context.read<TransactionProvider>().remove(tx.id),
            child: TransactionTile(
              tx: tx,
              category: category,
              currencySymbol: symbol,
              onLongPress: () => _onTxLongPress(context, tx),
            ),
          );
        },
      ),
    );
  }

  CategoryModel _resolveCategory(TransactionModel tx) {
    final list = tx.type == TransactionType.expense ? DefaultCategories.expenses : DefaultCategories.incomes;
    return list.firstWhere((c) => c.id == tx.categoryId, orElse: () => list.first);
  }

  Future<void> _onTxLongPress(BuildContext context, TransactionModel tx) async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop('edit'),
            child: const Text('Изменить'),
          ),
          const Divider(height: 0),
          SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop('delete'),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (action == 'edit') {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AddTransactionScreen(initialTx: tx),
      ));
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Удалить операцию?'),
          content: const Text('Действие необратимо.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Отмена')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Удалить')),
          ],
        ),
      );
      if (confirmed == true) {
        context.read<TransactionProvider>().remove(tx.id);
      }
    }
  }
}
