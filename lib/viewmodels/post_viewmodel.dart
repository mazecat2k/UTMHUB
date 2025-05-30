import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../repository/post_repo.dart';
import '../resources/auth_methods.dart';
import '../utils/search_type.dart';

class PostViewModel extends ChangeNotifier {
  final PostRepository _repository;
  final AuthMethods _authMethods;
  String _searchQuery = '';
  SearchType _searchType = SearchType.title;

  PostViewModel(this._repository, this._authMethods);

  String? get currentUserId => _authMethods.getCurrentUser()?.uid;
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
          case SearchType.description:
            return post.description.toLowerCase().contains(query);
          case SearchType.author:
            return post.authorName.toLowerCase().contains(query);
        }
      }).toList();
    });
  }

  Future<void> deletePost(String postId) async {
    try {
      await _repository.deletePost(postId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      if (currentUserId == null) return;
      await _repository.likePost(postId, currentUserId!);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reportPost({
    required String postId,
    required String reason,
    required String postTitle,
    required String postAuthor,
  }) async {
    try {
      if (currentUserId == null) return;
      await _repository.reportPost(
        postId: postId,
        reporterId: currentUserId!,
        reason: reason,
        postTitle: postTitle,
        postAuthor: postAuthor,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> showReportDialog(BuildContext context, String postId, Map<String, dynamic> postData) async {
    String? reason;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this post?'),
            const SizedBox(height: 10),
            TextFormField(
              maxLines: 3,
              onChanged: (value) => reason = value,
              decoration: const InputDecoration(
                hintText: 'Enter reason for reporting',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (reason != null && reason!.isNotEmpty) {
                await reportPost(
                  postId: postId,
                  reason: reason!,
                  postTitle: postData['title'],
                  postAuthor: postData['authorName'],
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post reported successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}