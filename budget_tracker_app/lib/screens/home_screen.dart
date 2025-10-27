 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import '../models/category_model.dart';
import '../utils/formatters.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final txProv = context.watch<TransactionProvider>();
    final symbol = currencySymbol(auth.currencyCode);

    return Scaffold(
      appBar: AppBar(
        title: Text('Привет, ${auth.username.isEmpty ? 'Гость' : auth.username}!'),
        actions: [
          IconButton(
            tooltip: 'Валюта',
            onPressed: () => Navigator.of(context).pushNamed('/currency'),
            icon: const Icon(Icons.currency_exchange),
          ),
          IconButton(
            tooltip: 'Выйти',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TransactionProvider>().initialize();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BalanceCard(
              currencySymbol: symbol,
              balance: txProv.balance,
              income: txProv.totalIncome,
              expense: txProv.totalExpense,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: DefaultCategories.expenses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final c = DefaultCategories.expenses[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(
                          initialType: TransactionType.expense,
                          initialCategoryId: c.id,
                        ),
                      ));
                    },
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: c.color.withOpacity(0.15),
                            child: Icon(c.icon, color: c.color),
                          ),
                          const SizedBox(height: 8),
                          Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Недавние операции', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/history'),
                  child: const Text('Все'),
                )
              ],
            ),
            const SizedBox(height: 8),
            if (txProv.transactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text('Нет операций. Добавьте первую!')),
              )
            else ...[
              for (final tx in txProv.transactions.take(10))
                TransactionTile(
                  tx: tx,
                  category: _resolveCategory(tx),
                  currencySymbol: symbol,
                  onLongPress: () => _onTxLongPress(context, tx),
                )
            ],
            const SizedBox(height: 16),
            _TipCard(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/stats'),
                    icon: const Icon(Icons.pie_chart_outline),
                    label: const Text('Статистика'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/history'),
                    icon: const Icon(Icons.history),
                    label: const Text('История'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
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
      if (confirmed == true && context.mounted) {
        await context.read<TransactionProvider>().remove(tx.id);
      }
    }
  }
}

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Поглядывай на статистику',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text('Изучай, куда уходят деньги. Иногда это сюрприз 💡'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
