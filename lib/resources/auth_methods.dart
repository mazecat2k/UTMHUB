import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthMethods {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  
  //sign up
  Future<String>signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    //required Uint8List file,
  }

  )
  async
  {
    String res="Some error occured";
    try{
      //|| file !=null
      if(email.isNotEmpty || password.isNotEmpty || username.isNotEmpty || bio.isNotEmpty ){
        //signup
       UserCredential cred= await _auth.createUserWithEmailAndPassword(email: email, password: password);

       print(cred.user!.uid);

       //add
       await _firestore.collection('users').doc(cred.user!.uid).set({
        'username':username,
        'uid':cred.user!.uid,
        'email': email,
        'bio': bio,
        'followers':[],
        'following':[],
       });

       res="success";
      }

    } catch(err){
      res=err.toString();
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
}




/*import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthMethods {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  
  //sign up
  Future<String>signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    //required Uint8List file,
  }

  )
  async
  {
    String res="Some error occured";
    try{
      //|| file !=null
      if(email.isNotEmpty || password.isNotEmpty || username.isNotEmpty || bio.isNotEmpty ){
        //signup
       UserCredential cred= await _auth.createUserWithEmailAndPassword(email: email, password: password);

       print(cred.user!.uid);

       //add
       await _firestore.collection('users').doc(cred.user!.uid).set({
        'username':username,
        'uid':cred.user!.uid,
        'email': email,
        'bio': bio,
        'followers':[],
        'following':[],
       });

       res="success";
      }

    } catch(err){
      res=err.toString();
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
}*/