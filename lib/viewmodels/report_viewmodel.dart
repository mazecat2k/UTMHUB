import 'package:flutter/foundation.dart';
import '../repository/report_repo.dart';
import '../repository/auth_repo.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportRepository _repository;
  final AuthRepository _authRepo;
  bool _isLoading = false;
  String? _error;

  ReportViewModel(this._repository, this._authRepo);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserId => _authRepo.getCurrentUser()?.uid;

  Future<bool> reportPost({
    required String postId,
    required String reason,
    required String postTitle,
    required String postAuthor,
  }) async {
    if (reason.isEmpty) {
      _error = 'Please provide a reason';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (currentUserId == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _repository.reportPost(
        postId: postId,
        reporterId: currentUserId!,
        reason: reason,
        postTitle: postTitle,
        postAuthor: postAuthor,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}