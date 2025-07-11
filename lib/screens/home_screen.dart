import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utmhub/screens/addpost_screen.dart';
import 'package:utmhub/screens/profilepage_screen.dart';
import 'package:utmhub/screens/post_detail_screen.dart';
import 'package:utmhub/resources/auth_methods.dart';
import 'package:utmhub/widgets/search_bar.dart';
import 'package:utmhub/utils/search_type.dart';
import 'package:utmhub/screens/editpost_screen.dart';
import 'package:utmhub/screens/notification_screen.dart'; // Import NotificationScreen
import 'package:utmhub/widgets/banner_ad_widget.dart'; // Import Banner Ad Widget
import 'package:utmhub/utils/ad_manager.dart'; // Import Ad Manager
import 'package:utmhub/services/ban_service.dart'; // Import Ban Service
import 'package:utmhub/screens/login_screen.dart'; // Import Login Screen
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'dart:math'; // For random ad display


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SearchType _searchType = SearchType.title;
  final AdManager _adManager = AdManager();
  
  @override
  void initState() {
    super.initState();
    // Load ads when screen initializes
    _adManager.loadBannerAd();
    _adManager.loadInterstitialAd();
    _adManager.loadRewardedAd();
    
    // Check if user is banned when entering home screen
    _checkUserBanStatus();
  }
  
  // Method to check if the current user is banned
  Future<void> _checkUserBanStatus() async {
    final banStatus = await BanService.checkCurrentUserBanStatus();
    
    if (banStatus['isBanned'] == true && mounted) {
      // User is banned, sign them out and redirect to login
      await FirebaseAuth.instance.signOut();
      
      String banMessage;
      if (banStatus['isPermanent'] == true) {
        banMessage = 'Your account has been permanently suspended.\n\nReason: ${banStatus['banReason']}';
      } else {
        final timeRemaining = BanService.formatBanTimeRemaining(banStatus['remainingMinutes'] ?? 0);
        banMessage = 'Your account is temporarily suspended.\n\nReason: ${banStatus['banReason']}\nTime remaining: $timeRemaining';
      }
      
      // Show ban message dialog and redirect to login
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text(
            'Account Suspended',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(banMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to login screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

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
          TextButton(            onPressed: () async {
              if (reason != null) {
                // Add report to Firestore with comprehensive data for admin review
                await FirebaseFirestore.instance.collection('reports').add({
                  'postId': postId, // ID of the reported post for admin reference
                  'reportedBy': AuthMethods().getCurrentUser()?.uid, // User who made the report
                  'reason': reason, // Selected reason for reporting
                  'postData': postData, // Store the entire post data for admin to see context
                  'timestamp': Timestamp.now(), // When the report was made (matches admin dashboard)
                  'status': 'pending', // Report status for future workflow (pending, reviewed, resolved)
                });

                // Close dialog and show success message if widget is still mounted
                if (mounted) {
                  Navigator.of(context).pop(); // Close the report dialog
                  // Show confirmation snackbar to user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post reported successfully'),
                      backgroundColor: Colors.green, // Green for success
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
    final currentUserId = AuthMethods().getCurrentUser()?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('UTM Hub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Notification Icon with Badge
          StreamBuilder<QuerySnapshot>(
            stream: currentUserId == null
                ? null
                : FirebaseFirestore.instance
                    .collection('notifications')
                    .where('recipientId', isEqualTo: currentUserId)
                    .where('isRead', isEqualTo: false)
                    .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.length;
              }
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    tooltip: 'Notifications',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, size: 30, color: Colors.white),
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
                          // Show interstitial ad occasionally (1 in 3 times)
                          if (Random().nextInt(3) == 0) {
                            _adManager.showInterstitialAd();
                          }
                          
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
                                  
                                  //Delete and Edit buttons
                                  if (data['authorId'] == AuthMethods().getCurrentUser()?.uid) ...[
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                        builder: (context) => EditPostPage(
                                          postId: postId,
                                          postData: data,
                                        ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
                                    iconSize: 20,
                                    color: Colors.orange,
                                    tooltip: 'Edit Post',
                                  ),
                                  IconButton(
                                    onPressed: () => _deletePost(postId),
                                    icon: const Icon(Icons.delete),
                                    iconSize: 20,
                                    color: Colors.red,
                                    tooltip: 'Delete Post',
                                  ),
                                ],

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
                                        // Show interstitial ad occasionally (1 in 4 times for comment button)
                                        if (Random().nextInt(4) == 0) {
                                          _adManager.showInterstitialAd();
                                        }
                                        
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
      bottomNavigationBar: const BannerAdWidget(), // Add banner ad at bottom
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