import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Check initial auth state
    _user = _authService.currentUser;
    _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;

    // Listen to auth state changes
    _authService.authStateChanges.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _user = session.user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _status = AuthStatus.unauthenticated;
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        _user = session.user;
      }
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Inscription échouée. Vérifiez votre email.';
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.message);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Une erreur inattendue s\'est produite.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Connexion échouée.';
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.message);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Une erreur inattendue s\'est produite.';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      await _authService.signOut();

      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Erreur lors de la déconnexion.';
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.message);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Une erreur inattendue s\'est produite.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  String _getErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect.';
    } else if (message.contains('Email not confirmed')) {
      return 'Veuillez confirmer votre email.';
    } else if (message.contains('User already registered')) {
      return 'Cet email est déjà utilisé.';
    } else if (message.contains('Password should be at least')) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    } else if (message.contains('Invalid email')) {
      return 'Format d\'email invalide.';
    }
    return message;
  }
}

