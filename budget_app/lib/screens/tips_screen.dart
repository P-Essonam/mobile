import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

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
              title: Text('Conseils'),
            ),

            // Tips Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4ECDC4),
                          Color(0xFF44A08D),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conseils financiers',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gérez mieux votre argent',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tips List
                  _TipCard(
                    icon: Icons.pie_chart,
                    title: 'La règle 50/30/20',
                    description:
                        'Allouez 50% de vos revenus aux besoins essentiels, 30% aux envies et 20% à l\'épargne.',
                    color: AppTheme.accentPurple,
                  ),
                  const SizedBox(height: 16),

                  _TipCard(
                    icon: Icons.savings,
                    title: 'Fonds d\'urgence',
                    description:
                        'Épargnez 3 à 6 mois de dépenses pour faire face aux imprévus.',
                    color: AppTheme.incomeGreen,
                  ),
                  const SizedBox(height: 16),

                  _TipCard(
                    icon: Icons.trending_down,
                    title: 'Réduisez les dépenses fixes',
                    description:
                        'Renégociez vos abonnements et contrats régulièrement pour économiser.',
                    color: AppTheme.expenseRed,
                  ),
                  const SizedBox(height: 16),

                  _TipCard(
                    icon: Icons.calendar_today,
                    title: 'Budget mensuel',
                    description:
                        'Planifiez vos dépenses en début de mois et suivez-les régulièrement.',
                    color: AppTheme.accentBlue,
                  ),
                  const SizedBox(height: 16),

                  _TipCard(
                    icon: Icons.shopping_cart,
                    title: 'Évitez les achats impulsifs',
                    description:
                        'Attendez 24-48h avant d\'acheter quelque chose de non essentiel.',
                    color: AppTheme.accentOrange,
                  ),
                  const SizedBox(height: 16),

                  _TipCard(
                    icon: Icons.auto_graph,
                    title: 'Investissez tôt',
                    description:
                        'Commencez à investir même de petites sommes pour profiter des intérêts composés.',
                    color: const Color(0xFF22C55E),
                  ),
                  const SizedBox(height: 16),

                  _TipCard(
                    icon: Icons.credit_card_off,
                    title: 'Évitez les dettes coûteuses',
                    description:
                        'Remboursez les crédits à taux élevé en priorité et évitez les découverts.',
                    color: const Color(0xFFEC4899),
                  ),
                  const SizedBox(height: 16),

                  _TipCard(
                    icon: Icons.restaurant,
                    title: 'Cuisinez à la maison',
                    description:
                        'Préparer ses repas coûte en moyenne 3 fois moins cher que manger dehors.',
                    color: const Color(0xFF14B8A6),
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

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

