import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/budget_summary.dart';
import '../widgets/transaction_card.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<TransactionProvider>().init();
          },
          color: AppTheme.incomeGreen,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: AppTheme.primaryDark,
                title: const Text('Dashboard'),
                actions: [
                  Consumer<TransactionProvider>(
                    builder: (context, provider, _) {
                      final dateFormatter = DateFormat('MMMM yyyy', 'fr_FR');
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
              
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: Consumer<TransactionProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading && provider.transactions.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.incomeGreen,
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        // Budget Summary Card
                        BudgetSummary(
                          balance: provider.balance,
                          income: provider.totalIncome,
                          expense: provider.totalExpense,
                        ),
                        const SizedBox(height: 24),
                        
                        // Quick Actions
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.remove,
                                label: 'Dépense',
                                color: AppTheme.expenseRed,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddExpenseScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.add,
                                label: 'Revenu',
                                color: AppTheme.incomeGreen,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddIncomeScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Recent Transactions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transactions récentes',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (provider.recentTransactions.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: AppTheme.cardDark,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucune transaction',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: AppTheme.textMuted),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Commencez par ajouter une dépense ou un revenu',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppTheme.textMuted),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ...provider.recentTransactions.map((transaction) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TransactionCard(
                                transaction: transaction,
                                onDelete: () async {
                                  await provider.deleteTransaction(transaction.id);
                                },
                              ),
                            );
                          }),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

