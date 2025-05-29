import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utmhub/screens/addpost_screen.dart';
import 'package:utmhub/screens/profilepage_screen.dart';
import 'package:utmhub/screens/post_detail_screen.dart';
import 'package:utmhub/resources/auth_methods.dart';
import 'package:utmhub/widgets/search_bar.dart';
import 'package:utmhub/utils/search_type.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SearchType _searchType = SearchType.title;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

//Report post function
Future<void> _reportPost(String postId, Map<String, dynamic> postData) async {
  String? reason;
  
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this post?'),
            const SizedBox(height: 16),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select a reason'),
              value: reason,
              items: const [
                'Inappropriate content',
                'Spam',
                'Harassment',
                'Misinformation',
                'Other'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                reason = newValue;
                (context as Element).markNeedsBuild();
              },
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
              if (reason != null) {
                // Add report to Firestore
                await FirebaseFirestore.instance.collection('reports').add({
                  'postId': postId,
                  'reportedBy': AuthMethods().getCurrentUser()?.uid,
                  'reason': reason,
                  'postTitle': postData['title'],
                  'postAuthor': postData['authorName'],
                  'createdAt': Timestamp.now(),
                  'status': 'pending', // pending, reviewed, resolved
                });

                if (mounted) {
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
      );
    },
  );
}

  Future<void> _likePost(String postId) async {
    try {
      String? currentUserId = AuthMethods().getCurrentUser()?.uid;
      if (currentUserId == null) return;

      DocumentReference postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId);

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error liking post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePost(String postId) async {
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
            .doc(postId)
            .collection('comments')
            .get();

        for (var comment in commentsSnapshot.docs) {
          // Delete all replies for this comment
          final repliesSnapshot = await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
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
            .doc(postId)
            .delete();

        if (mounted) {
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

  List<QueryDocumentSnapshot> _filterDocs(List<QueryDocumentSnapshot> docs) {
    if (_searchQuery.isEmpty) return docs;
    
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] ?? '').toString().toLowerCase();
      final tags = (data['tags'] ?? '').toString().toLowerCase();
      
      switch (_searchType) {
        case SearchType.title:
          return title.contains(_searchQuery.toLowerCase());
        case SearchType.tags:
          return tags.contains(_searchQuery.toLowerCase());
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UTM Hub'),
        backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
        actions: [
          IconButton(
            icon: const Text('👤', style: TextStyle(fontSize: 24)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
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
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<SearchType>(
                  value: _searchType,
                  items: SearchType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (SearchType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _searchType = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final filteredDocs = _filterDocs(docs);

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text('No matching posts found.'));
                }


                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    final title = data['title'] ?? '';
                    final description = data['description'] ?? '';
                    final authorName = data['authorName'] ?? 'Anonymous User';
                    final createdAt = data['createdAt'] as Timestamp?;
                    final postId = filteredDocs[index].id;
                    final likes = data['likes'] ?? [];
                    final isLiked = likes.contains(AuthMethods().getCurrentUser()?.uid);


                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                postId: postId,
                                postData: data,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Author and date row
                              Row(
                                children: [
                                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    authorName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Report button for non-authors
                                  if (data['authorId'] != AuthMethods().getCurrentUser()?.uid)
                                    IconButton(
                                      onPressed: () => _reportPost(postId, data),
                                      icon: const Icon(Icons.flag_outlined),
                                      iconSize: 20,
                                      color: Colors.orange,
                                      tooltip: 'Report Post',
                                    ),
                                  // Delete button for authors
                                  if (data['authorId'] == AuthMethods().getCurrentUser()?.uid)
                                    IconButton(
                                      onPressed: () => _deletePost(postId),
                                      icon: const Icon(Icons.delete),
                                      iconSize: 20,
                                      color: Colors.red,
                                      tooltip: 'Delete Post',
                                    ),
                                  if (createdAt != null)
                                    Text(
                                      createdAt.toDate().toString().split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                                      if (data['tags'] != null && data['tags'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 10),
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
                                            '${data['tags']}',
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20)
                                      ],
                              Text(
                                description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _likePost(postId),
                                      icon: Icon(
                                        Icons.thumb_up,
                                        color: isLiked ? Colors.blue : Colors.white,
                                      ),
                                      label: Text('Like (${likes.length})'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        backgroundColor: isLiked ? Colors.blue.withOpacity(0.8) : Colors.blueGrey[700],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PostDetailScreen(
                                              postId: postId,
                                              postData: data,
                                            ),
                                          ),
                                        );
                                      },
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
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: PopupMenuButton<String>(
        icon: const Icon(Icons.add),
        onSelected: (value) {
          if (value == 'add_post') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddPostPage()),
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'add_post', child: Text('Add Post')),
        ],
      ),
    );
  }
}
