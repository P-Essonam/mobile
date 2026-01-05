import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import '../models/transaction_model.dart';

class ExportService {
  Future<void> exportTransactionsToCSV(
    List<TransactionModel> transactions, {
    String currency = '€',
  }) async {
    if (transactions.isEmpty) {
      throw Exception('Aucune transaction à exporter');
    }

    final dateFormatter = DateFormat('dd/MM/yyyy');
    
    // Create CSV data
    List<List<dynamic>> csvData = [
      // Header row
      ['Date', 'Type', 'Catégorie', 'Montant', 'Description'],
    ];

    // Add transaction rows
    for (var transaction in transactions) {
      csvData.add([
        dateFormatter.format(transaction.transactionDate),
        transaction.type == 'income' ? 'Revenu' : 'Dépense',
        transaction.category?.name ?? 'Sans catégorie',
        '${transaction.amount.toStringAsFixed(2)} $currency',
        transaction.description ?? '',
      ]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(csvData);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'transactions_$timestamp.csv';

    await _downloadFile(csv, fileName);
  }

  Future<void> exportMonthlySummary(
    List<TransactionModel> transactions,
    int year,
    int month, {
    String currency = '€',
  }) async {
    final monthTransactions = transactions.where((t) {
      return t.transactionDate.year == year && t.transactionDate.month == month;
    }).toList();

    if (monthTransactions.isEmpty) {
      throw Exception('Aucune transaction ce mois-ci');
    }

    final dateFormatter = DateFormat('dd/MM/yyyy');
    final monthName = DateFormat('MMMM yyyy', 'fr_FR').format(DateTime(year, month));

    // Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> expensesByCategory = {};

    for (var t in monthTransactions) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
        final catName = t.category?.name ?? 'Autres';
        expensesByCategory[catName] = (expensesByCategory[catName] ?? 0) + t.amount;
      }
    }

    // Create CSV data
    List<List<dynamic>> csvData = [
      ['RAPPORT MENSUEL - $monthName'],
      [],
      ['RÉSUMÉ'],
      ['Total Revenus', '${totalIncome.toStringAsFixed(2)} $currency'],
      ['Total Dépenses', '${totalExpense.toStringAsFixed(2)} $currency'],
      ['Solde', '${(totalIncome - totalExpense).toStringAsFixed(2)} $currency'],
      [],
      ['DÉPENSES PAR CATÉGORIE'],
    ];

    // Add expense categories
    if (expensesByCategory.isNotEmpty) {
      expensesByCategory.forEach((category, amount) {
        final percentage = totalExpense > 0 
            ? (amount / totalExpense * 100).toStringAsFixed(1) 
            : '0';
        csvData.add([category, '${amount.toStringAsFixed(2)} $currency', '$percentage%']);
      });
    } else {
      csvData.add(['Aucune dépense', '0.00 $currency', '0%']);
    }

    csvData.addAll([
      [],
      ['DÉTAIL DES TRANSACTIONS'],
      ['Date', 'Type', 'Catégorie', 'Montant', 'Description'],
    ]);

    // Add transaction rows
    for (var transaction in monthTransactions) {
      csvData.add([
        dateFormatter.format(transaction.transactionDate),
        transaction.type == 'income' ? 'Revenu' : 'Dépense',
        transaction.category?.name ?? 'Sans catégorie',
        '${transaction.amount.toStringAsFixed(2)} $currency',
        transaction.description ?? '',
      ]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(csvData);
    final fileName = 'budget_${year}_${month.toString().padLeft(2, '0')}.csv';

    await _downloadFile(csv, fileName);
  }

  Future<void> _downloadFile(String content, String fileName) async {
    if (kIsWeb) {
      // Web: Create a download link
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      
      html.document.body?.children.add(anchor);
      anchor.click();
      
      // Cleanup
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile: Use path_provider and share_plus
      // Import these only for mobile
      final pathProvider = await _getPathProvider();
      final sharePlugin = await _getSharePlugin();
      
      if (pathProvider != null && sharePlugin != null) {
        final directory = await pathProvider.call();
        final file = await _writeFile(directory, fileName, content);
        await sharePlugin.call(file);
      }
    }
  }

  // Dynamic imports for mobile only
  Future<Function?> _getPathProvider() async {
    if (kIsWeb) return null;
    try {
      // This will only work on mobile
      final module = await Future.value(null); // Placeholder
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Function?> _getSharePlugin() async {
    if (kIsWeb) return null;
    return null;
  }

  Future<dynamic> _writeFile(dynamic directory, String fileName, String content) async {
    return null;
  }
}
