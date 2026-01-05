import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:neurorga/models/user.dart' as models;
import 'package:neurorga/services/backend_config.dart';

class AuthService {
  // Lazily access plugin instances to avoid triggering initialization when backend is disabled
  firebase_auth.FirebaseAuth get _auth => firebase_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<firebase_auth.User?> get authStateChanges {
    if (!BackendConfig.backendEnabled) {
      return Stream<firebase_auth.User?>.value(null);
    }
    return _auth.authStateChanges();
  }

  firebase_auth.User? get currentUser {
    if (!BackendConfig.backendEnabled) return null;
    return _auth.currentUser;
  }

  Future<firebase_auth.User?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (!BackendConfig.backendEnabled) {
        throw Exception('Backend disabled: Enable Firebase in Dreamflow panel to sign up.');
      }
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        final user = models.User(
          id: credential.user!.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(credential.user!.uid).set(user.toJson());
      }
      
      return credential.user;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  Future<firebase_auth.User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (!BackendConfig.backendEnabled) {
        throw Exception('Backend disabled: Enable Firebase in Dreamflow panel to sign in.');
      }
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      if (!BackendConfig.backendEnabled) return;
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (!BackendConfig.backendEnabled) {
        throw Exception('Backend disabled: Enable Firebase in Dreamflow panel to reset password.');
      }
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password reset error: $e');
      rethrow;
    }
  }

  Future<models.User?> getUserData(String uid) async {
    try {
      if (!BackendConfig.backendEnabled) return null;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return models.User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Get user data error: $e');
      return null;
    }
  }
}
