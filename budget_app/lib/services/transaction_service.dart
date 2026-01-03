import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all transactions for current user
  Future<List<TransactionModel>> getTransactions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('transactions')
        .select('*, categories(*)')
        .eq('user_id', userId)
        .order('transaction_date', ascending: false);

    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  // Get transactions for a specific month
  Future<List<TransactionModel>> getTransactionsByMonth(int year, int month) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final response = await _supabase
        .from('transactions')
        .select('*, categories(*)')
        .eq('user_id', userId)
        .gte('transaction_date', startDate.toIso8601String().split('T')[0])
        .lte('transaction_date', endDate.toIso8601String().split('T')[0])
        .order('transaction_date', ascending: false);

    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  // Get recent transactions (last 5)
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('transactions')
        .select('*, categories(*)')
        .eq('user_id', userId)
        .order('transaction_date', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  // Create a new transaction
  Future<TransactionModel> createTransaction({
    required String categoryId,
    required double amount,
    required String type,
    String? description,
    required DateTime transactionDate,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase.from('transactions').insert({
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
    }).select('*, categories(*)').single();

    return TransactionModel.fromJson(response);
  }

  // Update a transaction
  Future<TransactionModel> updateTransaction({
    required String id,
    String? categoryId,
    double? amount,
    String? description,
    DateTime? transactionDate,
  }) async {
    final updates = <String, dynamic>{};
    if (categoryId != null) updates['category_id'] = categoryId;
    if (amount != null) updates['amount'] = amount;
    if (description != null) updates['description'] = description;
    if (transactionDate != null) {
      updates['transaction_date'] = transactionDate.toIso8601String().split('T')[0];
    }

    final response = await _supabase
        .from('transactions')
        .update(updates)
        .eq('id', id)
        .select('*, categories(*)')
        .single();

    return TransactionModel.fromJson(response);
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    await _supabase.from('transactions').delete().eq('id', id);
  }

  // Get total income for a month
  Future<double> getTotalIncomeForMonth(int year, int month) async {
    final transactions = await getTransactionsByMonth(year, month);
    return transactions
        .where((t) => t.type == 'income')
        .fold<double>(0.0, (double sum, t) => sum + t.amount);
  }

  // Get total expense for a month
  Future<double> getTotalExpenseForMonth(int year, int month) async {
    final transactions = await getTransactionsByMonth(year, month);
    return transactions
        .where((t) => t.type == 'expense')
        .fold<double>(0.0, (double sum, t) => sum + t.amount);
  }

  // Get balance for a month
  Future<double> getBalanceForMonth(int year, int month) async {
    final income = await getTotalIncomeForMonth(year, month);
    final expense = await getTotalExpenseForMonth(year, month);
    return income - expense;
  }

  // Get spending by category for a month
  Future<Map<String, double>> getSpendingByCategory(int year, int month) async {
    final transactions = await getTransactionsByMonth(year, month);
    final Map<String, double> spending = {};

    for (var t in transactions.where((t) => t.type == 'expense')) {
      final categoryName = t.category?.name ?? 'Autres';
      spending[categoryName] = (spending[categoryName] ?? 0) + t.amount;
    }

    return spending;
  }

  // Get monthly totals for the last N months
  Future<List<Map<String, dynamic>>> getMonthlyTotals(int months) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final List<Map<String, dynamic>> results = [];

    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final income = await getTotalIncomeForMonth(date.year, date.month);
      final expense = await getTotalExpenseForMonth(date.year, date.month);

      results.add({
        'month': date,
        'income': income,
        'expense': expense,
        'balance': income - expense,
      });
    }

    return results;
  }
}

