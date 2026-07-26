import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../utils/database_service.dart';
import '../../models/calculation_history.dart';
import '../../utils/constants.dart';

class FinancialCalculator extends StatefulWidget {
  const FinancialCalculator({super.key});

  @override
  State<FinancialCalculator> createState() => _FinancialCalculatorState();
}

class _FinancialCalculatorState extends State<FinancialCalculator> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controllers
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _rController = TextEditingController();
  final TextEditingController _tController = TextEditingController();
  
  String _result = "";
  String _compoundingFrequency = "Annually";
  final List<String> _frequencies = ["Annually", "Semi-annually", "Quarterly", "Monthly"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pController.dispose();
    _rController.dispose();
    _tController.dispose();
    super.dispose();
  }

  void _calculateSimpleInterest() {
    double? P = double.tryParse(_pController.text);
    double? R = double.tryParse(_rController.text);
    double? T = double.tryParse(_tController.text);
    if (P == null || R == null || T == null) {
      _showError();
      return;
    }
    double si = (P * R * T) / 100;
    double total = P + si;
    setState(() => _result = "Simple Interest: ${si.toStringAsFixed(2)}\nTotal Amount: ${total.toStringAsFixed(2)}");
    _saveHistory("Simple Interest", "P:$P, R:$R, T:$T", "SI: ${si.toStringAsFixed(2)}");
  }

  void _calculateCompoundInterest() {
    double? P = double.tryParse(_pController.text);
    double? R = double.tryParse(_rController.text);
    double? T = double.tryParse(_tController.text);
    if (P == null || R == null || T == null) {
      _showError();
      return;
    }
    int n = _compoundingFrequency == "Monthly" ? 12 : _compoundingFrequency == "Quarterly" ? 4 : _compoundingFrequency == "Semi-annually" ? 2 : 1;
    double amount = P * math.pow((1 + (R / 100) / n), n * T);
    double ci = amount - P;
    setState(() => _result = "Compound Interest: ${ci.toStringAsFixed(2)}\nTotal Amount: ${amount.toStringAsFixed(2)}");
    _saveHistory("Compound Interest", "P:$P, R:$R, T:$T", "CI: ${ci.toStringAsFixed(2)}");
  }

  void _calculateEMI() {
    double? loan = double.tryParse(_pController.text);
    double? rate = double.tryParse(_rController.text);
    double? years = double.tryParse(_tController.text);
    if (loan == null || rate == null || years == null) {
      _showError();
      return;
    }
    double r = rate / (12 * 100);
    double n = years * 12;
    if (r == 0) {
      double emi = loan / n;
      setState(() => _result = "Monthly EMI: ${emi.toStringAsFixed(2)}\nTotal Interest: 0.00\nTotal Payment: ${loan.toStringAsFixed(2)}");
      return;
    }
    double emi = (loan * r * math.pow(1 + r, n)) / (math.pow(1 + r, n) - 1);
    double total = emi * n;
    setState(() => _result = "Monthly EMI: ${emi.toStringAsFixed(2)}\nTotal Interest: ${(total - loan).toStringAsFixed(2)}\nTotal Payment: ${total.toStringAsFixed(2)}");
    _saveHistory("EMI", "L:$loan, R:$rate, T:$years", "EMI: ${emi.toStringAsFixed(2)}");
  }

  void _calculateSIP() {
    double? monthly = double.tryParse(_pController.text);
    double? rate = double.tryParse(_rController.text);
    double? years = double.tryParse(_tController.text);
    if (monthly == null || rate == null || years == null) {
      _showError();
      return;
    }
    double i = rate / (12 * 100);
    double n = years * 12;
    if (i == 0) {
      double fv = monthly * n;
      setState(() => _result = "Future Value: ${fv.toStringAsFixed(2)}\nInvested: ${fv.toStringAsFixed(2)}\nReturns: 0.00");
      return;
    }
    double fv = monthly * ((math.pow(1 + i, n) - 1) / i) * (1 + i);
    setState(() => _result = "Future Value: ${fv.toStringAsFixed(2)}\nInvested: ${(monthly * n).toStringAsFixed(2)}\nReturns: ${(fv - monthly * n).toStringAsFixed(2)}");
    _saveHistory("SIP", "M:$monthly, R:$rate, T:$years", "FV: ${fv.toStringAsFixed(2)}");
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter valid numbers in all fields")));
  }

  void _calculateLoan() {
    // Basic Loan Payoff / Interest calculator
    _calculateEMI();
  }

  void _saveHistory(String type, String input, String result) {
    DatabaseService.addHistory(CalculationHistory(id: DateTime.now().toString(), expression: "Finance ($type): $input", result: result, dateTime: DateTime.now(), category: 'Financial'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Calculator'),
        backgroundColor: AppColors.financialColor,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Simple"),
            Tab(text: "Compound"),
            Tab(text: "EMI"),
            Tab(text: "SIP"),
            Tab(text: "Loan"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForm("Principal", "Rate (%)", "Time (Years)", _calculateSimpleInterest),
          _buildCompoundForm(),
          _buildForm("Loan Amount", "Rate (%)", "Tenure (Years)", _calculateEMI),
          _buildForm("Monthly SIP", "Exp. Return (%)", "Tenure (Years)", _calculateSIP),
          _buildForm("Loan Amount", "Interest Rate (%)", "Period (Years)", _calculateLoan),
        ],
      ),
    );
  }

  Widget _buildForm(String l1, String l2, String l3, VoidCallback onCalc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _inputCard(l1, l2, l3, onCalc),
          const SizedBox(height: 20),
          _resultCard(),
        ],
      ),
    );
  }

  Widget _buildCompoundForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _field(_pController, "Principal", Icons.money),
                  const SizedBox(height: 12),
                  _field(_rController, "Rate (%)", Icons.percent),
                  const SizedBox(height: 12),
                  _field(_tController, "Time (Years)", Icons.calendar_today),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _compoundingFrequency,
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Compounding"),
                    items: _frequencies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _compoundingFrequency = v!),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _calculateCompoundInterest,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.financialColor, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                    child: const Text("Calculate"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _resultCard(),
        ],
      ),
    );
  }

  Widget _inputCard(String l1, String l2, String l3, VoidCallback onCalc) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _field(_pController, l1, Icons.money),
            const SizedBox(height: 12),
            _field(_rController, l2, Icons.percent),
            const SizedBox(height: 12),
            _field(_tController, l3, Icons.calendar_today),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onCalc,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.financialColor, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
              child: const Text("Calculate"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String l, IconData i) {
    return TextField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l, prefixIcon: Icon(i, color: AppColors.financialColor), border: const OutlineInputBorder()));
  }

  Widget _resultCard() {
    if (_result.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.financialColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.financialColor.withValues(alpha: 0.3))),
      child: Text(_result, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.6, color: AppColors.financialColor.withValues(alpha: 0.8))),
    );
  }
}
