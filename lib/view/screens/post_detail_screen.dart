import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../viewmodels/post_viewmodel.dart';
import '../../viewmodels/comment_viewmodel.dart';
import '../widgets/comment_card.dart';
import '../widgets/post_detail_card.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final PostModel post;

  const PostDetailScreen({
    Key? key,
    required this.postId,
    required this.post,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleAddComment(CommentViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final success = await viewModel.addComment(
        widget.postId,
        _commentController.text,
      );

      if (success && mounted) {
        _commentController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PostViewModel, CommentViewModel>(
      builder: (context, postVM, commentVM, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Post Details'),
            backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
          ),
          body: Column(
            children: [
              // Post details
              PostDetailCard(
                post: widget.post,
                onLike: () => postVM.likePost(widget.postId),
                onDelete: () => postVM.deletePost(widget.postId),
              ),

              // Comments section
              Expanded(
                child: StreamBuilder<List<CommentModel>>(
                  stream: commentVM.getComments(widget.postId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final comments = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return CommentCard(
                          comment: comments[index],
                          onDelete: () => commentVM.deleteComment(
                            widget.postId,
                            comments[index].id,
                          ),
                          onLike: () => commentVM.likeComment(
                            widget.postId,
                            comments[index].id,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Add comment section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'Please enter a comment';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: commentVM.isLoading
                            ? null
                            : () => _handleAddComment(commentVM),
                        icon: commentVM.isLoading
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.send),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}