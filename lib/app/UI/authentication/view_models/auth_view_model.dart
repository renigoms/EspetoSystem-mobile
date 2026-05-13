import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLogin = true;

  bool _showPasswordField = false;

  bool _passwordRecoverySuccess = true;

  bool _hasMinLength = true;
  bool _hasUpperCase = true;
  bool _hasNumberCase = true;
  bool _hasSpecialCase = true;

  bool get isLogin => _isLogin;

  bool get showPasswordField => _showPasswordField;

  bool get passwordRecoverySuccess => _passwordRecoverySuccess;

  bool get hasMinLength => _hasMinLength;
  bool get hasUpperCase => _hasUpperCase;
  bool get hasNumberCase => _hasNumberCase;
  bool get hasSpecialCase => _hasSpecialCase;

  bool get passwordFailVerify =>
      !_hasMinLength || !_hasNumberCase || !_hasUpperCase || !_hasSpecialCase;

  void setIsLogin(bool value) {
    _isLogin = _isLogin != value ? !_isLogin : _isLogin;
    notifyListeners();
  }

  void setShowPasswordField() {
    _showPasswordField = true;
    notifyListeners();
  }

  void setPassRecoverySucc() {
    _passwordRecoverySuccess = !_passwordRecoverySuccess;
    notifyListeners();
  }

  void setHasMinLength(String value) {
    _hasMinLength = value.length >= 8;
    notifyListeners();
  }

  void setHasUpperCase(String value) {
    _hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
    notifyListeners();
  }

  void setHasNumberCase(String value) {
    _hasNumberCase = RegExp(r'[0-9]').hasMatch(value);
    notifyListeners();
  }

  void setHasSpecialCase(String value) {
    _hasSpecialCase = RegExp(
      r'[!@#\$%^&*(),.?{}|<>_\-\[\]\/;~+=]',
    ).hasMatch(value);
    notifyListeners();
  }

  Object handleLoginButtonPressed(String email, String password) {
    if (showPasswordField) {
      if (password.isEmpty) {
        return "Todos os campos devem ser preenchidos !";
      }

      return "Login realizado com sucesso seguir para home";
    }
    if (email.isNotEmpty) {
      setShowPasswordField();
      return true;
    }
    return "Todos os campos devem ser preenchidos !";
  }
}
