import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:espetosystem/app/data/models/auth_profile_model.dart';
import 'package:espetosystem/app/data/services/base_data_source.dart';

class AuthRepository {
  final SupabaseClient supabaseClient;
  final GoogleSignIn googleSignIn;
  final IBaseLocalDataSource localCache;

  AuthRepository({
    required this.supabaseClient,
    required this.googleSignIn,
    required this.localCache,
  });

  Future<AuthResponse> signInWithGoogle() async {
    final googleUser = await googleSignIn.authenticate(); 
    if (googleUser == null) throw 'Login cancelado pelo usuário';

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    // Obter o accessToken via authorizationClient (específico do setup do usuário)
    final authorization = await googleUser.authorizationClient.authorizeScopes([
      'email',
      'profile',
      'openid',
    ]);
    final accessToken = authorization.accessToken;

    if (idToken == null) throw 'ID Token não encontrado';

    final response = await supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    if (response.user != null) {
      await _syncProfile(response.user!);
    }
    return response;
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    final response = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      await _syncProfile(response.user!);
    }
    return response;
  }

  Future<AuthResponse> signUpWithEmail(String email, String password, String name) async {
    final response = await supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
    if (response.user != null) {
      await _syncProfile(response.user!);
    }
    return response;
  }

  Future<void> _syncProfile(User user) async {
    // Ensure profile exists in Supabase 'profiles' table
    final profileData = {
      'id': user.id,
      'login': user.email,
      'role': 'user',
    };
    
    await supabaseClient.from('profile').upsert(profileData);
    
    // Cache profile locally
    await localCache.save('user_profile', profileData);
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await supabaseClient.auth.signOut();
    await localCache.clear(); // Clear cache on logout
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
        .from('profile')
        .select()
        .eq('id', userId)
        .single();
    return AuthProfileModel.fromJson(data);
  }
}
