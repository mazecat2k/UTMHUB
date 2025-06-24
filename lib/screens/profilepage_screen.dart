// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:utmhub/screens/login_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   User? _currentUser;
//   String? _username;

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     _loadUsername(); // 👈 Fetch Firestore username here
//   }

//   Future<void> _loadUsername() async {
//     if (_currentUser != null) {
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(_currentUser!.uid)
//           .get();

//       if (doc.exists) {
//         setState(() {
//           _username = doc.data()?['username'] ?? 'No name set';
//         });
//       } else {
//         setState(() {
//           _username = 'No name set';
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
//       ),
//       body: _currentUser == null
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Name: ${_username ?? 'Loading...'}', // 👈 Use Firestore username here
//                     style: const TextStyle(fontSize: 18),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     'Email: ${_currentUser!.email ?? 'No email'}',
//                     style: const TextStyle(fontSize: 18),
//                   ),
//                   const SizedBox(height: 30),
//                   ElevatedButton(
//                     onPressed: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Change Password tapped')),
//                       );
//                     },
//                     child: const Text('Change Password'),
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () async {
//                       await FirebaseAuth.instance.signOut();
//                       Navigator.of(context).pushAndRemoveUntil(
//                         MaterialPageRoute(builder: (context) => const LoginScreen()),
//                         (route) => false,
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                     child: const Text('Logout'),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:utmhub/screens/login_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   User? _currentUser;
//   String? _username;

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     _loadUsername();
//   }

//   Future<void> _loadUsername() async {
//     if (_currentUser != null) {
//       final doc =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(_currentUser!.uid)
//               .get();

//       if (doc.exists) {
//         setState(() {
//           _username = doc.data()?['username'] ?? 'No name set';
//         });
//       } else {
//         setState(() {
//           _username = 'No name set';
//         });
//       }
//     }
//   }

//   // Show dialog for changing email
//   Future<void> _showChangeEmailDialog() async {
//     final currentPasswordController = TextEditingController();
//     final newEmailController = TextEditingController();

//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Change Email'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: currentPasswordController,
//                   decoration: const InputDecoration(
//                     labelText: 'Current Password',
//                   ),
//                   obscureText: true,
//                 ),
//                 TextField(
//                   controller: newEmailController,
//                   decoration: const InputDecoration(labelText: 'New Email'),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   try {
//                     final user = _currentUser!;
//                     final credential = EmailAuthProvider.credential(
//                       email: user.email!,
//                       password: currentPasswordController.text,
//                     );

//                     // Reauthenticate user
//                     await user.reauthenticateWithCredential(credential);

//                     // Update email
//                     await user.updateEmail(newEmailController.text.trim());

//                     // Update email in Firestore (optional, if you store email there)
//                     await FirebaseFirestore.instance
//                         .collection('users')
//                         .doc(user.uid)
//                         .update({'email': newEmailController.text.trim()});

//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Email updated successfully'),
//                       ),
//                     );
//                     setState(() {}); // Refresh UI
//                   } on FirebaseAuthException catch (e) {
//                     String errorMessage;
//                     switch (e.code) {
//                       case 'wrong-password':
//                         errorMessage = 'Incorrect current password';
//                         break;
//                       case 'invalid-email':
//                         errorMessage = 'Invalid new email address';
//                         break;
//                       case 'email-already-in-use':
//                         errorMessage = 'Email is already in use';
//                         break;
//                       case 'requires-recent-login':
//                         errorMessage =
//                             'Please log in again to perform this action';
//                         break;
//                       default:
//                         errorMessage = 'Error: ${e.message}';
//                     }
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text(errorMessage)));
//                   } catch (e) {
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text('Error: $e')));
//                   }
//                 },
//                 child: const Text('Save'),
//               ),
//             ],
//           ),
//     );
//   }

//   // Show dialog for changing password
//   Future<void> _showChangePasswordDialog() async {
//     final currentPasswordController = TextEditingController();
//     final newPasswordController = TextEditingController();

//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Change Password'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: currentPasswordController,
//                   decoration: const InputDecoration(
//                     labelText: 'Current Password',
//                   ),
//                   obscureText: true,
//                 ),
//                 TextField(
//                   controller: newPasswordController,
//                   decoration: const InputDecoration(labelText: 'New Password'),
//                   obscureText: true,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   try {
//                     final user = _currentUser!;
//                     final credential = EmailAuthProvider.credential(
//                       email: user.email!,
//                       password: currentPasswordController.text,
//                     );

