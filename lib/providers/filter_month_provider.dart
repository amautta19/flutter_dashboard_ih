import 'package:flutter/material.dart';

class FilterMonthProvider extends ChangeNotifier{
  String _month = '';
  
  String get getMonth => _month;

  void updateMonth(String month){
    _month = month;
    notifyListeners();
  }
}