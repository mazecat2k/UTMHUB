import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final List<String> likes;

  CommentModel({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.likes,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      text: map['text'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['author'] ?? 'Anonymous',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(map['likes'] ?? []),
    );
  }
}