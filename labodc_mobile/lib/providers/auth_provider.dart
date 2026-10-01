import 'package:flutter/material.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';
import 'package:labodc_mobile/models/auth_model.dart';
import 'package:labodc_mobile/services/auth_service.dart';

/// Auth Provider for managing authentication state
class AuthProvider with ChangeNotifier {
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  AuthData? _currentAuthData;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  AuthData? get currentAuthData => _currentAuthData;
  String? get error => _error;
  UserRole? get userRole {
    if (_currentAuthData == null) return null;
    return UserRole.fromString(_currentAuthData!.role);
  }

  /// Initialize auth state
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await _authService.isLoggedIn();
      if (_isAuthenticated) {
        final userData = _authService.getCurrentUser();
        if (userData != null) {
          _currentAuthData = AuthData.fromJson(userData);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      if (response.success && response.data != null) {
        _isAuthenticated = true;
        _currentAuthData = response.data!;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Đăng nhập thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register
  Future<bool> register(RegisterRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(request);

      _isLoading = false;
      if (response.success) {
        notifyListeners();
        return true;
      } else {
        final failureMessage = response.message.trim();
        _error = failureMessage.isEmpty ? 'Đăng ký thất bại' : failureMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Forgot password (request reset email/OTP)
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.forgotPassword(email);
      _isLoading = false;

      if (response.success) {
        notifyListeners();
        return true;
      } else {
        final failureMessage = response.message?.trim() ?? '';
        _error = failureMessage.isEmpty
            ? 'Gửi yêu cầu đặt lại mật khẩu thất bại'
            : failureMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset password (using token/otp provided by backend)
  Future<bool> resetPassword({
    required String token,
    required String otp,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(
        token: token,
        otp: otp,
        newPassword: newPassword,
      );

      _isLoading = false;
      if (response.success) {
        notifyListeners();
        return true;
      } else {
        final failureMessage = response.message?.trim() ?? '';
        _error = failureMessage.isEmpty
            ? 'Đặt lại mật khẩu thất bại'
            : failureMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _isAuthenticated = false;
      _currentAuthData = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
