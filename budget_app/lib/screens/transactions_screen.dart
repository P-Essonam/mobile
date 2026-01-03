import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_card.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

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
              title: const Text('Transactions'),
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

            // Transactions List
            Consumer<TransactionProvider>(
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

                if (provider.transactions.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune transaction ce mois',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Group transactions by date
                final groupedTransactions = <String, List<dynamic>>{};
                final dateFormatter = DateFormat('EEEE d MMMM', 'fr_FR');

                for (var transaction in provider.transactions) {
                  final dateKey = dateFormatter.format(transaction.transactionDate);
                  groupedTransactions.putIfAbsent(dateKey, () => []);
                  groupedTransactions[dateKey]!.add(transaction);
                }

                final sortedDates = groupedTransactions.keys.toList();

                return SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final dateKey = sortedDates[index];
                        final transactions = groupedTransactions[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (index > 0) const SizedBox(height: 24),
                            Text(
                              dateKey.substring(0, 1).toUpperCase() +
                                  dateKey.substring(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            ...transactions.map((transaction) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TransactionCard(
                                  transaction: transaction,
                                  onDelete: () async {
                                    await provider.deleteTransaction(
                                      transaction.id,
                                    );
                                  },
                                ),
                              );
                            }),
                          ],
                        );
                      },
                      childCount: sortedDates.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

