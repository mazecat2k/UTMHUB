import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
import '../../models/post_model.dart';

// ViewModels
import '../../viewmodels/post_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

// Views - Screens
import '../screens/addpost_screen.dart';
import '../screens/editpost_screen.dart';
import '../screens/post_detail_screen.dart';
import '../screens/profilepage_screen.dart';
import '../screens/login_screen.dart';

// Views - Widgets
import '../widgets/card.dart';
import '../widgets/report_prompt.dart';

// Utils
import '../../core/utils/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

@override
Widget build(BuildContext context) {
  return Consumer2<PostViewModel, AuthViewModel>(
    builder: (context, postVM, authVM, child) {
      if (!authVM.isLoggedIn) {
        return const LoginScreen();
      }

      return Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            _buildSearchBar(postVM),
            if (postVM.error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  postVM.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            _buildPostsList(postVM),
          ],
        ),
        floatingActionButton: _buildAddPostButton(context),
      );
    },
  );
}

  //Top AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('UTM Hub'),
      backgroundColor: appbarColor,
      actions: [
        IconButton(
          icon: const Text('👤', style: TextStyle(fontSize: 24)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(PostViewModel viewModel) {
    return Padding(
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
          const SizedBox(width: 8),
          DropdownButton<SearchType>(
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
    );
  }
  //List of Posts when searching
  Widget _buildPostsList(PostViewModel viewModel) {
    return Expanded(
      child: StreamBuilder<List<PostModel>>(
        stream: viewModel.getPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredPosts = _getFilteredPosts(snapshot.data!, viewModel);          
          if (filteredPosts.isEmpty) {
            return const Center(child: Text('No matching posts found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) => _buildPostCard(
              context,
              filteredPosts[index],
              viewModel,
            ),
          );
        },
      ),
    );
  }

  //Shows options to search by title or tags
  List<PostModel> _getFilteredPosts(List<PostModel> posts, PostViewModel viewModel) {
    final query = viewModel.searchQuery.toLowerCase();
    if (query.isEmpty) return posts;

    return posts.where((post) {
      switch (viewModel.searchType) {
        case SearchType.title:
          return post.title.toLowerCase().contains(query);
        case SearchType.tags:
          return post.tags.toLowerCase().contains(query);
      }
    }).toList();
  }

  Widget _buildPostCard(
    BuildContext context,
    PostModel post,
    PostViewModel viewModel,
  ) {
    return PostCard(
      post: post,
      onLike: () => viewModel.likePost(post.id),
      onDelete: () => viewModel.deletePost(post.id),
      onEdit: () => _navigateToEditPost(context, post),
      onTap: () => _navigateToPostDetail(context, post),
      onReport: () => showDialog(
      context: context,
      builder: (context) => ReportDialog(
        postId: post.id,
        postData: post.toMap(),
        ),
      ),
    );
  }

  void _navigateToEditPost(BuildContext context, PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostPage(
          postId: post.id,
          postData: post.toMap(),
        ),
      ),
    );
  }

  void _navigateToPostDetail(BuildContext context, PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          postId: post.id,
          postData: post.toMap(),
        ),
      ),
    );
  }

  Widget _buildAddPostButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddPostPage()),
      ),
      child: const Icon(Icons.add),
    );
  }
}