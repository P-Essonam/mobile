import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            const SliverAppBar(
              floating: true,
              backgroundColor: AppTheme.primaryDark,
              title: Text('Paramètres'),
            ),

            // Settings Content
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
                            colors: [
                              Color(0xFF1A1A2E),
                              Color(0xFF16213E),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    auth.user?.email ?? 'Email non disponible',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppTheme.textSecondary),
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

                  // Settings Sections
                  Text(
                    'Général',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Gérer les alertes',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bientôt disponible'),
                              backgroundColor: AppTheme.accentBlue,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: AppTheme.surfaceDark),
                      _SettingsTile(
                        icon: Icons.language,
                        title: 'Langue',
                        subtitle: 'Français',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bientôt disponible'),
                              backgroundColor: AppTheme.accentBlue,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: AppTheme.surfaceDark),
                      _SettingsTile(
                        icon: Icons.currency_exchange,
                        title: 'Devise',
                        subtitle: 'EUR (€)',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bientôt disponible'),
                              backgroundColor: AppTheme.accentBlue,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

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
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bientôt disponible'),
                              backgroundColor: AppTheme.accentBlue,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: AppTheme.surfaceDark),
                      _SettingsTile(
                        icon: Icons.category_outlined,
                        title: 'Gérer les catégories',
                        subtitle: 'Personnaliser les catégories',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bientôt disponible'),
                              backgroundColor: AppTheme.accentBlue,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

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
                      const Divider(height: 1, color: AppTheme.surfaceDark),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Conditions d\'utilisation',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bientôt disponible'),
                              backgroundColor: AppTheme.accentBlue,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: AppTheme.surfaceDark),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Politique de confidentialité',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bientôt disponible'),
                              backgroundColor: AppTheme.accentBlue,
                            ),
                          );
                        },
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
                      side: BorderSide(color: AppTheme.expenseRed.withOpacity(0.5)),
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
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
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
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            )
          : null,
      trailing: showArrow
          ? const Icon(
              Icons.chevron_right,
              color: AppTheme.textMuted,
            )
          : null,
    );
  }
}

