import 'package:flutter/material.dart';

class CalculatorCategory {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;
  bool isFavorite;

  CalculatorCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.screen,
    this.isFavorite = false,
  });
}
