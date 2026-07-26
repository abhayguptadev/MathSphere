import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/note.dart';
import 'models/calculation_history.dart';
import 'models/user_formula.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Register Adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CalculationHistoryAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(NoteAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(UserFormulaAdapter());
  }
  
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(MathSphereApp(initialDarkMode: isDarkMode));
}

class MathSphereApp extends StatefulWidget {
  final bool initialDarkMode;
  const MathSphereApp({super.key, required this.initialDarkMode});

  static State<MathSphereApp> of(BuildContext context) =>
      context.findAncestorStateOfType<_MathSphereAppState>()!;

  @override
  State<MathSphereApp> createState() => _MathSphereAppState();
}

class _MathSphereAppState extends State<MathSphereApp> {
  late bool _isDarkMode;

  bool get isDarkMode => _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  void toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathSphere',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
