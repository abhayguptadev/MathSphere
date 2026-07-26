import 'package:flutter/material.dart';
import '../../models/user_formula.dart';
import '../../utils/database_service.dart';

class FormulaLibrary extends StatefulWidget {
  const FormulaLibrary({super.key});

  @override
  State<FormulaLibrary> createState() => _FormulaLibraryState();
}

class _FormulaLibraryState extends State<FormulaLibrary> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _formulaController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _formulaController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formula Library'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Built-in"),
            Tab(text: "My Formulas"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBuiltInFormulas(),
          _buildUserFormulas(),
        ],
      ),
      floatingActionButton: _tabController.index == 1 
          ? FloatingActionButton(
              onPressed: _showAddFormulaDialog,
              backgroundColor: Colors.black,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBuiltInFormulas() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildFormulaCategory(
          "Algebra",
          Icons.functions,
          Colors.blue,
          [
            "--- Exponent & Radical Rules ---",
            "Product Rule: aᵐ · aⁿ = aᵐ⁺ⁿ",
            "Quotient Rule: aᵐ / aⁿ = aᵐ⁻ⁿ",
            "Power of a Power: (aᵐ)ⁿ = aᵐ·ⁿ",
            "Negative Exponent: a⁻ⁿ = 1/aⁿ",
            "Fractional Exponent: aᵐ/ⁿ = ⁿ√aᵐ",
            "--- Factoring & Expansion ---",
            "Difference of Squares: a² - b² = (a-b)(a+b)",
            "Perfect Square: (a ± b)² = a² ± 2ab + b²",
            "Sum of Cubes: a³ + b³ = (a+b)(a² - ab + b²)",
            "Difference of Cubes: a³ - b³ = (a-b)(a² + ab + b²)",
            "Perfect Cube: (a ± b)³ = a³ ± 3a²b + 3ab² ± b³",
            "--- Quadratic Equations ---",
            "Quadratic Formula: x = [-b ± √(b² - 4ac)] / 2a",
            "Discriminant: Δ = b² - 4ac",
            "Sum of Roots: x₁ + x₂ = -b/a",
            "Product of Roots: x₁ · x₂ = c/a",
            "--- Logarithms ---",
            "Product Rule: logᵦ(xy) = logᵦ(x) + logᵦ(y)",
            "Quotient Rule: logᵦ(x/y) = logᵦ(x) - logᵦ(y)",
            "Power Rule: logᵦ(xᵏ) = k · logᵦ(x)",
            "Change of Base: logᵦ(x) = log꜀(x) / log꜀(b)",
            "--- Sequences & Series ---",
            "Arithmetic Term: aₙ = a₁ + (n-1)d",
            "Arithmetic Sum: Sₙ = (n/2)(a₁ + aₙ)",
            "Geometric Term: aₙ = a₁ · rⁿ⁻¹",
            "Geometric Sum: Sₙ = a₁(1-rⁿ) / (1-r)",
            "Infinite Sum: S∞ = a₁ / (1-r)  (|r| < 1)",
          ],
        ),
        const SizedBox(height: 12),
        _buildFormulaCategory(
          "Geometry",
          Icons.architecture,
          Colors.green,
          [
            "--- 2D Area & Perimeter ---",
            "Triangle Area: A = ½ · base · height",
            "Heron's Formula: A = √[s(s-a)(s-b)(s-c)]",
            "Triangle Perimeter: P = a + b + c",
            "Rectangle: A = l · w | P = 2(l + w)",
            "Circle: A = πr² | C = 2πr",
            "Trapezoid Area: A = [(a+b)/2] · h",
            "--- 3D Volume & Surface Area ---",
            "Cube: V = s³ | SA = 6s²",
            "Rect. Prism: V = lwh | SA = 2(lw + lh + wh)",
            "Cylinder: V = πr²h | SA = 2πrh + 2πr²",
            "Cone Volume: V = ⅓πr²h",
            "Cone SA: SA = πrL + πr² (L = √[r²+h²])",
            "Sphere: V = 4/3πr³ | SA = 4πr²",
            "--- Coordinate Geometry ---",
            "Distance: d = √[(x₂-x₁)² + (y₂-y₁)²]",
            "Midpoint: M = ((x₁+x₂)/2, (y₁+y₂)/2)",
            "Slope (m): m = (y₂-y₁) / (x₂-x₁)",
            "Line Equation: y - y₁ = m(x - x₁)",
            "Circle Equation: (x-h)² + (y-k)² = r²",
          ],
        ),
        const SizedBox(height: 12),
        _buildFormulaCategory(
          "Trigonometry",
          Icons.change_history,
          Colors.orange,
          [
            "--- Right Triangle Ratios ---",
            "sinθ = Opp/Hyp | cosθ = Adj/Hyp | tanθ = Opp/Adj",
            "cscθ = 1/sinθ | secθ = 1/cosθ | cotθ = 1/tanθ",
            "--- Pythagorean Identities ---",
            "sin²θ + cos²θ = 1",
            "1 + tan²θ = sec²θ",
            "1 + cot²θ = csc²θ",
            "--- Sum & Difference Formulas ---",
            "sin(A ± B) = sinA cosB ± cosA sinB",
            "cos(A ± B) = cosA cosB ∓ sinA sinB",
            "tan(A ± B) = (tanA ± tanB) / (1 ∓ tanA tanB)",
            "--- Double & Half-Angle ---",
            "sin(2θ) = 2 sinθ cosθ",
            "cos(2θ) = cos²θ - sin²θ = 2cos²θ - 1 = 1 - 2sin²θ",
            "sin²θ = (1 - cos2θ) / 2",
            "cos²θ = (1 + cos2θ) / 2",
            "--- Non-Right Triangle Laws ---",
            "Law of Sines: a/sinA = b/sinB = c/sinC",
            "Law of Cosines: c² = a² + b² - 2ab cosC",
          ],
        ),
        const SizedBox(height: 12),
        _buildFormulaCategory(
          "Calculus",
          Icons.show_chart,
          Colors.red,
          [
            "--- Limits & Definitions ---",
            "Derivative: f'(x) = lim(h→0) [f(x+h) - f(x)] / h",
            "Special Limit: lim(x→0) sinx / x = 1",
            "--- Derivative Rules ---",
            "Power Rule: d/dx[xⁿ] = nxⁿ⁻¹",
            "Product Rule: (uv)' = u'v + uv'",
            "Quotient Rule: (u/v)' = (u'v - uv') / v²",
            "Chain Rule: [f(g(x))]' = f'(g(x)) · g'(x)",
            "Trig: sin'x = cosx | cos'x = -sinx | tan'x = sec²x",
            "Exp/Log: (eˣ)' = eˣ | (ln x)' = 1/x",
            "--- Integration Rules ---",
            "Power Rule: ∫ xⁿ dx = [xⁿ⁺¹ / (n+1)] + C",
            "Log Rule: ∫ (1/x) dx = ln|x| + C",
            "Exp Rule: ∫ eˣ dx = eˣ + C",
            "Trig: ∫ sinx dx = -cosx + C | ∫ cosx dx = sinx + C",
            "Integration by Parts: ∫ u dv = uv - ∫ v du",
            "--- Fundamental Theorem ---",
            "∫[a,b] f(x) dx = F(b) - F(a)",
          ],
        ),
        const SizedBox(height: 12),
        _buildFormulaCategory(
          "Vectors",
          Icons.trending_up,
          Colors.teal,
          [
            "Component Form: a = a₁i + a₂j + a₃k = <a₁, a₂, a₃>",
            "Angle Between: cosθ = (a · b) / (|a||b|)",
            "Orthogonal Condition: a · b = 0 ⇔ a ⊥ b",
            "Cross Product (Det): a × b = det[i j k; a₁ a₂ a₃; b₁ b₂ b₃]",
            "Magnitude Form: |a × b| = |a||b| sinθ",
            "Parallel Condition: a × b = 0 ⇔ a || b",
            "Scalar Triple Product: [a, b, c] = a · (b × c)",
            "Vector Triple Product: a × (b × c) = (a·c)b - (a·b)c",
          ],
        ),
        const SizedBox(height: 12),
        _buildFormulaCategory(
          "Matrices",
          Icons.grid_on,
          Colors.indigo,
          [
            "--- Operations & Properties ---",
            "Multiplication: cᵢⱼ = Σₖ aᵢₖ bₖⱼ",
            "Transpose Property: (AB)ᵀ = Bᵀ Aᵀ",
            "--- 2x2 Matrix (A = [a b; c d]) ---",
            "Determinant: det(A) = |A| = ad - bc",
            "Inverse: A⁻¹ = (1/|A|) [d -b; -c a]",
            "Inverse Identity: (AB)⁻¹ = B⁻¹ A⁻¹",
            "--- Systems & Eigenvalues ---",
            "Cramer's Rule: xᵢ = det(Aᵢ) / det(A)",
            "Eigenvalue Eq: det(A - λI) = 0",
          ],
        ),
        const SizedBox(height: 12),
        _buildFormulaCategory(
          "Inverse Trig",
          Icons.history,
          Colors.deepPurple,
          [
            "--- Principal Value Branches ---",
            "sin⁻¹(x) = θ ⇒ θ ∈ [-π/2, π/2]",
            "cos⁻¹(x) = θ ⇒ θ ∈ [0, π]",
            "tan⁻¹(x) = θ ⇒ θ ∈ (-π/2, π/2)",
            "--- Negative Arguments ---",
            "sin⁻¹(-x) = -sin⁻¹x | cos⁻¹(-x) = π - cos⁻¹x",
            "tan⁻¹(-x) = -tan⁻¹x",
            "--- Complementary Relations ---",
            "sin⁻¹x + cos⁻¹x = π/2",
            "tan⁻¹x + cot⁻¹x = π/2",
            "sec⁻¹x + csc⁻¹x = π/2",
            "--- Sum & Difference ---",
            "tan⁻¹x ± tan⁻¹y = tan⁻¹[(x ± y) / (1 ∓ xy)]",
            "sin⁻¹x ± sin⁻¹y = sin⁻¹[x√(1-y²) ± y√(1-x²)]",
            "--- Conversions & Multiples ---",
            "2tan⁻¹x = tan⁻¹[2x/(1-x²)] = sin⁻¹[2x/(1+x²)] = cos⁻¹[(1-x²)/(1+x²)]",
          ],
        ),
      ],
    );
  }

  Widget _buildUserFormulas() {
    return FutureBuilder<List<UserFormula>>(
      future: DatabaseService.getFormulas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 64, color: Colors.grey.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text("No custom formulas added yet.", 
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        final formulas = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: formulas.length,
          itemBuilder: (context, index) {
            final formula = formulas[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(formula.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(formula.category, style: const TextStyle(fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      onPressed: () => _viewFormulaDetails(formula),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showEditFormulaDialog(formula, index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteFormula(index),
                    ),
                  ],
                ),
                onTap: () => _viewFormulaDetails(formula),
              ),
            );
          },
        );
      },
    );
  }

  void _viewFormulaDetails(UserFormula formula) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormulaDetailScreen(formula: formula),
      ),
    );
  }

  void _showAddFormulaDialog() {
    _titleController.clear();
    _categoryController.clear();
    _formulaController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Custom Formula"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: _categoryController, decoration: const InputDecoration(labelText: "Category")),
              TextField(controller: _formulaController, decoration: const InputDecoration(labelText: "Formula")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isNotEmpty && _formulaController.text.isNotEmpty) {
                final newFormula = UserFormula(
                  id: DateTime.now().toString(),
                  title: _titleController.text,
                  category: _categoryController.text.isEmpty ? "General" : _categoryController.text,
                  formula: _formulaController.text,
                );
                await DatabaseService.addFormula(newFormula);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditFormulaDialog(UserFormula formula, int index) {
    _titleController.text = formula.title;
    _categoryController.text = formula.category;
    _formulaController.text = formula.formula;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Custom Formula"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: _categoryController, decoration: const InputDecoration(labelText: "Category")),
              TextField(controller: _formulaController, decoration: const InputDecoration(labelText: "Formula")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isNotEmpty && _formulaController.text.isNotEmpty) {
                final updatedFormula = UserFormula(
                  id: formula.id,
                  title: _titleController.text,
                  category: _categoryController.text.isEmpty ? "General" : _categoryController.text,
                  formula: _formulaController.text,
                );
                await DatabaseService.updateFormula(index, updatedFormula);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _deleteFormula(int index) async {
    await DatabaseService.deleteFormula(index);
    setState(() {});
  }

  Widget _buildFormulaCategory(String title, IconData icon, Color color, List<String> formulas) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
        children: formulas.map((f) => ListTile(
          title: Text(f, style: const TextStyle(fontSize: 15, fontFamily: 'monospace')),
          leading: const Icon(Icons.arrow_right, size: 20),
        )).toList(),
      ),
    );
  }
}

class FormulaDetailScreen extends StatelessWidget {
  final UserFormula formula;
  const FormulaDetailScreen({super.key, required this.formula});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formula.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Text(
                formula.category,
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Formula:",
              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                formula.formula,
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
