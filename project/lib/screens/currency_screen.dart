 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import '../providers/auth_provider.dart';

 class CurrencyScreen extends StatelessWidget {
   const CurrencyScreen({super.key});

   @override
   Widget build(BuildContext context) {
     final auth = context.watch<AuthProvider>();
     final currencies = const ['KZT', 'USD', 'EUR'];

     return Scaffold(
       appBar: AppBar(title: const Text('Выбор валюты')),
       body: ListView.builder(
         itemCount: currencies.length,
         itemBuilder: (_, i) {
           final code = currencies[i];
           return RadioListTile<String>(
             title: Text(code),
             value: code,
             groupValue: auth.currencyCode,
             onChanged: (v) async {
               await context.read<AuthProvider>().setCurrency(v!);
               if (context.mounted) Navigator.of(context).pop();
             },
           );
         },
       ),
     );
   }
 }

