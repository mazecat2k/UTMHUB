import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utmhub/resources/auth_methods.dart';
import 'package:utmhub/screens/post_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthMethods().getCurrentUser()?.uid;
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientId', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data!.docs;
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }

          // Group notifications by postId
          final Map<String, List<QueryDocumentSnapshot>> grouped = {};
          for (var notif in notifications) {
            final data = notif.data() as Map<String, dynamic>;
            final postId = data['postId'] ?? '';
            if (postId.isEmpty) continue;
            grouped.putIfAbsent(postId, () => []).add(notif);
          }

          final groupedEntries = grouped.entries.toList();

          return ListView.builder(
            itemCount: groupedEntries.length,
            itemBuilder: (context, index) {
              final postId = groupedEntries[index].key;
              final notifs = groupedEntries[index].value;
              final unreadCount = notifs.where((n) => !(n.data() as Map<String, dynamic>)['isRead']).length;
              final latestNotif = notifs.first;
              final latestData = latestNotif.data() as Map<String, dynamic>;
              final replyText = latestData['replyText'] ?? '';
              // If it's a comment notification, show the post title in the subtitle if replyText is empty
              final postTitle = latestData['postTitle'] ?? 'Your post';

              return Dismissible(
                key: Key(postId),
                direction: DismissDirection.endToStart,
                onDismissed: (_) async {
                  // Delete all notifications for this post
                  for (var notif in notifs) {
                    await notif.reference.delete();
                  }
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  tileColor: unreadCount > 0 ? Colors.yellow[50] : Colors.white,
                  leading: Icon(Icons.notifications, color: unreadCount > 0 ? Colors.orange : Colors.grey),
                  title: Text(
                    'New replies on your post',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    unreadCount > 1
                        ? '$unreadCount new replies. Latest: $replyText'
                        : (replyText.isNotEmpty ? replyText : postTitle),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black54),
                  ),
                  trailing: unreadCount > 0
                      ? CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        )
                      : null,
                  onTap: () async {
                    // Mark all notifications for this post as read
                    for (var notif in notifs) {
                      if (!(notif.data() as Map<String, dynamic>)['isRead']) {
                        await notif.reference.update({'isRead': true});
                      }
                    }
                    // Open post detail
                    final postSnap = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
                    if (postSnap.exists) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                            postId: postId,
                            postData: postSnap.data() as Map<String, dynamic>,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
