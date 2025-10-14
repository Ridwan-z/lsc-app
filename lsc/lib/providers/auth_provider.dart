import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? institution,
    String? major,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      institution: institution,
      major: major,
    );

    if (result['success'] == true) {
      _user = result['data']['user'];
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(email, password);

    if (result['success'] == true) {
      _user = result['data']['user'];
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();

    _user = null;
    _isAuthenticated = false;
    _isLoading = false;

    notifyListeners();
  }

  // Load user profile
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.getProfile();

    if (result['success'] == true) {
      _user = result['data'];
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Check if logged in
  Future<void> checkAuthStatus() async {
    _isAuthenticated = await _authService.isLoggedIn();
    if (_isAuthenticated) {
      await loadProfile();
    }
    notifyListeners();
  }
}
