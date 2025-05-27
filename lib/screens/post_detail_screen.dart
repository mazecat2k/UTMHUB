import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utmhub/resources/auth_methods.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;

  const PostDetailScreen({
    Key? key,
    required this.postId,
    required this.postData,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();  final TextEditingController _replyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _replyFormKey = GlobalKey<FormState>();
  String? _replyingToCommentId;

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }
  Future<void> _likePost() async {
    try {
      String? currentUserId = AuthMethods().getCurrentUser()?.uid;
      if (currentUserId == null) return;

      DocumentReference postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postRef);
        
        if (postSnapshot.exists) {
          Map<String, dynamic> data = postSnapshot.data() as Map<String, dynamic>;
          List<dynamic> likes = data['likes'] ?? [];
          
          if (likes.contains(currentUserId)) {
            // Unlike the post
            likes.remove(currentUserId);
          } else {
            // Like the post
            likes.add(currentUserId);
          }
          
          transaction.update(postRef, {'likes': likes});
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error liking post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addComment() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get current user data
        Map<String, dynamic>? userData = await AuthMethods().getUserData();
        String authorName = userData?['username'] ?? 'Anonymous User';
        String authorId = AuthMethods().getCurrentUser()?.uid ?? '';        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .add({
          'text': _commentController.text,
          'createdAt': Timestamp.now(),
          'author': authorName,
          'authorId': authorId,
          'likes': [], // Initialize empty likes array
        });

        _commentController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _likeComment(String commentId) async {
    try {
      String? currentUserId = AuthMethods().getCurrentUser()?.uid;
      if (currentUserId == null) return;

      DocumentReference commentRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot commentSnapshot = await transaction.get(commentRef);
        
        if (commentSnapshot.exists) {
          Map<String, dynamic> data = commentSnapshot.data() as Map<String, dynamic>;
          List<dynamic> likes = data['likes'] ?? [];
          
          if (likes.contains(currentUserId)) {
            // Unlike the comment
            likes.remove(currentUserId);
          } else {
            // Like the comment
            likes.add(currentUserId);
          }
          
          transaction.update(commentRef, {'likes': likes});
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error liking comment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addReply(String parentCommentId) async {
    if (_replyFormKey.currentState!.validate()) {
      try {
        Map<String, dynamic>? userData = await AuthMethods().getUserData();
        String authorName = userData?['username'] ?? 'Anonymous User';
        String authorId = AuthMethods().getCurrentUser()?.uid ?? '';

        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .doc(parentCommentId)
            .collection('replies')
            .add({
          'text': _replyController.text,
          'createdAt': Timestamp.now(),
          'author': authorName,
          'authorId': authorId,
          'parentCommentId': parentCommentId,
        });        _replyController.clear();
        setState(() {
          _replyingToCommentId = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reply added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding reply: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  void _startReply(String commentId, String authorName) {
    setState(() {
      _replyingToCommentId = commentId;
    });  }

  Future<void> _deletePost() async {
    try {
      // Show confirmation dialog
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Post'),
            content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        // Delete all comments and replies first
        final commentsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .get();

        for (var comment in commentsSnapshot.docs) {
          // Delete all replies for this comment
          final repliesSnapshot = await FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.postId)
              .collection('comments')
              .doc(comment.id)
              .collection('replies')
              .get();

          for (var reply in repliesSnapshot.docs) {
            await reply.reference.delete();
          }

          // Delete the comment
          await comment.reference.delete();
        }

        // Delete the post
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .delete();

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      // Show confirmation dialog
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Comment'),
            content: const Text('Are you sure you want to delete this comment and all its replies?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        // Delete all replies for this comment first
        final repliesSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .get();

        for (var reply in repliesSnapshot.docs) {
          await reply.reference.delete();
        }

        // Delete the comment
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .doc(commentId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteReply(String commentId, String replyId) async {
    try {
      // Show confirmation dialog
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Reply'),
            content: const Text('Are you sure you want to delete this reply?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reply deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting reply: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.postData['title'] ?? '';
    final description = widget.postData['description'] ?? '';
    final tags = widget.postData['tags'] ?? '';
    final authorName = widget.postData['authorName'] ?? 'Anonymous User';
    final createdAt = widget.postData['createdAt'] as Timestamp?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
      ),
      body: Column(
        children: [
          // Post content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'By $authorName',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              // Delete post button (only show to post author)
                              if (widget.postData['authorId'] == AuthMethods().getCurrentUser()?.uid)
                                IconButton(
                                  onPressed: _deletePost,
                                  icon: const Icon(Icons.delete),
                                  iconSize: 20,
                                  color: Colors.red,
                                  tooltip: 'Delete Post',
                                ),
                              if (createdAt != null)
                                Text(
                                  createdAt.toDate().toString().split('.')[0],
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),                          if (tags.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),                              child: Text(
                                'Tags: $tags',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          // Like button with real-time like count
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(widget.postId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox.shrink();
                              }
                              
                              final postData = snapshot.data!.data() as Map<String, dynamic>;
                              final likes = postData['likes'] ?? [];
                              final isLiked = likes.contains(AuthMethods().getCurrentUser()?.uid);
                              
                              return ElevatedButton.icon(
                                onPressed: _likePost,
                                icon: Icon(
                                  Icons.thumb_up,
                                  color: isLiked ? Colors.blue : Colors.white,
                                ),
                                label: Text('Like (${likes.length})'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLiked ? Colors.blue.withOpacity(0.8) : Colors.blueGrey[700],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (createdAt != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Posted on: ${createdAt.toDate().toString().split('.')[0]}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Comments section
                  const Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Comments list
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postId)
                        .collection('comments')
                        .orderBy('createdAt', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final comments = snapshot.data!.docs;
                      
                      if (comments.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                'No comments yet. Be the first to comment!',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,                        itemBuilder: (context, index) {
                          final commentData = comments[index].data();
                          final commentText = commentData['text'] ?? '';
                          final commentAuthor = commentData['author'] ?? 'Anonymous';
                          final commentTime = commentData['createdAt'] as Timestamp?;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        commentAuthor,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Delete comment button (only show to comment author)
                                      if (commentData['authorId'] == AuthMethods().getCurrentUser()?.uid)
                                        IconButton(
                                          onPressed: () => _deleteComment(comments[index].id),
                                          icon: const Icon(Icons.delete),
                                          iconSize: 16,
                                          color: Colors.red,
                                          tooltip: 'Delete Comment',
                                        ),
                                      if (commentTime != null)
                                        Text(
                                          commentTime.toDate().toString().split('.')[0],
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    commentText,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  // Like button
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _likeComment(comments[index].id),
                                        icon: Icon(
                                          Icons.thumb_up,
                                          color: (commentData['likes'] ?? []).contains(AuthMethods().getCurrentUser()?.uid)
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(commentData['likes'] ?? []).length}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Reply button
                                      TextButton(
                                        onPressed: () {
                                          final authorName = commentData['author'] ?? 'Anonymous';
                                          _startReply(comments[index].id, authorName);
                                        },
                                        child: Text(
                                          'Reply',
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Replies section
                                  if (_replyingToCommentId == comments[index].id) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Form(
                                            key: _replyFormKey,
                                            child: TextFormField(
                                              controller: _replyController,
                                              decoration: InputDecoration(
                                                hintText: 'Write a reply...',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                              ),                                              validator: (value) {
                                                if (value == null || value.trim().isEmpty) {
                                                  return 'Please enter a reply';
                                                }
                                                return null;
                                              },
                                              maxLines: null,
                                              textInputAction: TextInputAction.send,
                                              onFieldSubmitted: (_) => _addReply(comments[index].id),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () => _addReply(comments[index].id),
                                          icon: const Icon(Icons.send),
                                          style: IconButton.styleFrom(
                                            backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
                                            foregroundColor: Colors.white,
                                          ),                                        ),
                                      ],
                                    ),
                                  ],
                                  
                                  // Display existing replies
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(widget.postId)
                                        .collection('comments')
                                        .doc(comments[index].id)
                                        .collection('replies')
                                        .orderBy('createdAt', descending: false)
                                        .snapshots(),
                                    builder: (context, replySnapshot) {
                                      if (!replySnapshot.hasData) {
                                        return const SizedBox.shrink();
                                      }

                                      final replies = replySnapshot.data!.docs;
                                      
                                      if (replies.isEmpty) {
                                        return const SizedBox.shrink();
                                      }

                                      return Container(
                                        margin: const EdgeInsets.only(top: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${replies.length} ${replies.length == 1 ? 'Reply' : 'Replies'}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.only(left: 16),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  left: BorderSide(
                                                    color: Colors.grey.withOpacity(0.3),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                children: replies.map((reply) {
                                                  final replyData = reply.data();
                                                  final replyText = replyData['text'] ?? '';
                                                  final replyAuthor = replyData['author'] ?? 'Anonymous';
                                                  final replyTime = replyData['createdAt'] as Timestamp?;

                                                  return Container(
                                                    margin: const EdgeInsets.only(bottom: 8),
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.withOpacity(0.05),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(
                                                        color: Colors.grey.withOpacity(0.2),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.person,
                                                              size: 14,
                                                              color: Colors.grey[600],
                                                            ),
                                                            const SizedBox(width: 6),
                                                            Text(
                                                              replyAuthor,
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            // Delete reply button (only show to reply author)
                                                            if (replyData['authorId'] == AuthMethods().getCurrentUser()?.uid)
                                                              IconButton(
                                                                onPressed: () => _deleteReply(comments[index].id, reply.id),
                                                                icon: const Icon(Icons.delete),
                                                                iconSize: 14,
                                                                color: Colors.red,
                                                                tooltip: 'Delete Reply',
                                                                padding: EdgeInsets.zero,
                                                                constraints: const BoxConstraints(),
                                                              ),
                                                            if (replyTime != null)
                                                              Text(
                                                                replyTime.toDate().toString().split('.')[0],
                                                                style: TextStyle(
                                                                  color: Colors.grey[500],
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 6),
                                                        Text(
                                                          replyText,
                                                          style: const TextStyle(fontSize: 13),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Add comment section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a comment';
                        }
                        return null;
                      },
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onFieldSubmitted: (_) => _addComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addComment,
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
