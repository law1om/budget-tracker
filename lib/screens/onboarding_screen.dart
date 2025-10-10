 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import '../providers/auth_provider.dart';

 class OnboardingScreen extends StatefulWidget {
   const OnboardingScreen({super.key});

   @override
   State<OnboardingScreen> createState() => _OnboardingScreenState();
 }

 class _OnboardingScreenState extends State<OnboardingScreen> {
   final PageController _controller = PageController();
   int _index = 0;

   final _pages = const [
     _OnbPage(
       title: 'Личный финансовый помощник',
       subtitle: 'Отслеживайте доходы и расходы, управляйте бюджетом и достигайте целей.',
       icon: Icons.account_balance_wallet_outlined,
     ),
     _OnbPage(
       title: 'Категории расходов',
       subtitle: 'Еда, транспорт, аренда, одежда и развлечения — всё под контролем.',
       icon: Icons.category_outlined,
     ),
     _OnbPage(
       title: 'Статистика и аналитика',
       subtitle: 'Смотрите графики и находите возможности для экономии.',
       icon: Icons.pie_chart_outline_rounded,
     ),
   ];

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       body: SafeArea(
         child: Padding(
           padding: const EdgeInsets.all(24.0),
           child: Column(
             children: [
               Expanded(
                 child: PageView(
                   controller: _controller,
                   onPageChanged: (i) => setState(() => _index = i),
                   children: _pages,
                 ),
               ),
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: List.generate(
                   _pages.length,
                   (i) => AnimatedContainer(
                     duration: const Duration(milliseconds: 300),
                     margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                     width: _index == i ? 20 : 8,
                     height: 8,
                     decoration: BoxDecoration(
                       color: _index == i ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                       borderRadius: BorderRadius.circular(12),
                     ),
                   ),
                 ),
               ),
               SizedBox(
                 width: double.infinity,
                 child: FilledButton(
                   onPressed: () async {
                     if (_index < _pages.length - 1) {
                       _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                       return;
                     }
                     await context.read<AuthProvider>().setOnboardingSeen();
                     if (context.mounted) {
                       Navigator.of(context).pushReplacementNamed('/login');
                     }
                   },
                   child: Text(_index == _pages.length - 1 ? 'Начать' : 'Далее'),
                 ),
               ),
             ],
           ),
         ),
       ),
     );
   }
 }

 class _OnbPage extends StatelessWidget {
   final String title;
   final String subtitle;
   final IconData icon;

   const _OnbPage({
     required this.title,
     required this.subtitle,
     required this.icon,
   });

   @override
   Widget build(BuildContext context) {
     final cs = Theme.of(context).colorScheme;
     return Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         Icon(icon, size: 120, color: cs.primary),
         const SizedBox(height: 32),
         Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
         const SizedBox(height: 12),
         Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54)),
       ],
     );
   }
 }

