import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_saver/file_saver.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../utils/database_service.dart';
import '../../models/calculation_history.dart';
import '../../utils/constants.dart';

class GraphingCalculator extends StatefulWidget {
  const GraphingCalculator({super.key});

  @override
  State<GraphingCalculator> createState() => _GraphingCalculatorState();
}

class _GraphingCalculatorState extends State<GraphingCalculator> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final List<TextEditingController> _controllers = [TextEditingController(text: "x^2")];
  List<LineChartBarData> _chartData = [];
  double _minX = -10;
  double _maxX = 10;
  double _minY = -10;
  double _maxY = 10;

  final List<Color> _colors = [Colors.indigo, Colors.red, Colors.green, Colors.orange, Colors.purple];

  @override
  void initState() {
    super.initState();
    _generateAllPoints();
  }

  void _addFunction() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeFunction(int index) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers.removeAt(index);
        _generateAllPoints();
      });
    }
  }

  void _generateAllPoints() {
    try {
      List<LineChartBarData> newData = [];
      GrammarParser p = GrammarParser();
      Variable x = Variable('x');

      for (int k = 0; k < _controllers.length; k++) {
        if (_controllers[k].text.isEmpty) continue;
        
        Expression exp = p.parse(_controllers[k].text);
        List<FlSpot> points = [];
        double step = (_maxX - _minX) / 200;

        for (double i = _minX; i <= _maxX; i += step) {
          ContextModel cm = ContextModel()..bindVariable(x, Number(i));
          double y = exp.evaluate(EvaluationType.REAL, cm);
          if (y.isFinite && y.abs() < 1000) { // Limit y range for better visibility
            points.add(FlSpot(i, y));
          }
        }

        if (points.isNotEmpty) {
          newData.add(
            LineChartBarData(
              spots: points,
              isCurved: true,
              color: _colors[k % _colors.length],
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          );
        }
      }

      setState(() {
        _chartData = newData;
      });

      DatabaseService.addHistory(
        CalculationHistory(
          id: DateTime.now().toString(),
          expression: "Graphs: ${_controllers.map((c) => c.text).join(', ')}",
          result: "Plotted ${_controllers.length} functions",
          dateTime: DateTime.now(),
          category: 'Graphing',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error parsing expression. Check your syntax.")),
      );
    }
  }

  Future<void> _exportGraph(String format) async {
    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes == null) return;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'mathsphere_graph_$timestamp';

      if (kIsWeb) {
        // Web logic: Use FileSaver for direct browser download
        if (format == 'jpg') {
          await FileSaver.instance.saveFile(
            name: fileName,
            bytes: imageBytes,
            customMimeType: 'jpg',
            mimeType: MimeType.jpeg,
          );
        } else if (format == 'pdf') {
          final pdf = pw.Document();
          final image = pw.MemoryImage(imageBytes);
          pdf.addPage(
            pw.Page(
              build: (pw.Context context) => pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text("MathSphere Graph Export",
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 20),
                    pw.Image(image),
                  ],
                ),
              ),
            ),
          );
          final pdfBytes = await pdf.save();
          await FileSaver.instance.saveFile(
            name: fileName,
            bytes: pdfBytes,
            customMimeType: 'pdf',
            mimeType: MimeType.pdf,
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Download started...")),
        );
        return;
      }

      // Mobile/Desktop logic (unchanged)
      final directory = await getApplicationDocumentsDirectory();
      final fullPath = '${directory.path}/$fileName.$format';
      
      if (format == 'jpg') {
        final imageFile = File(fullPath);
        await imageFile.writeAsBytes(imageBytes);
        await Share.shareXFiles([XFile(fullPath)], text: 'My Mathematical Graph');
      } else if (format == 'pdf') {
        final pdf = pw.Document();
        final image = pw.MemoryImage(imageBytes);
        pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Image(image))));
        final pdfFile = File(fullPath);
        await pdfFile.writeAsBytes(await pdf.save());
        await Share.shareXFiles([XFile(fullPath)], text: 'My Mathematical Graph PDF');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graphing Calculator'),
        backgroundColor: Colors.indigo,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            onSelected: _exportGraph,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'jpg', child: Text("Export as JPG")),
              const PopupMenuItem(value: 'pdf', child: Text("Export as PDF")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ..._controllers.asMap().entries.map((entry) {
                  int idx = entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: "f(x) ${idx + 1}",
                              prefixIcon: Icon(Icons.show_chart, color: _colors[idx % _colors.length]),
                              border: const OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _generateAllPoints(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeFunction(idx),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _addFunction,
                      icon: const Icon(Icons.add),
                      label: const Text("Add Function"),
                    ),
                    ElevatedButton(
                      onPressed: _generateAllPoints,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      child: const Text("Update Graph"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
                child: LineChart(
                  LineChartData(
                    clipData: const FlClipData.all(),
                    gridData: const FlGridData(show: true, drawVerticalLine: true),
                    titlesData: const FlTitlesData(
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    minX: _minX,
                    maxX: _maxX,
                    minY: _minY,
                    maxY: _maxY,
                    lineBarsData: _chartData,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => Colors.indigo.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(icon: const Icon(Icons.zoom_in), onPressed: () {
                  setState(() {
                    _minX /= 1.5; _maxX /= 1.5; _minY /= 1.5; _maxY /= 1.5;
                    _generateAllPoints();
                  });
                }),
                IconButton(icon: const Icon(Icons.zoom_out), onPressed: () {
                  setState(() {
                    _minX *= 1.5; _maxX *= 1.5; _minY *= 1.5; _maxY *= 1.5;
                    _generateAllPoints();
                  });
                }),
                IconButton(icon: const Icon(Icons.center_focus_strong), onPressed: () {
                  setState(() {
                    _minX = -10; _maxX = 10; _minY = -10; _maxY = 10;
                    _generateAllPoints();
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
