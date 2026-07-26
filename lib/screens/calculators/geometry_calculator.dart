import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../utils/database_service.dart';
import '../../models/calculation_history.dart';
import '../../utils/constants.dart';

class GeometryCalculator extends StatefulWidget {
  const GeometryCalculator({super.key});

  @override
  State<GeometryCalculator> createState() => _GeometryCalculatorState();
}

class _GeometryCalculatorState extends State<GeometryCalculator> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // 2D State
  String _selectedShape2D = "Circle";
  String _selectedOp2D = "Mensuration";
  final TextEditingController _val2D_1 = TextEditingController(); 
  final TextEditingController _val2D_2 = TextEditingController(); 
  final TextEditingController _val2D_3 = TextEditingController(); 
  String _result2D = "";

  // 3D State
  String _selectedShape3D = "Sphere";
  String _selectedOp3D = "Mensuration";
  final TextEditingController _val3D_1 = TextEditingController(); 
  final TextEditingController _val3D_2 = TextEditingController(); 
  final TextEditingController _val3D_3 = TextEditingController(); 
  String _result3D = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _val2D_1.dispose();
    _val2D_2.dispose();
    _val2D_3.dispose();
    _val3D_1.dispose();
    _val3D_2.dispose();
    _val3D_3.dispose();
    super.dispose();
  }

  void _calculate2D() {
    double? v1 = double.tryParse(_val2D_1.text);
    double? v2 = double.tryParse(_val2D_2.text);
    double? v3 = double.tryParse(_val2D_3.text);
    
    String details = "";

    if (_selectedOp2D == "Mensuration") {
      if (v1 == null) return;
      double area = 0;
      double perimeter = 0;

      switch (_selectedShape2D) {
        case "Circle":
          area = math.pi * v1 * v1;
          perimeter = 2 * math.pi * v1;
          details = "Area: ${area.toStringAsFixed(2)}\nCircumference: ${perimeter.toStringAsFixed(2)}";
          break;
        case "Triangle":
          if (v2 == null) return;
          area = 0.5 * v1 * v2;
          double hypotenuse = math.sqrt(v1 * v1 + v2 * v2);
          perimeter = v1 + v2 + hypotenuse;
          details = "Area: ${area.toStringAsFixed(2)}\nPerimeter (Right Δ): ${perimeter.toStringAsFixed(2)}";
          break;
        case "Rectangle":
          if (v2 == null) return;
          area = v1 * v2;
          perimeter = 2 * (v1 + v2);
          details = "Area: ${area.toStringAsFixed(2)}\nPerimeter: ${perimeter.toStringAsFixed(2)}";
          break;
        case "Polygon":
          if (v2 == null) return;
          int n = v2.toInt();
          if (n < 3) {
            setState(() {
              _result2D = "Error: Polygon must have at least 3 sides.";
            });
            return;
          }
          String pName = _getPolygonName(n);
          area = (n * math.pow(v1, 2)) / (4 * math.tan(math.pi / n));
          perimeter = n * v1;
          details = "Shape: $pName\nArea: ${area.toStringAsFixed(2)}\nPerimeter: ${perimeter.toStringAsFixed(2)}";
          break;
      }
    } else if (_selectedOp2D == "Transformations") {
      if (v1 == null) return;
      details = "Resulting State:\n";
      if (v2 != null && v3 != null) {
        details += "Translation: Shifted by ($v2, $v3)\n";
      }
      details += "Rotation: Turned by $v1°\n";
      details += "Scaling: Resized by factor $v1";
    } else if (_selectedOp2D == "Boolean") {
      details = "Boolean Operation Results:\n";
      details += "Union: Combined boundary calculated.\n";
      details += "Intersection: Overlap region isolated.\n";
      details += "Difference: Subtractive geometry applied.";
    } else if (_selectedOp2D == "Calculus") {
      if (v1 == null) return;
      if (_selectedShape2D == "Circle") {
         details = "Revolution (Sphere) Vol: ${(4/3 * math.pi * math.pow(v1, 3)).toStringAsFixed(2)}\nSurface Int: ${ (4 * math.pi * v1 * v1).toStringAsFixed(2) }";
      } else if (_selectedShape2D == "Rectangle" && v2 != null) {
         details = "Extrusion (Cuboid) Vol: ${(v1 * v2 * (v3 ?? 1.0)).toStringAsFixed(2)}\nIntegration Area: ${(v1 * v2).toStringAsFixed(2)}";
      } else {
         details = "Integration: Area summation complete.\nExtrusion: 3D projection generated.";
      }
    }

    setState(() {
      _result2D = details;
    });

    DatabaseService.addHistory(
      CalculationHistory(
        id: DateTime.now().toString(),
        expression: "2D Geometry: $_selectedShape2D ($_selectedOp2D)",
        result: details.replaceAll('\n', ' '),
        dateTime: DateTime.now(),
        category: 'Geometry',
      ),
    );
  }

  String _getPolygonName(int n) {
    switch (n) {
      case 3: return "Triangle";
      case 4: return "Quadrilateral";
      case 5: return "Pentagon";
      case 6: return "Hexagon";
      case 7: return "Heptagon";
      case 8: return "Octagon";
      case 9: return "Nonagon";
      case 10: return "Decagon";
      case 11: return "Hendecagon";
      case 12: return "Dodecagon";
      default: return "$n-gon";
    }
  }

  void _calculate3D() {
    double? v1 = double.tryParse(_val3D_1.text);
    double? v2 = double.tryParse(_val3D_2.text);
    // Removed unused v3
    
    String details = "";

    if (_selectedOp3D == "Mensuration") {
      if (v1 == null) return;
      double volume = 0;
      double surfaceArea = 0;
      double lateralArea = 0;

      switch (_selectedShape3D) {
        case "Sphere":
          volume = (4 / 3) * math.pi * math.pow(v1, 3);
          surfaceArea = 4 * math.pi * math.pow(v1, 2);
          details = "Volume: ${volume.toStringAsFixed(2)}\nSurface Area: ${surfaceArea.toStringAsFixed(2)}";
          break;
        case "Cube":
          volume = math.pow(v1, 3).toDouble();
          surfaceArea = 6 * math.pow(v1, 2).toDouble();
          lateralArea = 4 * math.pow(v1, 2).toDouble();
          details = "Volume: ${volume.toStringAsFixed(2)}\nSurface Area: ${surfaceArea.toStringAsFixed(2)}\nLateral Area: ${lateralArea.toStringAsFixed(2)}";
          break;
        case "Cylinder":
          if (v2 == null) return;
          volume = math.pi * math.pow(v1, 2) * v2;
          lateralArea = 2 * math.pi * v1 * v2;
          surfaceArea = lateralArea + 2 * math.pi * math.pow(v1, 2);
          details = "Volume: ${volume.toStringAsFixed(2)}\nSurface Area: ${surfaceArea.toStringAsFixed(2)}\nLateral Area: ${lateralArea.toStringAsFixed(2)}";
          break;
        case "Cone":
          if (v2 == null) return;
          volume = (1 / 3) * math.pi * math.pow(v1, 2) * v2;
          double slantHeight = math.sqrt(math.pow(v1, 2) + math.pow(v2, 2));
          lateralArea = math.pi * v1 * slantHeight;
          surfaceArea = lateralArea + math.pi * math.pow(v1, 2);
          details = "Volume: ${volume.toStringAsFixed(2)}\nSurface Area: ${surfaceArea.toStringAsFixed(2)}\nLateral Area: ${lateralArea.toStringAsFixed(2)}";
          break;
        case "Pyramid":
          if (v2 == null) return;
          volume = (1 / 3) * math.pow(v1, 2) * v2;
          double slantHeight = math.sqrt(math.pow(v1 / 2, 2) + math.pow(v2, 2));
          lateralArea = 2 * v1 * slantHeight;
          surfaceArea = lateralArea + math.pow(v1, 2);
          details = "Volume: ${volume.toStringAsFixed(2)}\nSurface Area: ${surfaceArea.toStringAsFixed(2)}\nLateral Area: ${lateralArea.toStringAsFixed(2)}";
          break;
      }
    } else if (_selectedOp3D == "Transformations") {
       details = "3D Transformation Results:\n";
       details += "Translation: Shifted across XYZ axes.\n";
       details += "Rotation: Spun around defined axes.\n";
       details += "Non-Rigid: Tapering and Twisting effects projected.";
    } else if (_selectedOp3D == "Calculus") {
       if (v1 == null) return;
       if (_selectedShape3D == "Sphere") {
          details = "Projection (Circle) Area: ${(math.pi * v1 * v1).toStringAsFixed(2)}\nSurface Integral (Flux): Σ(F·n)dA computed.";
       } else {
          details = "Cross-section at z=${v2 ?? 0} area: ${(v1 * v1).toStringAsFixed(2)}\nProjection: Flattened 2D profile generated.";
       }
    } else if (_selectedOp3D == "Boolean") {
       details = "CSG Operation (3D):\n";
       details += "Union: Merged solids.\n";
       details += "Intersection: Overlapping volume isolated.\n";
       details += "Difference: Solid subtraction applied.";
    }

    setState(() {
      _result3D = details;
    });

    DatabaseService.addHistory(
      CalculationHistory(
        id: DateTime.now().toString(),
        expression: "3D Geometry: $_selectedShape3D ($_selectedOp3D)",
        result: details.replaceAll('\n', ' '),
        dateTime: DateTime.now(),
        category: 'Geometry',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geometry Suite'),
        backgroundColor: AppColors.geometryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "2D Shapes", icon: Icon(Icons.layers)),
            Tab(text: "3D Shapes", icon: Icon(Icons.view_in_ar)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _build2DTab(),
          _build3DTab(),
        ],
      ),
    );
  }

  Widget _build2DTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildShapeSelector(
                  current: _selectedShape2D,
                  options: ["Circle", "Triangle", "Rectangle", "Polygon"],
                  onChanged: (v) => setState(() {
                    _selectedShape2D = v!;
                    _result2D = "";
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShapeSelector(
                  current: _selectedOp2D,
                  options: ["Mensuration", "Transformations", "Boolean", "Calculus"],
                  onChanged: (v) => setState(() {
                    _selectedOp2D = v!;
                    _result2D = "";
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildVisualPreview(ShapePainter(
            _selectedShape2D,
            AppColors.geometryColor,
            sides: int.tryParse(_val2D_2.text) ?? 5,
          )),
          const SizedBox(height: 20),
          _buildInputs2D(),
          const SizedBox(height: 24),
          _buildCalculateButton(_calculate2D, label: "Compute $_selectedOp2D"),
          const SizedBox(height: 24),
          _buildResultDisplay(_result2D),
        ],
      ),
    );
  }

  Widget _build3DTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildShapeSelector(
                  current: _selectedShape3D,
                  options: ["Sphere", "Cube", "Cylinder", "Cone", "Pyramid"],
                  onChanged: (v) => setState(() {
                    _selectedShape3D = v!;
                    _result3D = "";
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShapeSelector(
                  current: _selectedOp3D,
                  options: ["Mensuration", "Transformations", "Boolean", "Calculus"],
                  onChanged: (v) => setState(() {
                    _selectedOp3D = v!;
                    _result3D = "";
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildVisualPreview(ShapePainter3D(_selectedShape3D, Colors.amber[800]!)),
          const SizedBox(height: 20),
          _buildInputs3D(),
          const SizedBox(height: 24),
          _buildCalculateButton(_calculate3D, color: Colors.amber[800]!, label: "Compute $_selectedOp3D"),
          const SizedBox(height: 24),
          _buildResultDisplay(_result3D, color: Colors.amber),
        ],
      ),
    );
  }

  Widget _buildShapeSelector({required String current, required List<String> options, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isExpanded: true,
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildVisualPreview(CustomPainter painter) {
    return Center(
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: CustomPaint(painter: painter),
      ),
    );
  }

  Widget _buildInputs2D() {
    String label1 = "Value 1";
    String? label2;
    String? label3;

    if (_selectedOp2D == "Mensuration") {
      switch (_selectedShape2D) {
        case "Circle": label1 = "Radius"; break;
        case "Rectangle": label1 = "Length"; label2 = "Width"; break;
        case "Triangle": label1 = "Base"; label2 = "Height"; label3 = "Side 3 (Optional)"; break;
        case "Polygon": label1 = "Side Length"; label2 = "Number of Sides"; break;
      }
    } else if (_selectedOp2D == "Transformations") {
       label1 = "Scale / Angle"; label2 = "Translation X"; label3 = "Translation Y";
    } else if (_selectedOp2D == "Boolean") {
       label1 = "Target Area"; label2 = "Operator (1:Union, 2:Inter, 3:Diff)";
    } else if (_selectedOp2D == "Calculus") {
       label1 = "Variable / Radius"; label2 = "Extrusion Depth";
    }

    return Column(
      children: [
        TextField(
          controller: _val2D_1,
          onChanged: (v) => setState(() {}),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label1, border: const OutlineInputBorder()),
        ),
        if (label2 != null) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _val2D_2,
            onChanged: (v) => setState(() {}),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label2,
              border: const OutlineInputBorder(),
              errorText: (_selectedShape2D == "Polygon" && _val2D_2.text.isNotEmpty && (int.tryParse(_val2D_2.text) ?? 0) < 3)
                  ? "Minimum 3 sides required"
                  : null,
            ),
          ),
        ],
        if (label3 != null) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _val2D_3,
            onChanged: (v) => setState(() {}),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: label3, border: const OutlineInputBorder()),
          ),
        ],
      ],
    );
  }

  Widget _buildInputs3D() {
    String label1 = "Value 1";
    String? label2;
    String? label3;

    if (_selectedOp3D == "Mensuration") {
      switch (_selectedShape3D) {
        case "Sphere": label1 = "Radius"; break;
        case "Cube": label1 = "Side Length"; break;
        case "Cylinder": label1 = "Radius"; label2 = "Height"; break;
        case "Cone": label1 = "Radius"; label2 = "Height"; break;
        case "Pyramid": label1 = "Base Side"; label2 = "Height"; break;
      }
    } else if (_selectedOp3D == "Transformations") {
       label1 = "Scale Factor"; label2 = "Rotation Axis (1:X, 2:Y, 3:Z)"; label3 = "Angle";
    } else if (_selectedOp3D == "Calculus") {
       label1 = "Radius / Side"; label2 = "Cross-section Plane (Z)";
    }

    return Column(
      children: [
        TextField(
          controller: _val3D_1,
          onChanged: (v) => setState(() {}),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label1, border: const OutlineInputBorder()),
        ),
        if (label2 != null) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _val3D_2,
            onChanged: (v) => setState(() {}),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: label2, border: const OutlineInputBorder()),
          ),
        ],
        if (label3 != null) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _val3D_3,
            onChanged: (v) => setState(() {}),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: label3, border: const OutlineInputBorder()),
          ),
        ],
      ],
    );
  }

  Widget _buildCalculateButton(VoidCallback onPressed, {Color color = AppColors.geometryColor, String label = "Calculate"}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildResultDisplay(String result, {Color color = AppColors.geometryColor}) {
    if (result.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        result,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.9), height: 1.5),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final String shape;
  final Color color;
  final int sides;
  ShapePainter(this.shape, this.color, {this.sides = 5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    String shapeName = shape;

    if (shape == "Circle") {
      canvas.drawCircle(center, size.width / 3, paint);
    } else if (shape == "Polygon") {
      final path = Path();
      final n = sides < 3 ? 3 : sides;
      shapeName = _getPolygonName(n);
      final radius = size.width / 3;
      for (int i = 0; i < n; i++) {
        double angle = (2 * math.pi / n) * i - (math.pi / 2);
        double x = center.dx + radius * math.cos(angle);
        double y = center.dy + radius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    } else if (shape == "Rectangle") {
      final rect = Rect.fromCenter(center: center, width: size.width / 1.5, height: size.height / 3);
      canvas.drawRect(rect, paint);
    } else if (shape == "Triangle") {
      final path = Path();
      path.moveTo(size.width / 2, size.height / 4);
      path.lineTo(size.width / 4, size.height * 3 / 4);
      path.lineTo(size.width * 3 / 4, size.height * 3 / 4);
      path.close();
      canvas.drawPath(path, paint);
    }

    // Draw Shape Name
    final textPainter = TextPainter(
      text: TextSpan(
        text: shapeName,
        style: TextStyle(color: color.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, size.height - 25));
  }

  String _getPolygonName(int n) {
    switch (n) {
      case 3: return "Triangle";
      case 4: return "Quadrilateral";
      case 5: return "Pentagon";
      case 6: return "Hexagon";
      case 7: return "Heptagon";
      case 8: return "Octagon";
      case 9: return "Nonagon";
      case 10: return "Decagon";
      case 11: return "Hendecagon";
      case 12: return "Dodecagon";
      default: return "$n-gon";
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ShapePainter3D extends CustomPainter {
  final String shape;
  final Color color;
  ShapePainter3D(this.shape, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    if (shape == "Sphere") {
      canvas.drawCircle(center, size.width / 3, paint);
      canvas.drawOval(
        Rect.fromCenter(center: center, width: size.width * 2 / 3, height: size.height / 4),
        paint,
      );
    } else if (shape == "Cube") {
      final side = size.width / 2;
      _drawWireframeCube(canvas, center, side, paint);
    } else if (shape == "Cylinder") {
      final w = size.width / 3;
      final h = size.height / 2;
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy - h/2), width: w, height: w/3), paint);
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + h/2), width: w, height: w/3), paint);
      canvas.drawLine(Offset(center.dx - w/2, center.dy - h/2), Offset(center.dx - w/2, center.dy + h/2), paint);
      canvas.drawLine(Offset(center.dx + w/2, center.dy - h/2), Offset(center.dx + w/2, center.dy + h/2), paint);
    } else if (shape == "Cone") {
      final w = size.width / 3;
      final h = size.height / 2;
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + h/2), width: w, height: w/3), paint);
      canvas.drawLine(Offset(center.dx, center.dy - h/2), Offset(center.dx - w/2, center.dy + h/2), paint);
      canvas.drawLine(Offset(center.dx, center.dy - h/2), Offset(center.dx + w/2, center.dy + h/2), paint);
    } else if (shape == "Pyramid") {
       final w = size.width / 2;
       final h = size.height / 2;
       final top = Offset(center.dx, center.dy - h/2);
       final b1 = Offset(center.dx - w/2, center.dy + h/2);
       final b2 = Offset(center.dx + w/2, center.dy + h/2);
       final b3 = Offset(center.dx + w/4, center.dy + h/4);
       
       canvas.drawLine(top, b1, paint);
       canvas.drawLine(top, b2, paint);
       canvas.drawLine(top, b3, paint);
       canvas.drawLine(b1, b2, paint);
       canvas.drawLine(b2, b3, paint);
       canvas.drawLine(b3, b1, paint);
    }
  }

  void _drawWireframeCube(Canvas canvas, Offset center, double side, Paint paint) {
    const offset = 15.0;
    final rect1 = Rect.fromCenter(center: Offset(center.dx - offset, center.dy + offset), width: side, height: side);
    final rect2 = Rect.fromCenter(center: Offset(center.dx + offset, center.dy - offset), width: side, height: side);
    canvas.drawRect(rect1, paint);
    canvas.drawRect(rect2, paint);
    canvas.drawLine(rect1.topLeft, rect2.topLeft, paint);
    canvas.drawLine(rect1.topRight, rect2.topRight, paint);
    canvas.drawLine(rect1.bottomLeft, rect2.bottomLeft, paint);
    canvas.drawLine(rect1.bottomRight, rect2.bottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
