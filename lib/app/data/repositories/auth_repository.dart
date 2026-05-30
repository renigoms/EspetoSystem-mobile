import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_profile_model.dart';

class AuthRepository {
  final SupabaseClient supabaseClient;
  final GoogleSignIn googleSignIn;

  AuthRepository({
    required this.supabaseClient,
    required this.googleSignIn,
  });

  Future<AuthResponse> signInWithGoogle() async {
    final googleUser = await googleSignIn.authenticate();
    if (googleUser == null) throw 'Login cancelado pelo usuário';

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    
    // Obter o accessToken via authorizationClient (novo na versão 7.2.0+)
    final authorization = await googleUser.authorizationClient.authorizeScopes([
      'email',
      'profile',
      'openid',
    ]);
    final accessToken = authorization.accessToken;

    if (idToken == null) throw 'ID Token não encontrado';

    return await supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(String email, String password, String name) async {
    final response = await supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
    return response;
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await supabaseClient.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await supabaseClient.auth.resetPasswordForEmail(
      email,
      redirectTo: 'espetosystem://recuperar-senha',
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await supabaseClient.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<AuthProfileModel?> getProfile(String userId) async {
    final data = await supabaseClient
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return AuthProfileModel.fromJson(data);
  }
}
