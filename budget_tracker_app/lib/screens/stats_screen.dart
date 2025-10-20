 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import 'package:fl_chart/fl_chart.dart';
 import '../providers/transaction_provider.dart';
 import '../providers/auth_provider.dart';
 import '../models/category_model.dart';
 import '../utils/formatters.dart';

 class StatsScreen extends StatelessWidget {
   const StatsScreen({super.key});

   @override
   Widget build(BuildContext context) {
     final txProv = context.watch<TransactionProvider>();
     final auth = context.watch<AuthProvider>();
     final data = txProv.expenseByCategory();
     final symbol = currencySymbol(auth.currencyCode);

     return Scaffold(
       appBar: AppBar(title: const Text('Статистика расходов')),
       body: Padding(
         padding: const EdgeInsets.all(16.0),
         child: data.isEmpty
             ? const Center(child: Text('Нет данных для графика'))
             : Column(
                 children: [
                   Expanded(
                     child: PieChart(
                       PieChartData(
                         sectionsSpace: 2,
                         centerSpaceRadius: 48,
                         sections: _buildSections(data),
                       ),
                     ),
                   ),
                   const SizedBox(height: 16),
                   Wrap(
                     spacing: 8,
                     runSpacing: 8,
                     children: [
                       for (final entry in data.entries)
                         _LegendItem(category: entry.key, value: entry.value, symbol: symbol),
                     ],
                   ),
                 ],
               ),
       ),
     );
   }

   List<PieChartSectionData> _buildSections(Map<CategoryModel, double> data) {
     final total = data.values.fold<double>(0.0, (p, v) => p + v);
     return data.entries.map((e) {
       final percent = total == 0 ? 0 : (e.value / total) * 100;
       return PieChartSectionData(
         color: e.key.color,
         value: e.value,
         title: '${percent.toStringAsFixed(0)}%',
         titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
         radius: 80,
       );
     }).toList();
   }
 }

 class _LegendItem extends StatelessWidget {
   final CategoryModel category;
   final double value;
   final String symbol;

   const _LegendItem({required this.category, required this.value, required this.symbol});

   @override
   Widget build(BuildContext context) {
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
       decoration: BoxDecoration(
         color: Theme.of(context).colorScheme.surfaceContainerHighest,
         borderRadius: BorderRadius.circular(12),
       ),
       child: Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           Container(width: 10, height: 10, decoration: BoxDecoration(color: category.color, shape: BoxShape.circle)),
           const SizedBox(width: 8),
           Text('${category.name}: $symbol ${value.toStringAsFixed(2)}'),
         ],
       ),
     );
   }
 }

