import 'package:flutter/material.dart';

class VersionAppProvider with ChangeNotifier{
  String _versionApp = '';

  String get getVersionApp => _versionApp;

  void updateVersionApp(String versionApp){
    _versionApp = versionApp;
    notifyListeners();
  }
}