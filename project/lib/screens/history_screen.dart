 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import '../providers/transaction_provider.dart';
 import '../providers/auth_provider.dart';
 import '../widgets/transaction_tile.dart';
 import '../models/transaction_model.dart';
 import '../models/category_model.dart';
 import '../utils/formatters.dart';

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
               onDelete: () => context.read<TransactionProvider>().remove(tx.id),
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
 }

