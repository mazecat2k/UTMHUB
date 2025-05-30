import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utmhub/view/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  String? _username;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUsername(); // 👈 Fetch Firestore username here
  }

  Future<void> _loadUsername() async {
    if (_currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _username = doc.data()?['username'] ?? 'No name set';
        });
      } else {
        setState(() {
          _username = 'No name set';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${_username ?? 'Loading...'}', // 👈 Use Firestore username here
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: ${_currentUser!.email ?? 'No email'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Change Password tapped')),
                      );
                    },
                    child: const Text('Change Password'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }
}
