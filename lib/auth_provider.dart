import 'package:flutter/material.dart';
import 'user.dart';
class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  User? _currentUser; // This will now hold the User object

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;

  void login(String email) {
    _currentUser = User(email: email); // Set the current user email
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _currentUser = null; // Clear user information on logout
    _isAuthenticated = false;
    notifyListeners();
  }
}
