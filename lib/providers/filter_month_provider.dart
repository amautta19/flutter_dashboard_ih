import 'package:flutter/material.dart';

class FilterMonthProvider extends ChangeNotifier {
  int _selectedMonth = DateTime.now().month; // Obtenemos el mes actual

  int get getMonth => _selectedMonth;

  void updateMonth(int newMonth) {
    _selectedMonth = newMonth;
    notifyListeners(); // Esto activa el redibujado de la UI
  }
}