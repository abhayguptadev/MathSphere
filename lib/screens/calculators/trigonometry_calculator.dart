import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/calculation_history.dart';
import '../../utils/constants.dart';
import '../../utils/database_service.dart';

class TrigonometryCalculator extends StatefulWidget {
  const TrigonometryCalculator({super.key});

  @override
  State<TrigonometryCalculator> createState() => _TrigonometryCalculatorState();
}

class _TrigonometryCalculatorState extends State<TrigonometryCalculator> {
  final TextEditingController _controller = TextEditingController();
  String _result = "";
  String _selectedFunc = "sin";
  bool _isDegree = true;

  Future<void> _calculate() async {
    double? val = double.tryParse(_controller.text);
    if (val == null) {
      setState(() => _result = "Invalid Input");
      return;
    }

    double input = _isDegree ? val * (math.pi / 180.0) : val;
    double res;

    switch (_selectedFunc) {
      case "sin": res = math.sin(input); break;
      case "cos": res = math.cos(input); break;
      case "tan": res = math.tan(input); break;
      case "asin": res = math.asin(val); break;
      case "acos": res = math.acos(val); break;
      case "atan": res = math.atan(val); break;
      default: res = 0;
    }

    setState(() {
      _result = res.toStringAsFixed(4);
    });

    await DatabaseService.addHistory(
      CalculationHistory(
        id: DateTime.now().toString(),
        expression: "$_selectedFunc($val${_isDegree ? '°' : ' rad'})",
        result: _result,
        dateTime: DateTime.now(),
        category: 'Trigonometry',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trigonometry'),
        backgroundColor: AppColors.trigonometryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Mode: "),
                Switch(
                  value: _isDegree,
                  onChanged: (v) => setState(() => _isDegree = v),
                  activeColor: AppColors.trigonometryColor,
                ),
                Text(_isDegree ? "Degrees" : "Radians"),
              ],
            ),
            DropdownButton<String>(
              value: _selectedFunc,
              isExpanded: true,
              items: ["sin", "cos", "tan", "asin", "acos", "atan"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
                  .toList(),
              onChanged: (v) => setState(() => _selectedFunc = v!),
            ),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter value"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.trigonometryColor, foregroundColor: Colors.white),
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
