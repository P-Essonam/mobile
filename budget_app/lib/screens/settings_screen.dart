import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import 'manage_categories_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLanguageDialog(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsProvider.availableLanguages.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: settingsProvider.language,
              activeColor: AppTheme.incomeGreen,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setLanguage(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Choisir la devise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsProvider.availableCurrencies.entries.map((entry) {
            return RadioListTile<String>(
              title: Text('${entry.value['name']} (${entry.value['symbol']})'),
              value: entry.key,
              groupValue: settingsProvider.currency,
              activeColor: AppTheme.incomeGreen,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setCurrency(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Rappel quotidien'),
                  subtitle: const Text('Recevoir un rappel pour saisir vos dépenses'),
                  value: settings.notificationsEnabled,
                  activeColor: AppTheme.incomeGreen,
                  onChanged: (value) {
                    settings.setNotificationsEnabled(value);
                  },
                ),
                if (settings.notificationsEnabled) ...[
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Heure du rappel'),
                    subtitle: Text('${settings.reminderHour}:00'),
                    trailing: const Icon(Icons.access_time, color: AppTheme.textMuted),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: settings.reminderHour, minute: 0),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppTheme.incomeGreen,
                                surface: AppTheme.cardDark,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        settings.setReminderHour(time.hour);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        settings.testNotification();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification de test envoyée'),
                            backgroundColor: AppTheme.incomeGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Tester la notification'),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final transactionProvider = context.read<TransactionProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final exportService = ExportService();

    // Show export options
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Exporter les données'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_month, color: AppTheme.accentBlue),
              title: const Text('Mois en cours'),
              subtitle: const Text('Transactions du mois sélectionné'),
              onTap: () => Navigator.pop(context, 'month'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.list_alt, color: AppTheme.accentPurple),
              title: const Text('Toutes les transactions'),
              subtitle: const Text('Historique complet'),
              onTap: () => Navigator.pop(context, 'all'),
            ),
          ],
        ),
      ),
    );

    if (choice == null || !context.mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Préparation de l\'export...'),
          backgroundColor: AppTheme.accentBlue,
        ),
      );

      if (choice == 'month') {
        await exportService.exportMonthlySummary(
          transactionProvider.transactions,
          transactionProvider.selectedYear,
          transactionProvider.selectedMonth,
          currency: settingsProvider.currencySymbol,
        );
      } else {
        // Load all transactions first
        final allTransactions = transactionProvider.transactions;
        await exportService.exportTransactionsToCSV(
          allTransactions,
          currency: settingsProvider.currencySymbol,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.expenseRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              floating: true,
              backgroundColor: AppTheme.primaryDark,
              title: Text('Paramètres'),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Profile Section
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withAlpha(25)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: AppTheme.incomeGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  auth.user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mon profil',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    auth.user?.email ?? 'Email non disponible',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // General Section
                  Text(
                    'Général',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) {
                      return _SettingsCard(
                        children: [
                          _SettingsTile(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            subtitle: settings.notificationsEnabled
                                ? 'Rappel à ${settings.reminderHour}:00'
                                : 'Désactivées',
                            onTap: () => _showNotificationSettings(context),
                          ),
                          const Divider(height: 1, color: AppTheme.surfaceDark),
                          _SettingsTile(
                            icon: Icons.language,
                            title: 'Langue',
                            subtitle: SettingsProvider.availableLanguages[settings.language] ?? 'Français',
                            onTap: () => _showLanguageDialog(context),
                          ),
                          const Divider(height: 1, color: AppTheme.surfaceDark),
                          _SettingsTile(
                            icon: Icons.currency_exchange,
                            title: 'Devise',
                            subtitle: '${settings.currency} (${settings.currencySymbol})',
                            onTap: () => _showCurrencyDialog(context),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Data Section
                  Text(
                    'Données',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.download_outlined,
                        title: 'Exporter les données',
                        subtitle: 'Télécharger en CSV',
                        onTap: () => _exportData(context),
                      ),
                      const Divider(height: 1, color: AppTheme.surfaceDark),
                      _SettingsTile(
                        icon: Icons.category_outlined,
                        title: 'Gérer les catégories',
                        subtitle: 'Ajouter, modifier, supprimer',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManageCategoriesScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // About Section
                  Text(
                    'À propos',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline,
                        title: 'Version',
                        subtitle: '1.0.0',
                        showArrow: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  OutlinedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.cardDark,
                          title: const Text('Se déconnecter?'),
                          content: const Text(
                            'Vous devrez vous reconnecter pour accéder à votre compte.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.expenseRed,
                              ),
                              child: const Text('Se déconnecter'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        context.read<TransactionProvider>().reset();
                        await context.read<AuthProvider>().signOut();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.expenseRed,
                      side: BorderSide(color: AppTheme.expenseRed.withAlpha(128)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Se déconnecter'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Credits
                  Center(
                    child: Text(
                      'Développé par Hassiatou & Essonam\n© 2024-2025',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            )
          : null,
      trailing: showArrow
          ? const Icon(Icons.chevron_right, color: AppTheme.textMuted)
          : null,
    );
  }
}
