import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // Create default categories for the new user
    if (response.user != null) {
      await _createDefaultCategories(response.user!.id);
    }

    return response;
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Create default categories for new user
  Future<void> _createDefaultCategories(String userId) async {
    try {
      // Create expense categories
      for (var cat in Category.defaultExpenseCategories) {
        await _supabase.from('categories').insert({
          'user_id': userId,
          'name': cat['name'],
          'type': 'expense',
          'icon': cat['icon'],
          'color': cat['color'],
        });
      }

      // Create income categories
      for (var cat in Category.defaultIncomeCategories) {
        await _supabase.from('categories').insert({
          'user_id': userId,
          'name': cat['name'],
          'type': 'income',
          'icon': cat['icon'],
          'color': cat['color'],
        });
      }
    } catch (e) {
      // Silently fail - categories can be created later
      // Error logged: $e
    }
  }
}

