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
      if (account == null) return null;
      
      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      print("Google SignIn Error: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

