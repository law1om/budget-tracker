 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import '../models/transaction_model.dart';
 import '../models/category_model.dart';
 import '../providers/transaction_provider.dart';
 import '../providers/auth_provider.dart';
 import '../utils/formatters.dart';

 class AddTransactionScreen extends StatefulWidget {
   const AddTransactionScreen({super.key});

   @override
   State<AddTransactionScreen> createState() => _AddTransactionScreenState();
 }

 class _AddTransactionScreenState extends State<AddTransactionScreen> {
   final _formKey = GlobalKey<FormState>();
   final _titleCtrl = TextEditingController();
   final _amountCtrl = TextEditingController();
   TransactionType _type = TransactionType.expense;
   String _categoryId = DefaultCategories.expenses.first.id;

   @override
   void dispose() {
     _titleCtrl.dispose();
     _amountCtrl.dispose();
     super.dispose();
   }

   @override
   Widget build(BuildContext context) {
     final auth = context.watch<AuthProvider>();
     final symbol = currencySymbol(auth.currencyCode);

     final categories = _type == TransactionType.expense
         ? DefaultCategories.expenses
         : DefaultCategories.incomes;

     return Scaffold(
       appBar: AppBar(title: const Text('Добавить операцию')),
       body: SafeArea(
         child: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
             children: [
               ToggleButtons(
                 isSelected: [
                   _type == TransactionType.expense,
                   _type == TransactionType.income,
                 ],
                 onPressed: (i) {
                   setState(() {
                     _type = i == 0 ? TransactionType.expense : TransactionType.income;
                     _categoryId = (_type == TransactionType.expense
                             ? DefaultCategories.expenses
                             : DefaultCategories.incomes)
                         .first
                         .id;
                   });
                 },
                 borderRadius: BorderRadius.circular(10),
                 children: const [
                   Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Расход')),
                   Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Доход')),
                 ],
               ),
               const SizedBox(height: 16),
               Form(
                 key: _formKey,
                 child: Column(
                   children: [
                     TextFormField(
                       controller: _titleCtrl,
                       decoration: const InputDecoration(labelText: 'Название'),
                       validator: (v) => (v == null || v.isEmpty) ? 'Введите название' : null,
                     ),
                     const SizedBox(height: 12),
                     TextFormField(
                       controller: _amountCtrl,
                       keyboardType: const TextInputType.numberWithOptions(decimal: true),
                       decoration: InputDecoration(labelText: 'Сумма ($symbol)'),
                       validator: (v) {
                         final value = double.tryParse(v ?? '');
                         if (value == null || value <= 0) return 'Введите корректную сумму';
                         return null;
                       },
                     ),
                     const SizedBox(height: 12),
                     Align(
                       alignment: Alignment.centerLeft,
                       child: Text('Категория', style: Theme.of(context).textTheme.labelLarge),
                     ),
                     const SizedBox(height: 8),
                     Wrap(
                       spacing: 8,
                       runSpacing: 8,
                       children: [
                         for (final c in categories)
                           ChoiceChip(
                             label: Text(c.name),
                             selected: _categoryId == c.id,
                             onSelected: (_) => setState(() => _categoryId = c.id),
                             avatar: Icon(c.icon, size: 18),
                           )
                       ],
                     ),
                     const SizedBox(height: 24),
                     SizedBox(
                       width: double.infinity,
                       child: FilledButton.icon(
                         icon: const Icon(Icons.check),
                         label: const Text('Сохранить'),
                         onPressed: () {
                           if (!_formKey.currentState!.validate()) return;
                           final tx = TransactionModel(
                             title: _titleCtrl.text.trim(),
                             amount: double.parse(_amountCtrl.text),
                             date: DateTime.now(),
                             categoryId: _categoryId,
                             type: _type,
                           );
                           context.read<TransactionProvider>().add(tx);
                           Navigator.of(context).pop();
                         },
                       ),
                     )
                   ],
                 ),
               )
             ],
           ),
         ),
       ),
     );
   }
 }

