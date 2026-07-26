import 'package:hive/hive.dart';

part 'calculation_history.g.dart';

@HiveType(typeId: 0)
class CalculationHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String expression;

  @HiveField(3)
  final String result;

  @HiveField(4)
  final DateTime dateTime;

  @HiveField(5)
  final String category;

  CalculationHistory({
    required this.id,
    this.title = 'Untitled',
    required this.expression,
    required this.result,
    required this.dateTime,
    required this.category,
  });
}
