import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String description;
  final String tags;
  final String authorName;
  final String authorId;  
  final List<String> likes;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.authorName,
    required this.authorId,
    required this.likes,
    required this.createdAt,
  });

  // Take post from firestore and convert to PostModel
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      tags: data['tags'] ?? '',
      authorName: data['authorName'] ?? '',
      authorId: data['authorId'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert PostModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'tags': tags,
      'authorName': authorName,
      'authorId': authorId,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}