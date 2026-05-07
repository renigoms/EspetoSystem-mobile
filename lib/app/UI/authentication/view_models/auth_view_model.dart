import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLogin = true;

  bool _showPasswordField = false;

  bool get isLogin => _isLogin;

  bool get showPasswordField => _showPasswordField;

  void setIsLogin(bool value) {
    _isLogin = _isLogin != value ? !_isLogin : _isLogin;
    notifyListeners();
  }

  void setShowPasswordField() {
    _showPasswordField = true;
    notifyListeners();
  }
}
