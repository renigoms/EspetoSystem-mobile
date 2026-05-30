import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository? _authRepository;
  void Function(String)? onPasswordRecovery;

  AuthViewModel({AuthRepository? authRepository}) : _authRepository = authRepository {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authRepository?.supabaseClient.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        onPasswordRecovery?.call('/update-password');
      }
      
      // Notifica o app quando o login ou logout acontece para o GoRouter reavaliar o redirect
      if (data.event == AuthChangeEvent.signedIn || data.event == AuthChangeEvent.signedOut) {
        notifyListeners();
      }
    });
  }

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
    if (email.isNotEmpty) {
      setShowPasswordField();
      if (password.isEmpty) {
        return "Todos os campos devem ser preenchidos !";
      }
      return true;
    }
    return "Todos os campos devem ser preenchidos !";
  }

  Future<String> loginWithEmail(String email, String password) async {
    if (_authRepository == null) return "Erro de configuração";
    try {
      final result = await _authRepository!.signInWithEmail(email, password);
      if (result.user != null) {
        return "true";
      }
      return "Erro ao fazer login";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> registerWithEmail(String email, String password, String name) async {
    if (_authRepository == null) return "Erro de configuração";
    try {
      final result = await _authRepository!.signUpWithEmail(email, password, name);
      if (result.user != null) {
        return "true";
      }
      return "Erro ao cadastrar";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> continueWithGoogleAction() async {
    if (_authRepository == null) return "Erro de configuração: Repositório não inicializado";
    try {
      final result = await _authRepository!.signInWithGoogle();

      if (result.user != null) {
        return "Sucesso: Bem-vindo ${result.user?.email}";
      }
      return "Erro ao sincronizar com o servidor";
    } catch (e) {
      return "Erro ao fazer login com Google: $e";
    }
  }

  Future<String> recoverPassword(String email) async {
    if (_authRepository == null) return "Erro de configuração do servidor.";
    try {
      await _authRepository!.resetPassword(email);
      setPassRecoverySucc();
      return "true";
    } on AuthException catch (e) {
      return e.message; // Retorna a mensagem de erro do Supabase (ex: "User not found")
    } catch (e) {
      return "Ocorreu um erro inesperado: $e";
    }
  }

  Future<String> updatePassword(String newPassword) async {
    if (_authRepository == null) return "Erro de configuração do servidor.";
    try {
      await _authRepository!.updatePassword(newPassword);
      return "true";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Erro ao atualizar senha: $e";
    }
  }
}
