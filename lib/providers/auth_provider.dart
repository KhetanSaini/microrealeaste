import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/models/user.dart';
import '../database/data_service.dart';

// Authentication state
class AuthState {
  final User? currentUser;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? currentUser,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Authentication provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();
  
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final token = await _storage.read(key: 'auth_token');
      final userId = await _storage.read(key: 'user_id');
      
      if (token != null && userId != null) {
        // In a real app, you would validate the token with your backend
        // For now, we'll just check if the user exists in our local data
        final user = DataService.getUserById(userId);
        if (user != null) {
          state = state.copyWith(
            currentUser: user,
            isAuthenticated: true,
            isLoading: false,
          );
        } else {
          await _clearAuthData();
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to check authentication status',
        isLoading: false,
      );
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // In a real app, you would validate credentials with your backend
      // For demo purposes, we'll use a simple check
      final users = DataService.users;
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );
      
      // Simple password check (in real app, use proper hashing)
      if (password == 'demo123') { // Demo password
        await _storage.write(key: 'auth_token', value: 'demo_token_${user.id}');
        await _storage.write(key: 'user_id', value: user.id);
        
        state = state.copyWith(
          currentUser: user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        throw Exception('Invalid password');
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
      );
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _clearAuthData();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to logout',
        isLoading: false,
      );
    }
  }

  /// Clear authentication data from secure storage
  Future<void> _clearAuthData() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_id');
  }

  /// Update current user profile
  Future<void> updateProfile(User updatedUser) async {
    try {
      await DataService.updateUser(updatedUser);
      state = state.copyWith(currentUser: updatedUser);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update profile');
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Computed providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).currentUser;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
}); 