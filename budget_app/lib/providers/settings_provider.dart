import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const Map<String, String> availableLanguages = {
    'fr': 'Français',
    'en': 'English',
  };

  static const Map<String, Map<String, String>> availableCurrencies = {
    'EUR': {'name': 'Euro', 'symbol': '€'},
    'USD': {'name': 'Dollar US', 'symbol': '\$'},
    'XOF': {'name': 'Franc CFA', 'symbol': 'FCFA'},
    'GBP': {'name': 'Livre Sterling', 'symbol': '£'},
  };

  String _language = 'fr';
  String _currency = 'EUR';
  bool _notificationsEnabled = false;
  int _reminderHour = 20;

  final NotificationService _notificationService = NotificationService();

  String get language => _language;
  String get currency => _currency;
  String get currencySymbol => availableCurrencies[_currency]?['symbol'] ?? '€';
  bool get notificationsEnabled => _notificationsEnabled;
  int get reminderHour => _reminderHour;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('language') ?? 'fr';
    _currency = prefs.getString('currency') ?? 'EUR';
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    _reminderHour = prefs.getInt('reminder_hour') ?? 20;
    
    // Initialize notification service
    await _notificationService.initialize();
    
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> setCurrency(String curr) async {
    _currency = curr;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', curr);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    
    if (enabled) {
      await _notificationService.scheduleDailyReminder(_reminderHour);
    } else {
      await _notificationService.cancelAllNotifications();
    }
    
    notifyListeners();
  }

  Future<void> setReminderHour(int hour) async {
    _reminderHour = hour;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', hour);
    
    if (_notificationsEnabled) {
      await _notificationService.scheduleDailyReminder(hour);
    }
    
    notifyListeners();
  }

  Future<void> testNotification() async {
    await _notificationService.showTestNotification();
  }

  String formatAmount(double amount) {
    final symbol = currencySymbol;
    if (_currency == 'XOF') {
      return '${amount.toStringAsFixed(0)} $symbol';
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}
