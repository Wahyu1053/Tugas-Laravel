import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);

      if (result['success']) {
        await _apiService.saveToken(result['data']['access_token']);
        _user = User.fromJson(result['data']['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String name, String email, String password, String passwordConfirmation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.register(name, email, password, passwordConfirmation);

      if (result['success']) {
        await _apiService.saveToken(result['data']['access_token']);
        _user = User.fromJson(result['data']['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Display detailed validation errors
        if (result['errors'] != null) {
          final errors = result['errors'] as Map<String, dynamic>;
          final errorMessages = errors.values.map((e) => e.toString()).join('\n');
          _error = errorMessages;
        } else {
          _error = result['message'] ?? 'Registration failed';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    await _apiService.removeToken();
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final token = await _apiService.getToken();
    if (token != null) {
      _user = await _apiService.getUser();
      notifyListeners();
    }
  }
}
