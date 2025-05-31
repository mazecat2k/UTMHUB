import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../repository/post_repo.dart';
import '../repository/auth_repo.dart';

//enum for the search type
enum SearchType {
  title,
  tags,
} 

class PostViewModel extends ChangeNotifier {
  final PostRepository _repository;
  final AuthRepository _authRepo;
  String _searchQuery = '';
  SearchType _searchType = SearchType.title;
  bool _isLoading = false;
  String? _error;
  

  PostViewModel(this._repository, this._authRepo);

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserId => _authRepo.getCurrentUser()?.uid;
  SearchType get searchType => _searchType;
  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSearchType(SearchType type) {
    _searchType = type;
    notifyListeners();
  }

  Stream<List<PostModel>> getPosts() {
    return _repository.getPosts().map((posts) {
      if (_searchQuery.isEmpty) return posts;
      
      return posts.where((post) {
        final query = _searchQuery.toLowerCase();
        switch (_searchType) {
          case SearchType.title:
            return post.title.toLowerCase().contains(query);
          case SearchType.tags:
            return post.tags.toLowerCase().contains(query);
        }
      }).toList();
    });
  }

  Future<void> deletePost(String postId) async {
    _isLoading = false;
    _error = null;
    notifyListeners();
    try {
      await _repository.deletePost(postId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> likePost(String postId) async {
    if (currentUserId == null) {
      _error = 'Not logged in, cannot like post';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.likePost(postId, currentUserId!);
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

Future<bool> createPost({
  required String title,
  required String description,
  required String tags,
}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    await _repository.createPost(
      title: title,
      description: description,
      tags: tags,
      authorId: currentUserId!,
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