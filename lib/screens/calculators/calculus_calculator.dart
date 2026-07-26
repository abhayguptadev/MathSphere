import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../models/calculation_history.dart';
import '../../utils/constants.dart';
import '../../utils/database_service.dart';

class CalculusCalculator extends StatefulWidget {
  const CalculusCalculator({super.key});

  @override
  State<CalculusCalculator> createState() => _CalculusCalculatorState();
}

class _CalculusCalculatorState extends State<CalculusCalculator> {
  final TextEditingController _funcController = TextEditingController(text: "x^2");
  final TextEditingController _pointController = TextEditingController(text: "2");
  String _result = "";
  String _selectedOp = "Derivative";

  Future<void> _calculate() async {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_funcController.text);
      Variable x = Variable('x');
      double val = double.parse(_pointController.text);
      ContextModel cm = ContextModel()..bindVariable(x, Number(val));

      if (_selectedOp == "Derivative") {
        Expression derivative = exp.derive('x').simplify();
        double eval = derivative.evaluate(EvaluationType.REAL, cm);
        
        // Handle potential NaN or Infinity
        String evalStr = eval.isNaN ? "Undefined" : eval.isInfinite ? "Infinity" : eval.toStringAsFixed(4);
        
        setState(() => _result = "f'(x) = ${derivative.toString()}\nAt x=$val, f'($val) = $evalStr");
      } else {
        // Numerical Integration using Simpson's Rule
        double lowerBound = 0; // Default lower bound for now, or could ask user
        double upperBound = val;
        int n = 1000; // intervals
        double h = (upperBound - lowerBound) / n;
        double sum = exp.evaluate(EvaluationType.REAL, ContextModel()..bindVariable(x, Number(lowerBound))) +
                     exp.evaluate(EvaluationType.REAL, ContextModel()..bindVariable(x, Number(upperBound)));

        for (int i = 1; i < n; i++) {
          double xVal = lowerBound + i * h;
          cm.bindVariable(x, Number(xVal));
          sum += exp.evaluate(EvaluationType.REAL, cm) * (i % 2 == 0 ? 2 : 4);
        }
        double eval = (h / 3) * sum;
        setState(() => _result = "∫ f(x) dx from 0 to $val\nResult ≈ ${eval.toStringAsFixed(4)}");
      }

      await DatabaseService.addHistory(
        CalculationHistory(
          id: DateTime.now().toString(),
          expression: "$_selectedOp of ${_funcController.text} at ${_pointController.text}",
          result: _result,
          dateTime: DateTime.now(),
          category: 'Calculus',
        ),
      );
    } catch (e) {
      setState(() => _result = "Error: Invalid Expression");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculus Solver'),
        backgroundColor: AppColors.calculusColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedOp,
              isExpanded: true,
              items: ["Derivative", "Integral"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedOp = v!),
            ),
            TextField(
              controller: _funcController,
              decoration: const InputDecoration(labelText: "Function f(x)", hintText: "e.g., x^2 + 3*x"),
            ),
            TextField(
              controller: _pointController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Point x"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.calculusColor, foregroundColor: Colors.white),
              child: const Text("Calculate"),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.calculusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                "Result:\n$_result",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
