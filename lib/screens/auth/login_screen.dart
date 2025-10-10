 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import '../../providers/auth_provider.dart';

 class LoginScreen extends StatefulWidget {
   const LoginScreen({super.key});

   @override
   State<LoginScreen> createState() => _LoginScreenState();
 }

 class _LoginScreenState extends State<LoginScreen> {
   final _formKey = GlobalKey<FormState>();
   final _usernameCtrl = TextEditingController();
   final _passwordCtrl = TextEditingController();
   bool _loading = false;

   @override
   void dispose() {
     _usernameCtrl.dispose();
     _passwordCtrl.dispose();
     super.dispose();
   }

   Future<void> _submit() async {
     if (!_formKey.currentState!.validate()) return;
     setState(() => _loading = true);
     await context.read<AuthProvider>().login(_usernameCtrl.text, _passwordCtrl.text);
     if (mounted) {
       Navigator.of(context).pushReplacementNamed('/home');
     }
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text('Вход')),
       body: SafeArea(
         child: Padding(
           padding: const EdgeInsets.all(24.0),
           child: Form(
             key: _formKey,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 TextFormField(
                   controller: _usernameCtrl,
                   decoration: const InputDecoration(labelText: 'Имя пользователя'),
                   validator: (v) => (v == null || v.isEmpty) ? 'Введите имя пользователя' : null,
                 ),
                 const SizedBox(height: 12),
                 TextFormField(
                   controller: _passwordCtrl,
                   decoration: const InputDecoration(labelText: 'Пароль'),
                   obscureText: true,
                   validator: (v) => (v == null || v.length < 3) ? 'Минимум 3 символа' : null,
                 ),
                 const SizedBox(height: 24),
                 FilledButton(
                   onPressed: _loading ? null : _submit,
                   child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Войти'),
                 ),
                 const SizedBox(height: 12),
                 TextButton(
                   onPressed: () => Navigator.of(context).pushReplacementNamed('/register'),
                   child: const Text('Нет аккаунта? Зарегистрироваться'),
                 )
               ],
             ),
           ),
         ),
       ),
     );
   }
 }

