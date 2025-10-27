 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/formatters.dart';
import '../services/api_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? initialTx;
  final TransactionType? initialType;
  final String? initialCategoryId;
  const AddTransactionScreen({super.key, this.initialTx, this.initialType, this.initialCategoryId});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String _categoryId = DefaultCategories.expenses.first.id;
  String? _editingId;
  DateTime? _editingDate;
  bool _categoryLocked = false;
  String _txCurrency = 'KZT';
  bool _txCurrencyInit = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTx != null) {
      _editingId = widget.initialTx!.id;
      _titleCtrl.text = widget.initialTx!.title;
      _amountCtrl.text = widget.initialTx!.amount.toString();
      _editingDate = widget.initialTx!.date;
      _categoryId = widget.initialTx!.categoryId;
      _type = widget.initialTx!.type;
    } else if (widget.initialCategoryId != null) {
      // Opened from expenses carousel with a concrete category
      _type = widget.initialType ?? TransactionType.expense;
      _categoryId = widget.initialCategoryId!;
      _categoryLocked = true;
    } else if (widget.initialType != null) {
      _type = widget.initialType!;
      _categoryId = (widget.initialType == TransactionType.expense
              ? DefaultCategories.expenses
              : DefaultCategories.incomes)
          .first
          .id;
    }
    // Initialize transaction currency from user's current currency after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_txCurrencyInit) {
        final auth = context.read<AuthProvider>();
        setState(() {
          _txCurrency = auth.currencyCode;
          _txCurrencyInit = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final symbol = currencySymbol(_txCurrency);

    final categories = _type == TransactionType.expense
        ? DefaultCategories.expenses
        : DefaultCategories.incomes;

    return Scaffold(
      appBar: AppBar(title: Text(_editingId == null ? 'Добавить операцию' : 'Редактировать операцию')),
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
                onPressed: _categoryLocked
                    ? null
                    : (i) {
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Название (необязательно)', style: Theme.of(context).textTheme.labelLarge),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(labelText: 'Название'),
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
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Валюта', style: Theme.of(context).textTheme.labelLarge),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final code in const ['KZT', 'USD', 'EUR'])
                          ChoiceChip(
                            label: Text(code),
                            selected: _txCurrency == code,
                            onSelected: (sel) => setState(() => _txCurrency = code),
                          ),
                      ],
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
                            onSelected: _categoryLocked ? null : (_) => setState(() => _categoryId = c.id),
                            avatar: Icon(c.icon, size: 18),
                          )
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.check),
                        label: Text(_editingId == null ? 'Сохранить' : 'Обновить'),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final api = ApiService();
                          final userCurrency = auth.currencyCode;
                          final enteredAmount = double.parse(_amountCtrl.text);
                          double amountInBase = enteredAmount;
                          if (_txCurrency != userCurrency) {
                            try {
                              amountInBase = await api.convertCurrency(
                                amount: enteredAmount,
                                from: _txCurrency,
                                to: userCurrency,
                              );
                            } catch (_) {
                              // Fallback: keep original amount if conversion fails
                              amountInBase = enteredAmount;
                            }
                          }

                          if (_editingId == null) {
                            final tx = TransactionModel(
                              title: _titleCtrl.text.trim(),
                              amount: amountInBase,
                              date: DateTime.now(),
                              categoryId: _categoryId,
                              type: _type,
                            );
                            await context.read<TransactionProvider>().add(tx);
                          } else {
                            final tx = TransactionModel(
                              id: _editingId,
                              title: _titleCtrl.text.trim(),
                              amount: amountInBase,
                              date: _editingDate ?? DateTime.now(),
                              categoryId: _categoryId,
                              type: _type,
                            );
                            await context.read<TransactionProvider>().update(tx);
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
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