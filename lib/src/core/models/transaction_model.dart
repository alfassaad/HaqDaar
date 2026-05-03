import 'package:flutter/material.dart';

enum TransactionType { credit, debit }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final IconData icon;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.icon,
  });

  bool get isCredit => type == TransactionType.credit;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
      'iconCode': icon.codePoint,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      type: TransactionType.values.byName(map['type'] ?? 'debit'),
      icon: IconData(map['iconCode'] ?? Icons.payment.codePoint, fontFamily: 'MaterialIcons'),
    );
  }
}
