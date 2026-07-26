import 'package:flutter/material.dart';
import 'package:equations/equations.dart';
import '../../models/calculation_history.dart';
import '../../utils/constants.dart';
import '../../utils/database_service.dart';

class AlgebraCalculator extends StatefulWidget {
  const AlgebraCalculator({super.key});

  @override
  State<AlgebraCalculator> createState() => _AlgebraCalculatorState();
}

class _AlgebraCalculatorState extends State<AlgebraCalculator> {
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _cController = TextEditingController();
  String _result = "";
  String _selectedType = "Linear";

  Future<void> _solve() async {
    try {
      if (_selectedType == "Linear") {
        final a = double.parse(_aController.text);
        final b = double.parse(_bController.text);
        if (a == 0) {
          setState(() => _result = b == 0 ? "Infinite solutions" : "No solution");
        } else {
          final res = -b / a;
          setState(() => _result = "x = ${res.toStringAsFixed(2)}");
        }
      } else if (_selectedType == "Quadratic") {
        final a = double.parse(_aController.text);
        final b = double.parse(_bController.text);
        final c = double.parse(_cController.text);
        
        final equation = Quadratic(
          a: Complex.fromReal(a),
          b: Complex.fromReal(b),
          c: Complex.fromReal(c),
        );
        final roots = equation.solutions();
        
        String r1 = roots[0].imaginary == 0 ? roots[0].real.toStringAsFixed(2) : roots[0].toString();
        String r2 = roots[1].imaginary == 0 ? roots[1].real.toStringAsFixed(2) : roots[1].toString();
        
        setState(() => _result = "x₁ = $r1\nx₂ = $r2");
      }

      await DatabaseService.addHistory(
        CalculationHistory(
          id: DateTime.now().toString(),
          expression: "$_selectedType Equation Solver",
          result: _result,
          dateTime: DateTime.now(),
          category: 'Algebra',
        ),
      );
    } catch (e) {
      setState(() => _result = "Error: Invalid Input");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algebra Solver'),
        backgroundColor: AppColors.algebraColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              items: ["Linear", "Quadratic"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedType = v!;
                _result = "";
              }),
            ),
            const SizedBox(height: 10),
            if (_selectedType == "Linear") ...[
              TextField(controller: _aController, decoration: const InputDecoration(labelText: "Coefficient a (ax + b = 0)")),
              TextField(controller: _bController, decoration: const InputDecoration(labelText: "Coefficient b")),
            ] else ...[
              TextField(controller: _aController, decoration: const InputDecoration(labelText: "Coefficient a (ax² + bx + c = 0)")),
              TextField(controller: _bController, decoration: const InputDecoration(labelText: "Coefficient b")),
              TextField(controller: _cController, decoration: const InputDecoration(labelText: "Coefficient c")),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _solve,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.algebraColor, foregroundColor: Colors.white),
              child: const Text("Solve"),
            ),
            const SizedBox(height: 20),
            SelectableText("Result: $_result", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
