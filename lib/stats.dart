///   Author: Zafeer Ur Rahim
///   Date: 14/10/2025
///   Description: Show summary stats for Cluans min, max, mean, sample stdev,
///                plus the shortest and longest answers.
///                LLM: None
///   Changes: none
///   Bugs: None known
///   Reflection:It was fun building the stats screen watching the data come alive with real-time updates.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cluan.dart';

/// Class: StatisticsWidget
/// Screen that reads values from CluansModel and displays them in a list.
class StatisticsWidget extends StatelessWidget {
  const StatisticsWidget({super.key});

  /// Format a nullable double to 1 decimal place.
  /// If the value is null, show "N/A".
  String formatToOneDecimal(double? value) {
    return value == null ? 'N/A' : value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the model so this screen updates when data changes.
    final m = context.watch<CluansModel>();

    final minRange = m.minLength?.toDouble();
    final maxRange = m.maxLength?.toDouble();
    final mean = m.meanLength;
    final sdev = m.sampleStdDev;

    // Pull example rows for shortest/longest
    final shortest = m.shortest;
    final longest = m.longest;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _StatRow(label: 'Min length', value: formatToOneDecimal(minRange)),
          _StatRow(label: 'Max length', value: formatToOneDecimal(maxRange)),
          _StatRow(label: 'Mean length', value: formatToOneDecimal(mean)),
          _StatRow(label: 'Sample std dev', value: formatToOneDecimal(sdev)),
          const Divider(height: 24),

          // Shortest and longest examples. If none, show "N/A".
          ListTile(
            title: const Text('Shortest answer'),
            subtitle: Text(
              shortest == null
                  ? '—'
                  : '"${shortest.answer}" (${shortest.answer.length})',
            ),
          ),
          ListTile(
            title: const Text('Longest answer'),
            subtitle: Text(
              longest == null
                  ? '—'
                  : '"${longest.answer}" (${longest.answer.length})',
            ),
          ),
        ],
      ),
    );
  }
}

/// Class: _StatRow
/// one labeled stat with the value aligned on the right.
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
