import 'package:flutter/material.dart';

class IndexScreenProvider extends ChangeNotifier{
  int _indexClicked = 0;

  int get getIndexClicked => _indexClicked;

  void updateIndexClicked(int index){
    _indexClicked = index;
    notifyListeners();
  }
}