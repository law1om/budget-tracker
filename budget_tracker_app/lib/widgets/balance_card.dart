 import 'package:flutter/material.dart';

 class BalanceCard extends StatelessWidget {
   final String currencySymbol;
   final double balance;
   final double income;
   final double expense;

   const BalanceCard({
     super.key,
     required this.currencySymbol,
     required this.balance,
     required this.income,
     required this.expense,
   });

   @override
   Widget build(BuildContext context) {
     final colorScheme = Theme.of(context).colorScheme;
     return Container(
       decoration: BoxDecoration(
         gradient: LinearGradient(
           colors: [colorScheme.primary, colorScheme.primaryContainer],
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
         ),
         borderRadius: BorderRadius.circular(20),
       ),
       padding: const EdgeInsets.all(20),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text('Баланс', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary)),
           const SizedBox(height: 8),
           Text(
             '$currencySymbol ${balance.toStringAsFixed(2)}',
             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                   color: colorScheme.onPrimary,
                   fontWeight: FontWeight.bold,
                 ),
           ),
           const SizedBox(height: 12),
           Row(
             children: [
               Expanded(
                 child: _SummaryTile(
                   label: 'Заработано',
                   value: '+ $currencySymbol ${income.toStringAsFixed(2)}',
                   icon: Icons.arrow_downward,
                   color: Colors.greenAccent.shade100,
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: _SummaryTile(
                   label: 'Потрачено',
                   value: '- $currencySymbol ${expense.toStringAsFixed(2)}',
                   icon: Icons.arrow_upward,
                   color: Colors.redAccent.shade100,
                 ),
               ),
             ],
           )
         ],
       ),
     );
   }
 }

 class _SummaryTile extends StatelessWidget {
   final String label;
   final String value;
   final IconData icon;
   final Color color;

   const _SummaryTile({
     required this.label,
     required this.value,
     required this.icon,
     required this.color,
   });

   @override
   Widget build(BuildContext context) {
     final onPrimary = Theme.of(context).colorScheme.onPrimary;
     return Container(
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: Colors.white.withOpacity(0.15),
         borderRadius: BorderRadius.circular(14),
       ),
       child: Row(
         children: [
           Container(
             width: 36,
             height: 36,
             decoration: BoxDecoration(color: color.withOpacity(0.8), shape: BoxShape.circle),
             child: Icon(icon, color: Colors.black87, size: 20),
           ),
           const SizedBox(width: 10),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: onPrimary)),
                 Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: onPrimary, fontWeight: FontWeight.w600)),
               ],
             ),
           )
         ],
       ),
     );
   }
 }

