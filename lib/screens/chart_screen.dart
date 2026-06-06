import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../constants/categories.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final expMap = provider.expenseByCategory;
    final total = expMap.values.fold(0.0, (a, b) => a + b);
    final fmt = NumberFormat('#,###', 'ja_JP');
    final entries = expMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('支出グラフ'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: total == 0
          ? const Center(child: Text('支出データがありません', style: TextStyle(color: Colors.grey)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _monthHeader(provider),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 260,
                    child: PieChart(
                      PieChartData(
                        sections: entries.map((e) {
                          final color = categoryColors[e.key] ?? Colors.grey;
                          final pct = (e.value / total * 100).toStringAsFixed(1);
                          return PieChartSectionData(
                            color: color,
                            value: e.value,
                            title: '$pct%',
                            radius: 90,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...entries.map((e) {
                    final color = categoryColors[e.key] ?? Colors.grey;
                    final pct = (e.value / total * 100).toStringAsFixed(1);
                    return _legendRow(e.key, e.value, pct, color, fmt);
                  }),
                ],
              ),
            ),
    );
  }

  Widget _monthHeader(TransactionProvider provider) {
    final fmt = DateFormat('yyyy年M月');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => provider.changeMonth(-1),
        ),
        Text(
          fmt.format(provider.selectedMonth),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => provider.changeMonth(1),
        ),
      ],
    );
  }

  Widget _legendRow(String label, double amount, String pct, Color color, NumberFormat fmt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Text('$pct%', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 12),
          Text('¥${fmt.format(amount)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
