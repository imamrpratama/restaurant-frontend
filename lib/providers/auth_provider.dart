import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/google_config.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  late final GoogleSignIn _googleSignIn;

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _requires2FA = false;
  String? _tempToken;

  AuthProvider() {
    // Initialize Google Sign-In
    _googleSignIn = GoogleSignIn(
      serverClientId: GoogleConfig.webClientId,
      scopes: GoogleConfig.scopes,
    );
  }

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get requires2FA => _requires2FA;

  // Check if user is already logged in
  Future<void> checkAuth() async {
    final token = await _storageService.getToken();
    if (token != null) {
      try {
        final response = await _apiService.get('/me');
        if (response.statusCode == 200) {
          _user = User.fromJson(jsonDecode(response.body));
          _isAuthenticated = true;
        } else {
          await _storageService.deleteToken();
          _isAuthenticated = false;
        }
      } catch (e) {
        await _storageService.deleteToken();
        _isAuthenticated = false;
      }
    }
    notifyListeners();
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data['user']);
        await _storageService.saveToken(data['token']);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/login', {
        'email': email,
        'password': password,
      });

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if 2FA is required
        if (data['requires_2fa'] == true) {
          _requires2FA = true;
          _tempToken = data['temp_token'];
          await _storageService.saveToken(_tempToken!);
          _isLoading = false;
          notifyListeners();
          return true;
        }

        // No 2FA required
        _user = User.fromJson(data['user']);
        await _storageService.saveToken(data['token']);
        _isAuthenticated = true;
        _requires2FA = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Google Sign-In - Option 1: Link to existing account
  Future<bool> googleLogin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Starting Google Sign-In...');

      // Sign in with Google
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _errorMessage = 'Google Sign-In cancelled by user';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('Google user signed in: ${googleUser.email}');

      // Get the ID token
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        _errorMessage =
            'Failed to get Google ID token. Please ensure Google Sign-In is properly configured.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('ID Token obtained, sending to backend...');

      // Send ID token to backend
      final response = await _apiService.post('/google-login', {
        'id_token': idToken,
      });

      print('Google login response status: ${response.statusCode}');
      print('Google login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if 2FA is required
        if (data['requires_2fa'] == true) {
          _requires2FA = true;
          _tempToken = data['temp_token'];
          await _storageService.saveToken(_tempToken!);
          _isLoading = false;
          notifyListeners();
          return true;
        }

        // No 2FA required - login successful
        _user = User.fromJson(data['user']);
        await _storageService.saveToken(data['token']);
        _isAuthenticated = true;
        _requires2FA = false;
        _isLoading = false;
        notifyListeners();

        print('Google login successful for ${_user?.email}');
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Google login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Google login error: $e');

      String errorMessage = 'Google login error';

      // Parse platform exceptions for better error messages
      if (e.toString().contains('ApiException')) {
        errorMessage = 'Google Play Services error. Please ensure:\n'
            '1. Running on Windows/Web for testing\n'
            '2. Google Client ID is configured\n'
            '3. Internet connection is available';
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage = 'Google Sign-In failed. Please check:\n'
            '1. Android SHA-1 fingerprint matches Google Console\n'
            '2. Google Play Services is installed\n'
            '3. Server Client ID is configured';
      } else if (e.toString().contains('NETWORK')) {
        errorMessage = 'Network error. Check your internet connection.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      _errorMessage = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Google Sign-Out
  Future<void> googleSignOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  // Verify 2FA OTP - IMPROVED ERROR HANDLING
  Future<bool> verify2FA(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Verifying 2FA with OTP: $otp');

      final response = await _apiService.post('/verify-2fa', {
        'otp': otp,
      });

      print('Verify 2FA response status: ${response.statusCode}');
      print('Verify 2FA response body: ${response.body}');

      // Check if response is JSON
      if (response.headers['content-type']?.contains('application/json') !=
          true) {
        print('Response is not JSON! ');
        print('Content-Type: ${response.headers['content-type']}');
        _errorMessage = 'Server error: Invalid response format';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          _user = User.fromJson(data['user']);
          await _storageService.saveToken(data['token']);
          _isAuthenticated = true;
          _requires2FA = false;
          _tempToken = null;
          _isLoading = false;
          notifyListeners();
          return true;
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
          _errorMessage = 'Failed to parse server response';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Invalid OTP code';
        _isLoading = false;
        notifyListeners();
        return false;
      } else if (response.statusCode == 401) {
        _errorMessage = 'Session expired. Please login again.';
        await logout();
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? '2FA verification failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Verify 2FA error: $e');
      _errorMessage =
          'Connection error: ${e.toString().replaceAll('Exception: ', '')}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify Recovery Code
  Future<bool> verifyRecoveryCode(String recoveryCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/verify-recovery-code', {
        'recovery_code': recoveryCode,
      });

      print('Recovery code response status: ${response.statusCode}');
      print('Recovery code response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data['user']);
        await _storageService.saveToken(data['token']);
        _isAuthenticated = true;
        _requires2FA = false;
        _tempToken = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage =
            errorData['message'] ?? 'Recovery code verification failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Enable 2FA
  Future<Map<String, dynamic>?> enable2FA() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/2fa/enable', {});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _isLoading = false;
        notifyListeners();
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to enable 2FA';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Confirm 2FA
  Future<bool> confirm2FA(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/2fa/confirm', {
        'otp': otp,
      });

      if (response.statusCode == 200) {
        // Refresh user data
        await checkAuth();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to confirm 2FA';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Disable 2FA
  Future<bool> disable2FA({
    required String password,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/2fa/disable', {
        'password': password,
        'otp': otp,
      });

      if (response.statusCode == 200) {
        // Refresh user data
        await checkAuth();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to disable 2FA';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _errorMessage = 'Google Sign-In not implemented yet';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if email exists and get available login methods
  Future<Map<String, dynamic>> checkEmailExists(String email) async {
    try {
      final response = await _apiService.post('/check-email', {
        'email': email,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'exists': false};
    } catch (e) {
      print('Error checking email: $e');
      return {'exists': false};
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post('/logout', {});
      // Also sign out from Google if signed in
      await googleSignOut();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _storageService.deleteToken();
      _user = null;
      _isAuthenticated = false;
      _requires2FA = false;
      _tempToken = null;
      notifyListeners();
    }
  }
}
