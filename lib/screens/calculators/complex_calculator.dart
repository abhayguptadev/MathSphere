import 'package:flutter/material.dart';
import 'package:equations/equations.dart';
import '../../utils/database_service.dart';
import '../../models/calculation_history.dart';
import '../../utils/constants.dart';

class ComplexCalculator extends StatefulWidget {
  const ComplexCalculator({super.key});

  @override
  State<ComplexCalculator> createState() => _ComplexCalculatorState();
}

class _ComplexCalculatorState extends State<ComplexCalculator> {
  final TextEditingController _realA = TextEditingController();
  final TextEditingController _imagA = TextEditingController();
  final TextEditingController _realB = TextEditingController();
  final TextEditingController _imagB = TextEditingController();
  String _result = "";
  String _selectedOp = "Add";

  void _calculate() {
    try {
      final a = Complex(double.parse(_realA.text), double.parse(_imagA.text));
      final b = Complex(double.parse(_realB.text), double.parse(_imagB.text));
      Complex res;

      switch (_selectedOp) {
        case "Add": res = a + b; break;
        case "Subtract": res = a - b; break;
        case "Multiply": res = a * b; break;
        case "Divide": res = a / b; break;
        default: res = const Complex(0, 0);
      }

      setState(() {
        _result = res.toString();
      });

      DatabaseService.addHistory(
        CalculationHistory(
          id: DateTime.now().toString(),
          expression: "($a) $_selectedOp ($b)",
          result: _result,
          dateTime: DateTime.now(),
          category: 'Complex',
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
        title: const Text('Complex Numbers'),
        backgroundColor: AppColors.complexColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedOp,
              isExpanded: true,
              items: ["Add", "Subtract", "Multiply", "Divide"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedOp = v!),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: TextField(controller: _realA, decoration: const InputDecoration(labelText: "Real A"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _imagA, decoration: const InputDecoration(labelText: "Imag A (i)"))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: TextField(controller: _realB, decoration: const InputDecoration(labelText: "Real B"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _imagB, decoration: const InputDecoration(labelText: "Imag B (i)"))),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.complexColor, foregroundColor: Colors.white),
              child: const Text("Calculate"),
            ),
            const SizedBox(height: 20),
            Text("Result: $_result", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
