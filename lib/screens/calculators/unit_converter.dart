import 'package:flutter/material.dart';
import '../../utils/database_service.dart';
import '../../models/calculation_history.dart';

class UnitConverter extends StatefulWidget {
  const UnitConverter({super.key});

  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = "Length";
  String _fromUnit = "Meters";
  String _toUnit = "Kilometers";
  String _result = "";

  final Map<String, List<String>> _units = {
    "Length": ["Meters", "Kilometers", "Miles", "Feet", "Inches"],
    "Weight": ["Kilograms", "Grams", "Pounds", "Ounces"],
    "Temperature": ["Celsius", "Fahrenheit", "Kelvin"],
  };

  final Map<String, double> _conversionRates = {
    "Meters": 1.0,
    "Kilometers": 0.001,
    "Miles": 0.000621371,
    "Feet": 3.28084,
    "Inches": 39.3701,
    "Kilograms": 1.0,
    "Grams": 1000.0,
    "Pounds": 2.20462,
    "Ounces": 35.274,
  };

  void _convert() {
    double? val = double.tryParse(_controller.text);
    if (val == null) return;

    double res = 0;
    if (_selectedCategory == "Temperature") {
      if (_fromUnit == "Celsius") {
        if (_toUnit == "Fahrenheit") res = (val * 9 / 5) + 32;
        else if (_toUnit == "Kelvin") res = val + 273.15;
        else res = val;
      } else if (_fromUnit == "Fahrenheit") {
        if (_toUnit == "Celsius") res = (val - 32) * 5 / 9;
        else if (_toUnit == "Kelvin") res = (val - 32) * 5 / 9 + 273.15;
        else res = val;
      } else { // Kelvin
        if (_toUnit == "Celsius") res = val - 273.15;
        else if (_toUnit == "Fahrenheit") res = (val - 273.15) * 9 / 5 + 32;
        else res = val;
      }
    } else {
      // Standard conversion via base unit (Meters or Kilograms)
      double baseVal = val / _conversionRates[_fromUnit]!;
      res = baseVal * _conversionRates[_toUnit]!;
    }

    setState(() {
      _result = res.toStringAsFixed(4);
    });

    DatabaseService.addHistory(
      CalculationHistory(
        id: DateTime.now().toString(),
        expression: "$val $_fromUnit to $_toUnit",
        result: "$_result $_toUnit",
        dateTime: DateTime.now(),
        category: 'Conversion',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unit Converter'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: _units.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() {
                  _selectedCategory = v!;
                  _fromUnit = _units[_selectedCategory]![0];
                  _toUnit = _units[_selectedCategory]![1];
                  _result = "";
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Value to convert"),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _fromUnit,
                    isExpanded: true,
                    items: _units[_selectedCategory]!.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() { _fromUnit = v!; _convert(); }),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.arrow_forward)),
                Expanded(
                  child: DropdownButton<String>(
                    value: _toUnit,
                    isExpanded: true,
                    items: _units[_selectedCategory]!.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() { _toUnit = v!; _convert(); }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text("Result: $_result $_toUnit", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
          ],
        ),
      ),
    );
  }
}
