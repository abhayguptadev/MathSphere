import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../models/calculation_history.dart';
import '../../utils/database_service.dart';

class SimpleCalculator extends StatefulWidget {
  const SimpleCalculator({super.key});

  @override
  State<SimpleCalculator> createState() => _SimpleCalculatorState();
}

class _SimpleCalculatorState extends State<SimpleCalculator> {
  String _equation = "0";
  String _result = "0";
  String _expression = "";

  void buttonPressed(String buttonText) async {
    setState(() {
      if (buttonText == "C") {
        _equation = "0";
        _result = "0";
      } else if (buttonText == "⌫") {
        _equation = _equation.substring(0, _equation.length - 1);
        if (_equation == "") {
          _equation = "0";
        }
      } else if (buttonText == "=") {
        _expression = _equation;
        _expression = _expression.replaceAll('×', '*');
        _expression = _expression.replaceAll('÷', '/');

        try {
          Parser p = Parser();
          Expression exp = p.parse(_expression);
          ContextModel cm = ContextModel();
          _result = '${exp.evaluate(EvaluationType.REAL, cm)}';
        } catch (e) {
          _result = "Error";
        }
      } else {
        if (_equation == "0") {
          _equation = buttonText;
        } else {
          _equation = _equation + buttonText;
        }
      }
    });

    if (buttonText == "=" && _result != "Error") {
      await DatabaseService.addHistory(
        CalculationHistory(
          id: DateTime.now().toString(),
          expression: _equation,
          result: _result,
          dateTime: DateTime.now(),
          category: 'Simple',
        ),
      );
    }
  }

  Widget buildButton(String buttonText, double buttonHeight, Color buttonColor) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1 * buttonHeight,
      color: buttonColor,
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            side: const BorderSide(color: Colors.white, width: 1, style: BorderStyle.solid),
          ),
          padding: const EdgeInsets.all(16.0),
        ),
        onPressed: () => buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.normal, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Calculator')),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Text(_equation, style: const TextStyle(fontSize: 38.0)),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: Text(_result, style: const TextStyle(fontSize: 48.0)),
          ),
          const Expanded(child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width * .75,
                child: Table(
                  children: [
                    TableRow(children: [
                      buildButton("C", 1, Colors.redAccent),
                      buildButton("⌫", 1, Colors.blue),
                      buildButton("÷", 1, Colors.blue),
                    ]),
                    TableRow(children: [
                      buildButton("7", 1, Colors.black54),
                      buildButton("8", 1, Colors.black54),
                      buildButton("9", 1, Colors.black54),
                    ]),
                    TableRow(children: [
                      buildButton("4", 1, Colors.black54),
                      buildButton("5", 1, Colors.black54),
                      buildButton("6", 1, Colors.black54),
                    ]),
                    TableRow(children: [
                      buildButton("1", 1, Colors.black54),
                      buildButton("2", 1, Colors.black54),
                      buildButton("3", 1, Colors.black54),
                    ]),
                    TableRow(children: [
                      buildButton(".", 1, Colors.black54),
                      buildButton("0", 1, Colors.black54),
                      buildButton("00", 1, Colors.black54),
                    ]),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Table(
                  children: [
                    TableRow(children: [
                      buildButton("×", 1, Colors.blue),
                    ]),
                    TableRow(children: [
                      buildButton("-", 1, Colors.blue),
                    ]),
                    TableRow(children: [
                      buildButton("+", 1, Colors.blue),
                    ]),
                    TableRow(children: [
                      buildButton("=", 2, Colors.redAccent),
                    ]),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
