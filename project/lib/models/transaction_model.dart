 import 'dart:convert';
 import 'package:uuid/uuid.dart';

 enum TransactionType { income, expense }

 class TransactionModel {
   final String id;
   final String title;
   final double amount;
   final DateTime date;
   final String categoryId;
   final TransactionType type;

   TransactionModel({
     String? id,
     required this.title,
     required this.amount,
     required this.date,
     required this.categoryId,
     required this.type,
   }) : id = id ?? const Uuid().v4();

   Map<String, dynamic> toJson() => {
         'id': id,
         'title': title,
         'amount': amount,
         'date': date.toIso8601String(),
         'categoryId': categoryId,
         'type': type.name,
       };

   factory TransactionModel.fromJson(Map<String, dynamic> json) {
     return TransactionModel(
       id: json['id'] as String?,
       title: json['title'] as String,
       amount: (json['amount'] as num).toDouble(),
       date: DateTime.parse(json['date'] as String),
       categoryId: json['categoryId'] as String,
       type: (json['type'] as String) == 'income'
           ? TransactionType.income
           : TransactionType.expense,
     );
   }

   static String encodeList(List<TransactionModel> list) =>
       jsonEncode(list.map((e) => e.toJson()).toList());

   static List<TransactionModel> decodeList(String? source) {
     if (source == null || source.isEmpty) return [];
     final data = jsonDecode(source) as List<dynamic>;
     return data.map((e) => TransactionModel.fromJson(e)).toList();
   }
 }

