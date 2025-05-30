import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmhub/view/screens/addpost_screen.dart';
import 'package:utmhub/view/screens/profilepage_screen.dart';
import 'package:utmhub/view/screens/post_detail_screen.dart';
import 'package:utmhub/view/screens/editpost_screen.dart';
import 'package:utmhub/utils/search_type.dart';
import 'package:utmhub/viewmodels/post_viewmodel.dart';
import 'package:utmhub/models/post_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PostViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('UTM Hub'),
            backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
            actions: [
              IconButton(
                icon: const Text('👤', style: TextStyle(fontSize: 24)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Bar with Type Selector
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: viewModel.updateSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),                    DropdownButton<SearchType>(
                      value: viewModel.searchType,
                      items: SearchType.values.map((type) {
                        return DropdownMenuItem<SearchType>(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (SearchType? value) {
                        if (value != null) {
                          viewModel.updateSearchType(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Posts List
              Expanded(
                child: StreamBuilder<List<PostModel>>(
                  stream: viewModel.getPosts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final posts = snapshot.data!;
                    final query = viewModel.searchQuery.toLowerCase();
                    final filteredPosts = query.isEmpty ? posts : posts.where((post) {
                      switch (viewModel.searchType) {
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

                    if (filteredPosts.isEmpty) {
                      return const Center(child: Text('No matching posts found.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        return PostCard(
                          post: post,
                          onLike: () => viewModel.likePost(post.id),
                          onDelete: () => viewModel.deletePost(post.id),
                          onReport: () => viewModel.showReportDialog(context, post.id, post.toMap()),
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPostPage(
                                postId: post.id,
                                postData: post.toMap(),
                              ),
                            ),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                postId: post.id,
                                postData: post.toMap(),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPostPage()),
            ),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

// Separate widget for post card to improve readability
class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const PostCard({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onDelete,
    required this.onReport,
    required this.onEdit,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<PostViewModel>();
    final isAuthor = post.authorId == viewModel.currentUserId;
    final isLiked = post.likes.contains(viewModel.currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    post.authorName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (!isAuthor)
                    IconButton(
                      onPressed: onReport,
                      icon: const Icon(Icons.flag_outlined),
                      iconSize: 20,
                      color: Colors.orange,
                      tooltip: 'Report Post',
                    ),
                  if (isAuthor) ...[
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      iconSize: 20,
                      color: Colors.orange,
                      tooltip: 'Edit Post',
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                      iconSize: 20,
                      color: Colors.red,
                      tooltip: 'Delete Post',
                    ),
                  ],
                  Text(
                    post.createdAt.toString().split(' ')[0],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (post.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.5)),
                  ),
                  child: Text(
                    post.tags,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                post.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onLike,
                      icon: Icon(
                        Icons.thumb_up,
                        color: isLiked ? Colors.blue : Colors.white,
                      ),
                      label: Text('Like (${post.likes.length})'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: isLiked ? Colors.blue.withOpacity(0.8) : Colors.blueGrey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.comment),
                      label: const Text('Comment'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blueGrey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}