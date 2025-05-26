import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty && bio.isNotEmpty) {
        // Register user with Firebase Auth
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password
        );

        print(cred.user!.uid);

        // Store user data in Firestore
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'username': username,
          'uid': cred.user!.uid,
          'email': email,
          'bio': bio,
          'followers': [],
          'following': [],
        });

        res = "success";
      } else {
        res = "Please fill in all fields";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'email-already-in-use') {
        res = "Email is already in use";
      } else if (err.code == 'weak-password') {
        res = "Password is too weak";
      } else if (err.code == 'invalid-email') {
        res = "Invalid email format";
      } else {
        res = err.message ?? "Registration error";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Login user
  Future<String> logInUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // Login user
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        res = "No user found with this email";
      } else if (err.code == 'wrong-password') {
        res = "Wrong password";
      } else {
        res = err.message ?? "An error occurred during login";
      }
    } catch (err) {
      res = err.toString();
    }
    
    return res;
  }
  
  // Reset Password, this hasn't been implemented fully yet
  Future<String> resetPassword({required String email}) async {
    String res = "Some error occurred";
    
    try {
      if (email.isNotEmpty) {
        await _auth.sendPasswordResetEmail(email: email);
        res = "Password reset link sent to your email";
      } else {
        res = "Please enter an email address";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        res = "No user found with this email";
      } else {
        res = err.message ?? "An error occurred during password reset";
      }
    } catch (err) {
      res = err.toString();
    }
    
    return res;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}