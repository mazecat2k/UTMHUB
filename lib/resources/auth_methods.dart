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

       //
      /* await _firetore.collection('users').add({
  'username':username,
        'uid':cred.user!.uid,
        'email': email,
        'bio': bio,
        'followers':[],
        'following':[],
       });*/
       res="success";



      }

    } catch(err){
      res=err.toString();
    }
    return res;
  }
}