import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../utils/database_service.dart';
import '../../models/calculation_history.dart';

class ScientificCalculator extends StatefulWidget {
  const ScientificCalculator({super.key});

  @override
  State<ScientificCalculator> createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  String _equation = "0";
  String _result = "0";
  String _expression = "";

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "AC") {
        _equation = "0";
        _result = "0";
      } else if (buttonText == "⌫") {
        _equation = _equation.substring(0, _equation.length - 1);
        if (_equation == "") _equation = "0";
      } else if (buttonText == "=") {
        _expression = _equation;
        _expression = _expression.replaceAll('×', '*');
        _expression = _expression.replaceAll('÷', '/');
        _expression = _expression.replaceAll('π', '3.141592653589793');
        _expression = _expression.replaceAll('e', '2.718281828459045');

        try {
          Parser p = Parser();
          Expression exp = p.parse(_expression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          
          String finalResult;
          if (eval.abs() > 1e12 || (eval.abs() < 1e-10 && eval != 0)) {
            finalResult = eval.toStringAsExponential(6);
          } else {
            // Remove trailing zeros for clean look
            finalResult = eval.toString().contains('.') 
                ? eval.toString().replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')
                : eval.toString();
          }

          setState(() {
            _result = finalResult;
          });

          DatabaseService.addHistory(
            CalculationHistory(
              id: DateTime.now().toString(),
              expression: _equation,
              result: _result,
              dateTime: DateTime.now(),
              category: 'Scientific',
            ),
          );
        } catch (e) {
          setState(() {
            _result = "Error";
          });
        }
      } else {
        if (_equation == "0") {
          _equation = buttonText;
        } else {
          _equation = _equation + buttonText;
        }
      }
    });
  }

  Widget buildButton(String buttonText, Color color, {double widthFactor = 1.0}) {
    return Expanded(
      flex: (widthFactor * 10).toInt(),
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => buttonPressed(buttonText),
          child: Text(buttonText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scientific Calculator')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(_equation, style: const TextStyle(fontSize: 32, color: Colors.grey)),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(_result, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                Row(children: [
                  buildButton("sin", Colors.blueGrey),
                  buildButton("cos", Colors.blueGrey),
                  buildButton("tan", Colors.blueGrey),
                  buildButton("log", Colors.blueGrey),
                ]),
                Row(children: [
                  buildButton("sqrt", Colors.blueGrey),
                  buildButton("^", Colors.blueGrey),
                  buildButton("π", Colors.blueGrey),
                  buildButton("e", Colors.blueGrey),
                ]),
                Row(children: [
                  buildButton("AC", Colors.redAccent),
                  buildButton("⌫", Colors.orange),
                  buildButton("(", Colors.grey),
                  buildButton(")", Colors.grey),
                ]),
                Row(children: [
                  buildButton("7", Colors.grey[800]!),
                  buildButton("8", Colors.grey[800]!),
                  buildButton("9", Colors.grey[800]!),
                  buildButton("÷", Colors.blue),
                ]),
                Row(children: [
                  buildButton("4", Colors.grey[800]!),
                  buildButton("5", Colors.grey[800]!),
                  buildButton("6", Colors.grey[800]!),
                  buildButton("×", Colors.blue),
                ]),
                Row(children: [
                  buildButton("1", Colors.grey[800]!),
                  buildButton("2", Colors.grey[800]!),
                  buildButton("3", Colors.grey[800]!),
                  buildButton("-", Colors.blue),
                ]),
                Row(children: [
                  buildButton(".", Colors.grey[800]!),
                  buildButton("0", Colors.grey[800]!),
                  buildButton("=", Colors.red, widthFactor: 1.0),
                  buildButton("+", Colors.blue),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
