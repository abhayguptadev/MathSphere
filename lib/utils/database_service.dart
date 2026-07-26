import 'package:hive_flutter/hive_flutter.dart';
import '../models/calculation_history.dart';
import '../models/note.dart';
import '../models/user_formula.dart';

class DatabaseService {
  static const String historyBoxName = 'history_box';
  static const String notesBoxName = 'notes_box';
  static const String formulasBoxName = 'formulas_box';

  static Future<List<CalculationHistory>> getHistory() async {
    final box = await Hive.openBox<CalculationHistory>(historyBoxName);
    return box.values.toList().reversed.toList();
  }

  static Future<void> addHistory(CalculationHistory record) async {
    final box = await Hive.openBox<CalculationHistory>(historyBoxName);
    await box.add(record);
  }

  static Future<void> deleteHistory(int index) async {
    final box = await Hive.openBox<CalculationHistory>(historyBoxName);
    // index is from the reversed list, so we need the original index
    int originalIndex = box.length - 1 - index;
    await box.deleteAt(originalIndex);
  }

  static Future<void> clearHistory() async {
    final box = await Hive.openBox<CalculationHistory>(historyBoxName);
    await box.clear();
  }

  static Future<List<Note>> getNotes() async {
    final box = await Hive.openBox<Note>(notesBoxName);
    return box.values.toList().reversed.toList();
  }

  static Future<void> addNote(Note note) async {
    final box = await Hive.openBox<Note>(notesBoxName);
    await box.add(note);
  }

  static Future<void> deleteNote(int index) async {
    final box = await Hive.openBox<Note>(notesBoxName);
    int originalIndex = box.length - 1 - index;
    await box.deleteAt(originalIndex);
  }

  static Future<List<UserFormula>> getFormulas() async {
    final box = await Hive.openBox<UserFormula>(formulasBoxName);
    return box.values.toList().reversed.toList();
  }

  static Future<void> addFormula(UserFormula formula) async {
    final box = await Hive.openBox<UserFormula>(formulasBoxName);
    await box.add(formula);
  }

  static Future<void> deleteFormula(int index) async {
    final box = await Hive.openBox<UserFormula>(formulasBoxName);
    int originalIndex = box.length - 1 - index;
    await box.deleteAt(originalIndex);
  }

  static Future<void> updateFormula(int index, UserFormula formula) async {
    final box = await Hive.openBox<UserFormula>(formulasBoxName);
    int originalIndex = box.length - 1 - index;
    await box.putAt(originalIndex, formula);
  }
}
