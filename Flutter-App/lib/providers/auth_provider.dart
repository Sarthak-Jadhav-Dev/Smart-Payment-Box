import 'dart:convert';
import 'dart:developer' as developer;
// ignore: unused_import
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;
  final bool isFirstTime;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isFirstTime = true,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
    bool? isFirstTime,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
      isFirstTime: isFirstTime ?? this.isFirstTime,
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

  AuthNotifier() : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('is_first_time') ?? true;
    final userJson = prefs.getString('user_data');

    if (userJson != null) {
      final user = User.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isFirstTime: isFirstTime,
      );
    } else {
      state = state.copyWith(isFirstTime: isFirstTime);
    }
  }

  Future<void> signInAsGuest() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Simulate a small delay for realistic UX
      await Future.delayed(const Duration(milliseconds: 500));

      final user = User(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Guest User',
        email: 'guest@example.com',
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

      developer.log('Guest Sign-In successful');
    } catch (e, stack) {
      developer.log('Guest Sign-In error', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sign in: ${e.toString()}',
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
