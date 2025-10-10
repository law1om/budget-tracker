 import 'package:flutter/material.dart';
 import 'package:intl/intl.dart';
 import '../models/transaction_model.dart';
 import '../models/category_model.dart';

 class TransactionTile extends StatelessWidget {
   final TransactionModel tx;
   final CategoryModel category;
   final String currencySymbol;
   final VoidCallback? onDelete;

   const TransactionTile({
     super.key,
     required this.tx,
     required this.category,
     required this.currencySymbol,
     this.onDelete,
   });

   @override
   Widget build(BuildContext context) {
     final isIncome = tx.type == TransactionType.income;
     final amountPrefix = isIncome ? '+' : '-';
     final amountColor = isIncome ? Colors.green : Colors.red;
     final dateStr = DateFormat('dd MMM, HH:mm').format(tx.date);

     return ListTile(
       leading: CircleAvatar(
         backgroundColor: category.color.withOpacity(0.2),
         child: Icon(category.icon, color: category.color),
       ),
       title: Text(tx.title, maxLines: 1, overflow: TextOverflow.ellipsis),
       subtitle: Text('${category.name} • $dateStr'),
       trailing: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.end,
         children: [
           Text(
             '$amountPrefix $currencySymbol ${tx.amount.toStringAsFixed(2)}',
             style: TextStyle(color: amountColor, fontWeight: FontWeight.w600),
           ),
         ],
       ),
       onLongPress: onDelete,
     );
   }
 }

