import 'dart:convert';
import 'dart:developer' as developer;
// ignore: unused_import
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AuthNotifier(apiService);
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;
  final bool isFirstTime;
  final bool justRegistered;

  AuthState({
    this.isLoading = true,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isFirstTime = true,
    this.justRegistered = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
    bool? isFirstTime,
    bool? justRegistered,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      justRegistered: justRegistered ?? this.justRegistered,
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // isLoading starts true; set it false when done so SplashScreen knows
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('is_first_time') ?? true;
    final userJson = prefs.getString('user_data');

    if (userJson != null) {
      final user = User.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        isFirstTime: isFirstTime,
      );
    } else {
      state = state.copyWith(isLoading: false, isFirstTime: isFirstTime);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        // Supabase can return 200 with an error key if credentials are wrong
        final responseData = response.data;
        if (responseData['error'] != null) {
          state = state.copyWith(
            isLoading: false,
            error: responseData['error'].toString(),
          );
          return;
        }
        final data = responseData['data']['user'];
        if (data == null) {
          state = state.copyWith(
            isLoading: false,
            error: 'Invalid credentials. Please check your email and password.',
          );
          return;
        }
        final user = User(
          id: data['id'],
          name: data['user_metadata']['full_name'] ?? 'User',
          email: data['email'],
        );

        // Save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(user.toJson()));
        await prefs.setBool('is_first_time', false);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          isFirstTime: false,
        );
        developer.log('Login successful');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['error'] ?? 'Login failed',
        );
      }
    } catch (e, stack) {
      developer.log('Login error', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sign in: $e',
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _apiService.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        final data = response.data['data']['user'];
        final user = User(
          id: data['id'],
          name: data['user_metadata']['full_name'] ?? name,
          email: data['email'],
        );

        // Save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(user.toJson()));
        await prefs.setBool('is_first_time', false);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          isFirstTime: false,
          justRegistered: true, // Navigate to Onboarding
        );
        developer.log('Registration successful');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['error'] ?? 'Registration failed',
        );
      }
    } catch (e, stack) {
      developer.log('Registration error', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to register: $e',
      );
    }
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');

      state = state.copyWith(
        isAuthenticated: false,
        user: null,
      );

      developer.log('User signed out');
    } catch (e) {
      developer.log('Sign out error', error: e);
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
    state = state.copyWith(isFirstTime: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
