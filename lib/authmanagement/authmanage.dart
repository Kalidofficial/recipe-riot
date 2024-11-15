import 'package:firebase_auth/firebase_auth.dart';

class Authmanage {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        return 'Please verify your email address.';
      }

      return 'Sign in successful';
    } catch (e) {
      return 'Note: ${e.toString()}';
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      }
      return 'Registration successful. Please verify your email address.';
    } catch (e) {
      return 'Note: ${e.toString()}';
    }
  }
}
