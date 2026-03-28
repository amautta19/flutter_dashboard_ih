import 'package:flutter/material.dart';

class FilterDayProvider extends ChangeNotifier {
  // Inicializamos con el día de hoy o una fecha por defecto
  DateTime _selectedDate = DateTime.now();

  DateTime get getDate => _selectedDate;

  void updateDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }
}