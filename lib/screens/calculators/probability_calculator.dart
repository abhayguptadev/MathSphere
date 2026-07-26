import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../utils/database_service.dart';
import '../../models/calculation_history.dart';
import '../../utils/constants.dart';

class ProbabilityCalculator extends StatefulWidget {
  const ProbabilityCalculator({super.key});

  @override
  State<ProbabilityCalculator> createState() => _ProbabilityCalculatorState();
}

class _ProbabilityCalculatorState extends State<ProbabilityCalculator> {
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _rController = TextEditingController();
  String _result = "";
  String _formula = "";

  double _factorial(int n) {
    if (n < 0) return 0;
    if (n == 0 || n == 1) return 1;
    double res = 1;
    for (int i = 2; i <= n; i++) res *= i;
    return res;
  }

  void _calculate(String type) {
    int? n = int.tryParse(_nController.text);
    int? r = int.tryParse(_rController.text);

    if (n == null || r == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid integers for n and r")),
      );
      return;
    }

    setState(() {
      if (type == "nPr") {
        if (n < r) {
          _result = "n must be >= r";
          _formula = "";
        } else {
          double res = _factorial(n) / _factorial(n - r);
          _result = "Permutations (nPr): ${res.toStringAsFixed(0)}";
          _formula = "P(n,r) = n! / (n-r)!";
        }
      } else if (type == "nCr") {
        if (n < r) {
          _result = "n must be >= r";
          _formula = "";
        } else {
          double res = _factorial(n) / (_factorial(r) * _factorial(n - r));
          _result = "Combinations (nCr): ${res.toStringAsFixed(0)}";
          _formula = "C(n,r) = n! / (r! * (n-r)!)";
        }
      } else if (type == "Prob") {
        if (n == 0) {
          _result = "Sample space cannot be 0";
          _formula = "";
        } else {
          double res = r / n;
          _result = "Probability: ${res.toStringAsFixed(6)}\n($r out of $n)";
          _formula = "P(E) = n(E) / n(S)";
        }
      }
    });

    if (_result.isNotEmpty && !_result.contains("must be")) {
      DatabaseService.addHistory(
        CalculationHistory(
          id: DateTime.now().toString(),
          expression: "$type with n=$n, r=$r",
          result: _result.replaceAll('\n', ' '),
          dateTime: DateTime.now(),
          category: 'Probability',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Probability Calculator'),
        backgroundColor: AppColors.probabilityColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "n (Total Items / Sample Space)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.apps),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _rController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "r (Selected / Favorable Events)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.check_circle_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _calculate("nPr"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.probabilityColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text("Permutation"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _calculate("nCr"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.probabilityColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text("Combination"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _calculate("Prob"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.probabilityColor.withValues(alpha: 0.8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Basic Probability"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_result.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.probabilityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.probabilityColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    if (_formula.isNotEmpty) ...[
                      Text(
                        _formula,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppColors.probabilityColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      _result,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.probabilityColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
