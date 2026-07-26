import 'package:hive/hive.dart';

part 'user_formula.g.dart';

@HiveType(typeId: 2)
class UserFormula {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String category;
  @HiveField(3)
  final String formula;

  UserFormula({
    required this.id,
    required this.title,
    required this.category,
    required this.formula,
  });
}
