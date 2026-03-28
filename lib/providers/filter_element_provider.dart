
import 'package:flutter/material.dart';

class FilterElementProvider extends ChangeNotifier{
  String _element = 'CIP'; // Columna por defecto

  String get getElement => _element;

  void updateColumn(String column) {
    _element = column;
    notifyListeners();
  }
}