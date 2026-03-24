
import 'package:flutter/material.dart';

class FilterElement extends ChangeNotifier{
  String _selectedColumn = 'CIP'; // Columna por defecto

  String get selectedColumn => _selectedColumn;

  void updateColumn(String column) {
    _selectedColumn = column;
    notifyListeners();
  }
}