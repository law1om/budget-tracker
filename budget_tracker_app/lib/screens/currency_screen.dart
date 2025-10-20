 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import '../providers/auth_provider.dart';
 import '../providers/transaction_provider.dart';
 import '../services/api_service.dart';

 class CurrencyScreen extends StatefulWidget {
   const CurrencyScreen({super.key});

   @override
   State<CurrencyScreen> createState() => _CurrencyScreenState();
 }

 class _CurrencyScreenState extends State<CurrencyScreen> {
   bool _isLoading = false;

   @override
   Widget build(BuildContext context) {
     final auth = context.watch<AuthProvider>();
     final currencies = const ['KZT', 'USD', 'EUR'];

     return Scaffold(
       appBar: AppBar(title: const Text('Выбор валюты')),
       body: _isLoading
           ? const Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   CircularProgressIndicator(),
                   SizedBox(height: 16),
                   Text('Конвертация баланса...'),
                 ],
               ),
             )
           : ListView.builder(
               itemCount: currencies.length,
               itemBuilder: (_, i) {
                 final code = currencies[i];
                 return RadioListTile<String>(
                   title: Text(code),
                   value: code,
                   groupValue: auth.currencyCode,
                   onChanged: (v) async {
                     if (v == null || v == auth.currencyCode) return;
                     
                     setState(() => _isLoading = true);
                     try {
                       final authProvider = context.read<AuthProvider>();
                       final txProvider = context.read<TransactionProvider>();
                       final oldCurrency = authProvider.currencyCode;
                       
                       // Get conversion rate from API (1 old currency = X new currency)
                       double conversionRate = 1.0;
                       if (oldCurrency != v) {
                         conversionRate = await ApiService().convertCurrency(
                           amount: 1.0,
                           from: oldCurrency,
                           to: v,
                         );
                       }
                       
                       // Convert all existing transactions
                       if (txProvider.transactions.isNotEmpty && conversionRate != 1.0) {
                         await txProvider.convertTransactions(conversionRate);
                       }
                       
                       // Update user currency and balance
                       await authProvider.setCurrency(v);
                       
                       if (mounted) {
                         // Update transaction provider with new converted balance
                         final newBalance = authProvider.user?.balance ?? 0.0;
                         txProvider.setInitialBalance(newBalance);
                         
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(
                             content: Text('Валюта успешно изменена'),
                             backgroundColor: Colors.green,
                           ),
                         );
                         Navigator.of(context).pop();
                       }
                     } catch (e) {
                       if (mounted) {
                         setState(() => _isLoading = false);
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text('Ошибка: ${e.toString()}'),
                             backgroundColor: Colors.red,
                           ),
                         );
                       }
                     }
                   },
                 );
               },
             ),
     );
   }
 }

