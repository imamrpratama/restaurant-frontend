import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiService.post(
        '/register',
        {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        includeAuth: false);

    return _apiService.handleResponse(response);
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
        '/login',
        {
          'email': email,
          'password': password,
        },
        includeAuth: false);

    final data = _apiService.handleResponse(response);

    // Check if 2FA is required
    if (data['requires_2fa'] == true) {
      return data;
    }

    // Save token and user
    await _storageService.saveToken(data['token']);
    await _storageService.saveUser(data['user']);

    return data;
  }

  // Verify 2FA
  Future<Map<String, dynamic>> verify2FA({
    required int userId,
    required String code,
  }) async {
    final response = await _apiService.post(
        '/verify-2fa',
        {
          'user_id': userId,
          'code': code,
        },
        includeAuth: false);

    final data = _apiService.handleResponse(response);

    await _storageService.saveToken(data['token']);
    await _storageService.saveUser(data['user']);

    return data;
  }

  // Google Sign-In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign-In cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await _apiService.post(
          '/google-signin',
          {
            'id_token': googleAuth.idToken,
          },
          includeAuth: false);

      final data = _apiService.handleResponse(response);

      // Check if 2FA is required
      if (data['requires_2fa'] == true) {
        return data;
      }

      await _storageService.saveToken(data['token']);
      await _storageService.saveUser(data['user']);

      return data;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Enable 2FA
  Future<Map<String, dynamic>> enable2FA() async {
    final response = await _apiService.post('/2fa/enable', {});
    return _apiService.handleResponse(response);
  }

  // Confirm 2FA
  Future<Map<String, dynamic>> confirm2FA(String code) async {
    final response = await _apiService.post('/2fa/confirm', {'code': code});
    return _apiService.handleResponse(response);
  }

  // Disable 2FA
  Future<Map<String, dynamic>> disable2FA() async {
    final response = await _apiService.post('/2fa/disable', {});
    return _apiService.handleResponse(response);
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post('/logout', {});
    } catch (e) {
      // Continue with local logout even if API fails
    }

    await _googleSignIn.signOut();
    await _storageService.clearAll();
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/me');
      final data = _apiService.handleResponse(response);
      return User.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Check if authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getToken();
    return token != null;
  }
}
