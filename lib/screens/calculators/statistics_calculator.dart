import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../utils/database_service.dart';
import '../../models/calculation_history.dart';
import '../../utils/constants.dart';

class StatisticsCalculator extends StatefulWidget {
  const StatisticsCalculator({super.key});

  @override
  State<StatisticsCalculator> createState() => _StatisticsCalculatorState();
}

class _StatisticsCalculatorState extends State<StatisticsCalculator> {
  final TextEditingController _dataController = TextEditingController();
  Map<String, String> _results = {};

  void _calculateStats() {
    String input = _dataController.text;
    if (input.isEmpty) return;

    try {
      List<double> data = input
          .split(',')
          .map((e) => double.tryParse(e.trim()))
          .where((e) => e != null)
          .cast<double>()
          .toList();

      if (data.isEmpty) throw Exception("No valid numbers found");

      // Mean
      double sum = data.reduce((a, b) => a + b);
      double mean = sum / data.length;

      // Median
      data.sort();
      double median;
      int middle = data.length ~/ 2;
      if (data.length % 2 == 1) {
        median = data[middle];
      } else {
        median = (data[middle - 1] + data[middle]) / 2;
      }

      // Mode
      Map<double, int> freq = {};
      for (var x in data) freq[x] = (freq[x] ?? 0) + 1;
      int maxFreq = freq.values.reduce((a, b) => a > b ? a : b);
      List<double> modes = freq.entries
          .where((e) => e.value == maxFreq)
          .map((e) => e.key)
          .toList();

      // Standard Deviation & Variance
      double variance = data.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / data.length;
      double stdDev = math.sqrt(variance);

      setState(() {
        _results = {
          "Count": data.length.toString(),
          "Mean": mean.toStringAsFixed(4),
          "Median": median.toStringAsFixed(4),
          "Mode": modes.length == data.length ? "None" : modes.join(', '),
          "Std Dev": stdDev.toStringAsFixed(4),
          "Variance": variance.toStringAsFixed(4),
          "Min": data.first.toString(),
          "Max": data.last.toString(),
          "Sum": sum.toStringAsFixed(2),
        };
      });

      DatabaseService.addHistory(
        CalculationHistory(
          id: DateTime.now().toString(),
          expression: "Stats: ${data.length} items",
          result: "Mean: ${mean.toStringAsFixed(2)}",
          dateTime: DateTime.now(),
          category: 'Statistics',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Please enter numbers separated by commas (e.g. 1, 2, 3)")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Calculator'),
        backgroundColor: AppColors.statisticsColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Enter Dataset",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Numbers separated by commas",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dataController,
                      decoration: InputDecoration(
                        hintText: "e.g. 10, 20, 15, 30, 25",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.list_alt),
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.05),
                      ),
                      maxLines: 4,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _calculateStats,
                      icon: const Icon(Icons.analytics),
                      label: const Text("Calculate All Stats"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statisticsColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_results.isNotEmpty) ...[
              const Text(
                "Result Analysis",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  String key = _results.keys.elementAt(index);
                  String value = _results[key]!;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statisticsColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.statisticsColor.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(key, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
