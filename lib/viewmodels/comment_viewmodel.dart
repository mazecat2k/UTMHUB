import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../repository/auth_repo.dart';
import '../repository/comment_repo.dart';


class CommentViewModel extends ChangeNotifier {
  final CommentRepository _repository;
  final AuthRepository _authRepo;
  bool _isLoading = false;
  String? _error;

  CommentViewModel(this._repository, this._authRepo);

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserId => _authRepo.getCurrentUser()?.uid;

  Stream<List<CommentModel>> getComments(String postId) {
    return _repository.getComments(postId);
  }

  Future<bool> addComment(String postId, String text) async {
    if (text.trim().isEmpty) {
      _error = 'Comment cannot be empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await _authRepo.getUserData();
      await _repository.addComment(
        postId: postId,
        text: text,
        authorId: currentUserId!,
        authorName: userData?.username ?? 'Anonymous User',
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

  Future<bool> deleteComment(String postId, String commentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteComment(postId, commentId);
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

  Future<bool> likeComment(String postId, String commentId) async {
    if (currentUserId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _repository.likeComment(postId, commentId, currentUserId!);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}