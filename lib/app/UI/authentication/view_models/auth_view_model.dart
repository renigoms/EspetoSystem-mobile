import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (email.isNotEmpty) {
      setShowPasswordField();
      if (password.isEmpty) {
        return "Todos os campos devem ser preenchidos !";
      }
      return true;
    }
    return "Todos os campos devem ser preenchidos !";
  }

  final supabase = Supabase.instance.client;

  Future<String> continueWithGoogleAction() async {
    try {
      // O serverClientId DEVE ser o Web Client ID para que o Supabase aceite o token
      const webClientId =
          '823631587645-ed0pe3ukr3qrga348d40spjjidi8s7lp.apps.googleusercontent.com';

      GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(serverClientId: webClientId);

      final GoogleSignInAccount googleUser = await signIn.authenticate();

      final String? idToken = googleUser.authentication.idToken;

      final authorization =
          await googleUser.authorizationClient.authorizationForScopes([
            'email',
            'profile',
          ]) ??
          await googleUser.authorizationClient.authorizeScopes([
            'email',
            'profile',
          ]);

      final String accessToken = authorization.accessToken;

      if (idToken == null) {
        return 'ID Token não encontrado. Verifique as configurações no Google Cloud Console.';
      }

      final result = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (result.user != null && result.session != null) {
        return "Deu certo !! ${result.user?.id}";
      }
      return "Erro ao sincronizar com o servidor";
    } catch (e) {
      print(e);
      return "Erro ao fazer login com Google: $e";
    }
  }
}
