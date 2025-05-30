import 'package:flutter/foundation.dart';
import '../repository/auth_repo.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthViewModel(this._authRepository);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _authRepository.getCurrentUser() != null;

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String bio,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authRepository.signUp(
        email: email,
        password: password,
        username: username,
        bio: bio,
      );
      if (result == "success") {
        await _loadUserData();
        return true;
      }
      _error = result;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authRepository.signIn(
        email: email,
        password: password,
      );
      
      if (result == "success") {
        await _loadUserData();
        return true;
      }
      _error = result;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    _currentUser = await _authRepository.getUserData();
    notifyListeners();
  }
}