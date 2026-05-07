import 'package:flutter/material.dart';

class LoginModelViel extends ChangeNotifier {
  bool _isLogin = true;

  bool get isLogin => _isLogin;

  void setIsLogin(bool value) {
    _isLogin = _isLogin != value ? !_isLogin : _isLogin;
    notifyListeners();
  }
}
