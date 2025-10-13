import 'package:flutter/foundation.dart';

class NavigationProvider extends ChangeNotifier {
  String _currentScreen = 'home';
  Map<String, dynamic> _navigationData = {};

  String get currentScreen => _currentScreen;
  Map<String, dynamic> get navigationData => _navigationData;

  void setCurrentScreen(String screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void setNavigationData(Map<String, dynamic> data) {
    _navigationData = data;
    notifyListeners();
  }

  void clearNavigationData() {
    _navigationData.clear();
    notifyListeners();
  }
}
