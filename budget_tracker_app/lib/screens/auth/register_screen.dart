 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import '../../providers/auth_provider.dart';
 import '../../providers/transaction_provider.dart';

 class RegisterScreen extends StatefulWidget {
   const RegisterScreen({super.key});

   @override
   State<RegisterScreen> createState() => _RegisterScreenState();
 }

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    
    try {
      final auth = context.read<AuthProvider>();
      await auth.register(
        _nameCtrl.text,
        _emailCtrl.text,
        _passwordCtrl.text,
      );
      
      // Initialize TransactionProvider for the new user
      if (mounted && auth.user != null) {
        final txProvider = context.read<TransactionProvider>();
        await txProvider.initialize(auth.user!.id);
        txProvider.setInitialBalance(auth.user!.balance);
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text('Регистрация')),
       body: SafeArea(
         child: Padding(
           padding: const EdgeInsets.all(24.0),
           child: Form(
             key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Имя'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Введите имя' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Введите email';
                    if (!v.contains('@')) return 'Некорректный email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6) ? 'Минимум 6 символов' : null,
                ),
                const SizedBox(height: 24),
                 FilledButton(
                   onPressed: _loading ? null : _submit,
                   child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Создать аккаунт'),
                 ),
                 const SizedBox(height: 12),
                 TextButton(
                   onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                   child: const Text('Уже есть аккаунт? Войти'),
                 )
               ],
             ),
           ),
         ),
       ),
     );
   }
 }

