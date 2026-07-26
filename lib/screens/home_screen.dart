import 'package:flutter/material.dart';
import '../main.dart';
import '../models/calculator_category.dart';
import '../utils/constants.dart';
import 'calculators/simple_calculator.dart';
import 'calculators/trigonometry_calculator.dart';
import 'calculators/algebra_calculator.dart';
import 'calculators/calculus_calculator.dart';
import 'calculators/matrix_calculator.dart';
import 'calculators/complex_calculator.dart';
import 'calculators/geometry_calculator.dart';
import 'calculators/graphing_calculator.dart';
import 'calculators/unit_converter.dart';
import 'calculators/scientific_calculator.dart';
import 'calculators/statistics_calculator.dart';
import 'calculators/financial_calculator.dart';
import 'calculators/probability_calculator.dart';
import 'calculators/formula_library.dart';
import 'notes_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<CalculatorCategory> categories;

  @override
  void initState() {
    super.initState();
    categories = [
      CalculatorCategory(
        title: 'Simple',
        icon: Icons.calculate,
        color: Colors.orange,
        screen: const SimpleCalculator(),
      ),
      CalculatorCategory(
        title: 'Scientific',
        icon: Icons.science,
        color: Colors.blueGrey,
        screen: const ScientificCalculator(),
      ),
      CalculatorCategory(
        title: 'Trigonometry',
        icon: Icons.change_history,
        color: AppColors.trigonometryColor,
        screen: const TrigonometryCalculator(),
      ),
      CalculatorCategory(
        title: 'Algebra',
        icon: Icons.functions,
        color: AppColors.algebraColor,
        screen: const AlgebraCalculator(),
      ),
      CalculatorCategory(
        title: 'Calculus',
        icon: Icons.show_chart,
        color: AppColors.calculusColor,
        screen: const CalculusCalculator(),
      ),
      CalculatorCategory(
        title: 'Matrix',
        icon: Icons.grid_on,
        color: AppColors.matrixColor,
        screen: const MatrixCalculator(),
      ),
      CalculatorCategory(
        title: 'Complex',
        icon: Icons.exposure_plus_1,
        color: AppColors.complexColor,
        screen: const ComplexCalculator(),
      ),
      CalculatorCategory(
        title: 'Geometry',
        icon: Icons.architecture,
        color: AppColors.geometryColor,
        screen: const GeometryCalculator(),
      ),
      CalculatorCategory(
        title: 'Graphing',
        icon: Icons.auto_graph,
        color: Colors.indigo,
        screen: const GraphingCalculator(),
      ),
      CalculatorCategory(
        title: 'Unit Converter',
        icon: Icons.compare_arrows,
        color: Colors.teal,
        screen: const UnitConverter(),
      ),
      CalculatorCategory(
        title: 'Statistics',
        icon: Icons.bar_chart,
        color: AppColors.statisticsColor,
        screen: const StatisticsCalculator(),
      ),
      CalculatorCategory(
        title: 'Financial',
        icon: Icons.monetization_on,
        color: AppColors.financialColor,
        screen: const FinancialCalculator(),
      ),
      CalculatorCategory(
        title: 'Probability',
        icon: Icons.casino,
        color: AppColors.probabilityColor,
        screen: const ProbabilityCalculator(),
      ),
      CalculatorCategory(
        title: 'Formula Library',
        icon: Icons.menu_book,
        color: Colors.black,
        screen: const FormulaLibrary(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mathApp = MathSphereApp.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MathSphere'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.note_alt),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotesScreen()),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 1200 ? 6 : (constraints.maxWidth > 800 ? 4 : 2);
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(context, category);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CalculatorCategory category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => category.screen),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, size: 48, color: category.color),
            const SizedBox(height: 12),
            Text(
              category.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
