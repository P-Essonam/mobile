import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> spendingByCategory;

  const ExpensePieChart({
    super.key,
    required this.spendingByCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (spendingByCategory.isEmpty) {
      return const Center(
        child: Text(
          'Aucune dépense ce mois',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    final total = spendingByCategory.values.fold(0.0, (a, b) => a + b);
    final colors = [
      AppTheme.expenseRed,
      AppTheme.accentBlue,
      AppTheme.accentPurple,
      AppTheme.accentOrange,
      const Color(0xFF22C55E),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      AppTheme.textMuted,
    ];

    final entries = spendingByCategory.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: List.generate(entries.length, (index) {
                final entry = entries[index];
                final percentage = (entry.value / total) * 100;
                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 45,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(entries.length, (index) {
            final entry = entries[index];
            return _LegendItem(
              color: colors[index % colors.length],
              label: entry.key,
              amount: entry.value,
            );
          }),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double amount;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ${formatter.format(amount)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}

class MonthlyLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyTotals;

  const MonthlyLineChart({
    super.key,
    required this.monthlyTotals,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyTotals.isEmpty) {
      return const Center(
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    final dateFormatter = DateFormat('MMM', 'fr_FR');
    final maxValue = monthlyTotals.fold<double>(0, (max, item) {
      final income = item['income'] as double;
      final expense = item['expense'] as double;
      return [max, income, expense].reduce((a, b) => a > b ? a : b);
    });

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxValue / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && 
                          value.toInt() < monthlyTotals.length) {
                        final date = monthlyTotals[value.toInt()]['month'] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dateFormatter.format(date),
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // Income line
                LineChartBarData(
                  spots: List.generate(monthlyTotals.length, (index) {
                    return FlSpot(
                      index.toDouble(),
                      monthlyTotals[index]['income'] as double,
                    );
                  }),
                  isCurved: true,
                  color: AppTheme.incomeGreen,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: AppTheme.incomeGreen,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.incomeGreen.withOpacity(0.1),
                  ),
                ),
                // Expense line
                LineChartBarData(
                  spots: List.generate(monthlyTotals.length, (index) {
                    return FlSpot(
                      index.toDouble(),
                      monthlyTotals[index]['expense'] as double,
                    );
                  }),
                  isCurved: true,
                  color: AppTheme.expenseRed,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: AppTheme.expenseRed,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.expenseRed.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => AppTheme.cardDark,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final formatter = NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: '€',
                      );
                      final isIncome = spot.barIndex == 0;
                      return LineTooltipItem(
                        formatter.format(spot.y),
                        TextStyle(
                          color: isIncome 
                              ? AppTheme.incomeGreen 
                              : AppTheme.expenseRed,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ChartLegend(
              color: AppTheme.incomeGreen,
              label: 'Revenus',
            ),
            const SizedBox(width: 24),
            _ChartLegend(
              color: AppTheme.expenseRed,
              label: 'Dépenses',
            ),
          ],
        ),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}

