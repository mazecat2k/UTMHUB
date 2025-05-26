import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utmhub/screens/addpost_screen.dart';
import 'package:utmhub/screens/login_screen.dart';
import 'package:utmhub/screens/profilepage_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       const Text(
      //         'Login Successful!',
      //         style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      //       ),
      //       const SizedBox(height: 40),
      //       ElevatedButton(
      //         onPressed: () {
      //           // Navigate to login screen and remove all previous routes
      //           Navigator.of(context).pushAndRemoveUntil(
      //             MaterialPageRoute(builder: (context) => const LoginScreen()),
      //             (route) => false, // Remove all previous routes
      //           );
      //         },
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
      //           padding: const EdgeInsets.symmetric(
      //             horizontal: 50,
      //             vertical: 15,
      //           ),
      //         ),
      //         child: const Text(
      //           'Logout',
      //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      // body: StreamBuilder(
      //   stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      //   builder: (context, snapshot) {
      //     if (!snapshot.hasData)
      //       return const Center(child: CircularProgressIndicator());

      //     final docs = snapshot.data!.docs;
      //     if (docs.isEmpty) return const Center(child: Text('No posts yet.'));

      //     return ListView.builder(
      //       itemCount: docs.length,
      //       itemBuilder: (context, index) {
      //         final data = docs[index].data();
      //         return ListTile(
      //           title: Text(data['title'] ?? ''),
      //           subtitle: Text(data['description'] ?? ''),
      //           trailing: Text(data['tags'] ?? ''),
      //         );
      //       },
      //     );
      //   },
      // ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No posts yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final description = data['description'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(description),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // handle like action
                              },
                              icon: const Icon(Icons.thumb_up),
                              label: const Text('Like'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                backgroundColor: Colors.blueGrey[700],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // handle comment action
                              },
                              icon: const Icon(Icons.comment),
                              label: const Text('Comment'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                backgroundColor: Colors.blueGrey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: PopupMenuButton<String>(
        icon: const Icon(Icons.add),
        onSelected: (value) {
          if (value == 'add_post') {
            // Navigate to the add post page
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddPostPage()),
            );
          }
        },
        itemBuilder:
            (context) => [
              const PopupMenuItem(value: 'add_post', child: Text('Add Post')),
            ],
      ),
    );
  }
}
