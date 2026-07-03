import 'package:google_sign_in/google_sign_in.dart';

import '../constants/api_constants.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: ApiConstants.googleWebClientId,
    scopes: ['email', 'profile'],
  );

  static Future<void> init() async {
    // Initialization handled by the constructor
  }

  static Future<String?> signInAndGetIdToken() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        print("Google SignIn: User cancelled");
        return null;
      }

      print("Google SignIn: Account = ${account.email}");
      final auth = await account.authentication;
      print("Google SignIn: idToken = ${auth.idToken != null ? 'OK' : 'NULL'}");
      return auth.idToken;
    } catch (e) {
      print("Google SignIn Error: $e");
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

