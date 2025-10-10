 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import '../providers/auth_provider.dart';
 import '../providers/transaction_provider.dart';
 import '../widgets/balance_card.dart';
 import '../widgets/transaction_tile.dart';
 import '../models/category_model.dart';
 import '../utils/formatters.dart';
 import '../models/transaction_model.dart';

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
                   color: Theme.of(context).colorScheme.surfaceVariant,
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
                 )
             ],
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
 }