//                     // Reauthenticate user
//                     await user.reauthenticateWithCredential(credential);

//                     // Update password
//                     await user.updatePassword(newPasswordController.text);

//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Password updated successfully'),
//                       ),
//                     );
//                   } on FirebaseAuthException catch (e) {
//                     String errorMessage;
//                     switch (e.code) {
//                       case 'wrong-password':
//                         errorMessage = 'Incorrect current password';
//                         break;
//                       case 'weak-password':
//                         errorMessage = 'New password is too weak';
//                         break;
//                       case 'requires-recent-login':
//                         errorMessage =
//                             'Please log in again to perform this action';
//                         break;
//                       default:
//                         errorMessage = 'Error: ${e.message}';
//                     }
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text(errorMessage)));
//                   } catch (e) {
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text('Error: $e')));
//                   }
//                 },
//                 child: const Text('Save'),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
//       ),
//       body:
//           _currentUser == null
//               ? const Center(child: CircularProgressIndicator())
//               : Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Name: ${_username ?? 'Loading...'}',
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       'Email: ${_currentUser!.email ?? 'No email'}',
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                     const SizedBox(height: 30),
//                     ElevatedButton(
//                       onPressed: _showChangePasswordDialog,
//                       child: const Text('Change Password'),
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: _showChangeEmailDialog,
//                       child: const Text('Change Email'),
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: () async {
//                         await FirebaseAuth.instance.signOut();
//                         Navigator.of(context).pushAndRemoveUntil(
//                           MaterialPageRoute(
//                             builder: (context) => const LoginScreen(),
//                           ),
//                           (route) => false,
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                       ),
//                       child: const Text('Logout'),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utmhub/screens/login_screen.dart';
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
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    if (_currentUser != null) {
      final doc =
          await FirebaseFirestore.instance
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

  // Show dialog for changing email
  Future<void> _showChangeEmailDialog() async {
    final currentPasswordController = TextEditingController();
    final newEmailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                  obscureText: true,
                ),
                TextField(
                  controller: newEmailController,
                  decoration: const InputDecoration(labelText: 'New Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (newEmailController.text.isEmpty ||
                      currentPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                      ),
                    );
                    return;
                  }

                  try {
                    final credential = EmailAuthProvider.credential(
                      email: _currentUser!.email!,
                      password: currentPasswordController.text,
                    );
                    print('pass4');

                    await _currentUser!.reauthenticateWithCredential(
                      credential,
                    );
                    print('pass5');

                    await _currentUser!.updateEmail(newEmailController.text);
                    print('pass6');

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email updated successfully'),
                      ),
                    );
                    setState(() {}); // Refresh UI
                  } on FirebaseAuthException catch (e) {
                    String errorMessage;
                    switch (e.code) {
                      case 'invalid-email':
                        errorMessage = 'Invalid email format';
                        break;
                      case 'wrong-password':
                        errorMessage = 'Incorrect current password';
                        break;
                      case 'email-already-in-use':
                        errorMessage = 'Email is already in use';
                        break;
                      default:
                        errorMessage = 'Error: ${e.message}';
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(errorMessage)));
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  // Show dialog for changing password
  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                  obscureText: true,
                ),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (newPasswordController.text.isEmpty ||
                      currentPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                      ),
                    );
                    return;
                  }

                  if (newPasswordController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password must be at least 6 characters'),
                      ),
                    );
                    return;
                  }

                  try {
                    final credential = EmailAuthProvider.credential(
                      email: _currentUser!.email!,
                      password: currentPasswordController.text,
                    );
                    print('pass1');

                    await _currentUser!.reauthenticateWithCredential(
                      credential,
                    );
                    print('pass2');

                    await _currentUser!.updatePassword(
                      newPasswordController.text,
                    );
                    print('pass3');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password updated successfully'),
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    String errorMessage;
                    switch (e.code) {
                      case 'wrong-password':
                        errorMessage = 'Incorrect current password';
                        break;
                      case 'weak-password':
                        errorMessage = 'New password is too weak';
                        break;
                      default:
                        errorMessage = 'Error: ${e.message}';
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(errorMessage)));
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
      ),
      body:
          _currentUser == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${_username ?? 'Loading...'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${_currentUser!.email ?? 'No email'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _showChangePasswordDialog,
                      child: const Text('Change Password'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _showChangeEmailDialog,
                      child: const Text('Change Email'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
    );
  }
}
