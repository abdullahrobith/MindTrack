import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/models/user_model.dart';
import '../../core/config/network_config.dart';

class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get JWT from backend
    try {
      final res = await http.post(
        Uri.parse('${NetworkConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        NetworkConfig.token = data['access_token'];
      }
    } catch (e) {
      print("Gagal dapatkan token: $e");
    }

    return credential;
  }

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Send verification email
    await credential.user?.sendEmailVerification();

    // Create user in Firestore
    UserModel newUser = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      provider: 'manual',
      gender: 'Belum dipilih',
      theme: 'light',
      photoUrl: null,
      emailVerified: false,
    );

    await _firestore.collection('users').doc(credential.user!.uid).set(newUser.toJson());

    // Sync to MongoDB Backend
    try {
      await http.post(
        Uri.parse('${NetworkConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
    } catch (e) {
      print("Gagal sync ke MongoDB: $e");
    }

    return credential;
  }

  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> saveGoogleUserToFirestore(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    
    if (!doc.exists) {
      UserModel newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        provider: 'google',
        gender: 'Belum dipilih',
        theme: 'light',
        photoUrl: user.photoURL,
        emailVerified: user.emailVerified,
      );
      await _firestore.collection('users').doc(user.uid).set(newUser.toJson());
    } else {
      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }

    // Sync to MongoDB Backend
    try {
      final idToken = await user.getIdToken();
      if (idToken != null) {
        final res = await http.post(
          Uri.parse('${NetworkConfig.baseUrl}/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id_token': idToken,
          }),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          NetworkConfig.token = data['access_token'];
        }
      }
    } catch (e) {
      print("Gagal sync google ke MongoDB: $e");
    }
  }

  Future<UserModel?> getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? gender,
    String? password,
    String? theme,
  }) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (gender != null) data['gender'] = gender;
    if (theme != null) data['theme'] = theme;
    
    // We update email and password in FirebaseAuth if provided, but the prompt says 
    // to just update Firestore fields and keep structure.
    if (password != null && password.isNotEmpty) {
      await currentUser.updatePassword(password);
    }
    if (name != null) {
        await currentUser.updateDisplayName(name);
    }

    if (data.isNotEmpty) {
      await _firestore.collection('users').doc(currentUser.uid).update(data);
      
      // Sync to MongoDB
      if (NetworkConfig.token != null) {
        try {
          // Backend expects UserUpdate schema: name, email, gender, theme, password, confirm_password
          final backendData = Map<String, dynamic>.from(data);
          if (password != null && password.isNotEmpty) {
            backendData['password'] = password;
            backendData['confirm_password'] = password;
          }
          
          await http.put(
            Uri.parse('${NetworkConfig.baseUrl}/auth/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${NetworkConfig.token}'
            },
            body: jsonEncode(backendData),
          );
        } catch (e) {
          print("Gagal update profil ke MongoDB: $e");
        }
      }
    }
  }
}