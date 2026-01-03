import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/chart_widgets.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppTheme.primaryDark,
              title: const Text('Statistiques'),
              actions: [
                Consumer<TransactionProvider>(
                  builder: (context, provider, _) {
                    final dateFormatter = DateFormat('MMM yyyy', 'fr_FR');
                    final selectedDate = DateTime(
                      provider.selectedYear,
                      provider.selectedMonth,
                    );
                    return Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => provider.previousMonth(),
                        ),
                        Text(
                          dateFormatter.format(selectedDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => provider.nextMonth(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            // Stats Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: Consumer<TransactionProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.incomeGreen,
                        ),
                      ),
                    );
                  }

                  final formatter = NumberFormat.currency(
                    locale: 'fr_FR',
                    symbol: '€',
                  );

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Revenus',
                              amount: formatter.format(provider.totalIncome),
                              icon: Icons.arrow_downward,
                              color: AppTheme.incomeGreen,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: 'Dépenses',
                              amount: formatter.format(provider.totalExpense),
                              icon: Icons.arrow_upward,
                              color: AppTheme.expenseRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _StatCard(
                        title: 'Économies',
                        amount: formatter.format(provider.balance),
                        icon: Icons.savings,
                        color: provider.balance >= 0
                            ? AppTheme.incomeGreen
                            : AppTheme.expenseRed,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 32),

                      // Spending by Category
                      Text(
                        'Répartition des dépenses',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: ExpensePieChart(
                          spendingByCategory: provider.spendingByCategory,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Monthly Evolution
                      Text(
                        'Évolution sur 6 mois',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: MonthlyLineChart(
                          monthlyTotals: provider.monthlyTotals,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.fullWidth = false,
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
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

