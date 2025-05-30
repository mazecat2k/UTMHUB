import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository(this._firestore);

  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc))
            .toList());
  }

  Future<void> deletePost(String postId) async {
    final batch = _firestore.batch();
    final postRef = _firestore.collection('posts').doc(postId);

    // Delete comments and replies
    final commentsSnapshot = await postRef.collection('comments').get();
    for (var comment in commentsSnapshot.docs) {
      final repliesSnapshot = await comment.reference.collection('replies').get();
      for (var reply in repliesSnapshot.docs) {
        batch.delete(reply.reference);
      }
      batch.delete(comment.reference);
    }

    // Delete the post
    batch.delete(postRef);
    await batch.commit();
  }

  Future<void> likePost(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    
    await _firestore.runTransaction((transaction) async {
      final postSnap = await transaction.get(postRef);
      if (!postSnap.exists) return;

      final likes = List<String>.from(postSnap.data()?['likes'] ?? []);
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      transaction.update(postRef, {'likes': likes});
    });
  }

  Future<void> reportPost({
    required String postId,
    required String reporterId,
    required String reason,
    required String postTitle,
    required String postAuthor,
  }) async {
    await _firestore.collection('reports').add({
      'postId': postId,
      'reportedBy': reporterId,
      'reason': reason,
      'postTitle': postTitle,
      'postAuthor': postAuthor,
      'createdAt': Timestamp.now(),
      'status': 'pending',
    });
  }
}