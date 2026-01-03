import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/category.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> _recentTransactions = [];
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _balance = 0;
  
  Map<String, double> _spendingByCategory = {};
  List<Map<String, dynamic>> _monthlyTotals = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  List<Category> get expenseCategories => _expenseCategories;
  List<Category> get incomeCategories => _incomeCategories;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _balance;
  Map<String, double> get spendingByCategory => _spendingByCategory;
  List<Map<String, dynamic>> get monthlyTotals => _monthlyTotals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  // Initialize data
  Future<void> init() async {
    await Future.wait([
      loadCategories(),
      loadTransactions(),
      loadRecentTransactions(),
      loadMonthlyStats(),
    ]);
  }

  // Load all categories
  Future<void> loadCategories() async {
    try {
      _expenseCategories = await _categoryService.getExpenseCategories();
      _incomeCategories = await _categoryService.getIncomeCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des catégories.';
      notifyListeners();
    }
  }

  // Load transactions for selected month
  Future<void> loadTransactions() async {
    try {
      _isLoading = true;
      notifyListeners();

      _transactions = await _transactionService.getTransactionsByMonth(
        _selectedYear,
        _selectedMonth,
      );

      _calculateTotals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors du chargement des transactions.';
      notifyListeners();
    }
  }

  // Load recent transactions
  Future<void> loadRecentTransactions() async {
    try {
      _recentTransactions = await _transactionService.getRecentTransactions(limit: 5);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des transactions récentes.';
      notifyListeners();
    }
  }

  // Load monthly stats
  Future<void> loadMonthlyStats() async {
    try {
      _spendingByCategory = await _transactionService.getSpendingByCategory(
        _selectedYear,
        _selectedMonth,
      );
      _monthlyTotals = await _transactionService.getMonthlyTotals(6);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des statistiques.';
      notifyListeners();
    }
  }

  // Change selected month
  void setMonth(int year, int month) {
    _selectedYear = year;
    _selectedMonth = month;
    loadTransactions();
    loadMonthlyStats();
  }

  // Go to previous month
  void previousMonth() {
    if (_selectedMonth == 1) {
      _selectedMonth = 12;
      _selectedYear--;
    } else {
      _selectedMonth--;
    }
    loadTransactions();
    loadMonthlyStats();
  }

  // Go to next month
  void nextMonth() {
    final now = DateTime.now();
    if (_selectedYear == now.year && _selectedMonth == now.month) {
      return; // Can't go to future
    }
    
    if (_selectedMonth == 12) {
      _selectedMonth = 1;
      _selectedYear++;
    } else {
      _selectedMonth++;
    }
    loadTransactions();
    loadMonthlyStats();
  }

  // Add new transaction
  Future<bool> addTransaction({
    required String categoryId,
    required double amount,
    required String type,
    String? description,
    required DateTime date,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _transactionService.createTransaction(
        categoryId: categoryId,
        amount: amount,
        type: type,
        description: description,
        transactionDate: date,
      );

      await Future.wait([
        loadTransactions(),
        loadRecentTransactions(),
        loadMonthlyStats(),
      ]);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors de l\'ajout de la transaction.';
      notifyListeners();
      return false;
    }
  }

  // Update transaction
  Future<bool> updateTransaction({
    required String id,
    String? categoryId,
    double? amount,
    String? description,
    DateTime? date,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _transactionService.updateTransaction(
        id: id,
        categoryId: categoryId,
        amount: amount,
        description: description,
        transactionDate: date,
      );

      await Future.wait([
        loadTransactions(),
        loadRecentTransactions(),
        loadMonthlyStats(),
      ]);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors de la mise à jour.';
      notifyListeners();
      return false;
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _transactionService.deleteTransaction(id);

      await Future.wait([
        loadTransactions(),
        loadRecentTransactions(),
        loadMonthlyStats(),
      ]);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors de la suppression.';
      notifyListeners();
      return false;
    }
  }

  // Calculate totals from loaded transactions
  void _calculateTotals() {
    _totalIncome = _transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    _totalExpense = _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    _balance = _totalIncome - _totalExpense;
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset state (on logout)
  void reset() {
    _transactions = [];
    _recentTransactions = [];
    _expenseCategories = [];
    _incomeCategories = [];
    _totalIncome = 0;
    _totalExpense = 0;
    _balance = 0;
    _spendingByCategory = {};
    _monthlyTotals = [];
    _isLoading = false;
    _errorMessage = null;
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;
    notifyListeners();
  }
}

