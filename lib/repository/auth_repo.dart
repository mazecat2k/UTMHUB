import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Sign up a new user
  Future<String> signUp({
    required String email,
    required String password,
    required String username,
    required String bio,
  }) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty && bio.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password
        );

        await _createUserInFirestore(cred.user!.uid, username, email, bio);
        return "success";
      }
      return "Please fill in all fields";
    } on FirebaseAuthException catch (err) {
      return _handleAuthException(err);
    }
  }
  //Sign in an existing user
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        return "success";
      }
      return "Please enter all the fields";
    } on FirebaseAuthException catch (err) {
      return _handleAuthException(err);
    }
  }
  //Sign out the current user
  Future<void> signOut() => _auth.signOut();
  
  User? getCurrentUser() => _auth.currentUser;

  Future<UserModel?> getUserData() async {
    try {
      User? currentUser = getCurrentUser();
      if (currentUser != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> _createUserInFirestore(
    String uid, 
    String username, 
    String email, 
    String bio
  ) async {
    await _firestore.collection('users').doc(uid).set({
      'username': username,
      'uid': uid,
      'email': email,
      'bio': bio,
      'followers': [],
      'following': [],
    });
  }

  String _handleAuthException(FirebaseAuthException err) {
    switch (err.code) {
      case 'email-already-in-use':
        return "Email is already in use";
      case 'weak-password':
        return "Password is too weak";
      case 'invalid-email':
        return "Invalid email format";
      case 'user-not-found':
        return "No user found with this email";
      case 'wrong-password':
        return "Wrong password";
      default:
        return err.message ?? "An authentication error occurred";
    }
  }
}