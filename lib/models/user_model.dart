import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String username;
  final String uid;
  final String email;
  final String bio;
  final List<String> followers;
  final List<String> following;


  UserModel({
    required this.username,
    required this.uid,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
  });

  // Take post from firestore and convert to UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'bio': bio,
      'followers': followers,
      'following': following,    };
  }
}