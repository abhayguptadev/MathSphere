import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/database_service.dart';
import '../../models/calculation_history.dart';

class MatrixCalculator extends StatefulWidget {
  const MatrixCalculator({super.key});

  @override
  State<MatrixCalculator> createState() => _MatrixCalculatorState();
}

class _MatrixCalculatorState extends State<MatrixCalculator> {
  int _rows = 2;
  int _cols = 2;
  late List<List<TextEditingController>> _matrixA;
  late List<List<TextEditingController>> _matrixB;
  String _result = "";
  String _selectedOp = "Addition";

  @override
  void initState() {
    super.initState();
    _initMatrices();
  }

  void _initMatrices() {
    _matrixA = List.generate(_rows, (_) => List.generate(_cols, (_) => TextEditingController()));
    _matrixB = List.generate(_rows, (_) => List.generate(_cols, (_) => TextEditingController()));
  }

  void _calculate() {
    try {
      List<List<double>> a = _matrixA.map((row) => row.map((e) => double.tryParse(e.text) ?? 0.0).toList()).toList();
      List<List<double>> b = _matrixB.map((row) => row.map((e) => double.tryParse(e.text) ?? 0.0).toList()).toList();
      List<List<double>> res = List.generate(_rows, (_) => List.generate(_cols, (_) => 0.0));

      if (_selectedOp == "Addition") {
        for (int i = 0; i < _rows; i++) {
          for (int j = 0; j < _cols; j++) {
            res[i][j] = a[i][j] + b[i][j];
          }
        }
      } else if (_selectedOp == "Subtraction") {
        for (int i = 0; i < _rows; i++) {
          for (int j = 0; j < _cols; j++) {
            res[i][j] = a[i][j] - b[i][j];
          }
        }
      } else if (_selectedOp == "Multiplication") {
        if (_cols != _rows) {
          setState(() => _result = "Error: Rows must equal Columns for this multiplication implementation");
          return;
        }
        res = List.generate(_rows, (_) => List.generate(_cols, (_) => 0.0));
        for (int i = 0; i < _rows; i++) {
          for (int j = 0; j < _cols; j++) {
            for (int k = 0; k < _cols; k++) {
              res[i][j] += a[i][k] * b[k][j];
            }
          }
        }
      }

      setState(() {
        _result = res.map((row) => "[${row.join(', ')}]").join('\n');
      });

      DatabaseService.addHistory(
        CalculationHistory(
          id: DateTime.now().toString(),
          expression: "Matrix A (${_rows}x${_cols}) $_selectedOp Matrix B",
          result: _result.replaceAll('\n', ' '),
          dateTime: DateTime.now(),
          category: 'Matrix',
        ),
      );
    } catch (e) {
      setState(() => _result = "Error: Invalid Input");
    }
  }

  Widget _buildMatrixInput(List<List<TextEditingController>> matrix, String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        for (int i = 0; i < _rows; i++)
          Row(
            children: [
              for (int j = 0; j < _cols; j++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      controller: matrix[i][j],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrix Calculator'),
        backgroundColor: AppColors.matrixColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Size: "),
                DropdownButton<int>(
                  value: _rows,
                  items: [2, 3, 4].map((e) => DropdownMenuItem(value: e, child: Text("${e}x$e"))).toList(),
                  onChanged: (v) => setState(() {
                    _rows = v!;
                    _cols = v;
                    _initMatrices();
                  }),
                ),
                const Spacer(),
                const Text("Op: "),
                DropdownButton<String>(
                  value: _selectedOp,
                  items: ["Addition", "Subtraction", "Multiplication"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedOp = v!),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMatrixInput(_matrixA, "Matrix A"),
            const Divider(height: 40),
            _buildMatrixInput(_matrixB, "Matrix B"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.matrixColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Calculate Result"),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.matrixColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Result Matrix:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_result, style: const TextStyle(fontSize: 18, fontFamily: 'monospace')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
