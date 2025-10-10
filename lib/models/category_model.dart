 import 'package:flutter/material.dart';

 class CategoryModel {
   final String id;
   final String name;
   final IconData icon;
   final Color color;
   final bool isExpense; // true = expense, false = income

   const CategoryModel({
     required this.id,
     required this.name,
     required this.icon,
     required this.color,
     required this.isExpense,
   });

   Map<String, dynamic> toJson() => {
         'id': id,
         'name': name,
         'iconCodePoint': icon.codePoint,
         'iconFontFamily': icon.fontFamily,
         'color': color.value,
         'isExpense': isExpense,
       };

   factory CategoryModel.fromJson(Map<String, dynamic> json) {
     return CategoryModel(
       id: json['id'] as String,
       name: json['name'] as String,
       icon: IconData(
         json['iconCodePoint'] as int,
         fontFamily: json['iconFontFamily'] as String?,
       ),
       color: Color(json['color'] as int),
       isExpense: json['isExpense'] as bool? ?? true,
     );
   }
 }

 // Default categories
 class DefaultCategories {
   static const List<CategoryModel> expenses = [
     CategoryModel(
       id: 'food',
       name: 'Еда',
       icon: Icons.restaurant,
       color: Color(0xFFEF5350),
       isExpense: true,
     ),
     CategoryModel(
       id: 'transport',
       name: 'Транспорт',
       icon: Icons.directions_bus,
       color: Color(0xFF42A5F5),
       isExpense: true,
     ),
     CategoryModel(
       id: 'rent',
       name: 'Аренда',
       icon: Icons.home,
       color: Color(0xFFAB47BC),
       isExpense: true,
     ),
     CategoryModel(
       id: 'clothes',
       name: 'Одежда',
       icon: Icons.checkroom,
       color: Color(0xFF26A69A),
       isExpense: true,
     ),
     CategoryModel(
       id: 'entertainment',
       name: 'Развлечения',
       icon: Icons.local_activity,
       color: Color(0xFFFFA726),
       isExpense: true,
     ),
   ];

   static const List<CategoryModel> incomes = [
     CategoryModel(
       id: 'salary',
       name: 'Зарплата',
       icon: Icons.payments,
       color: Color(0xFF66BB6A),
       isExpense: false,
     ),
     CategoryModel(
       id: 'bonus',
       name: 'Бонус',
       icon: Icons.card_giftcard,
       color: Color(0xFF8D6E63),
       isExpense: false,
     ),
   ];

   static List<CategoryModel> all() => [
         ...expenses,
         ...incomes,
       ];
 }

