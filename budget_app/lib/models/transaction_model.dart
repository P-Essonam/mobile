import 'category.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final String type; // 'income' or 'expense'
  final String? description;
  final DateTime transactionDate;
  final DateTime createdAt;
  final Category? category;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.description,
    required this.transactionDate,
    required this.createdAt,
    this.category,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      category: json['categories'] != null 
          ? Category.fromJson(json['categories'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    double? amount,
    String? type,
    String? description,
    DateTime? transactionDate,
    DateTime? createdAt,
    Category? category,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}

