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

  // Show dialog for changing username
  Future<void> _showChangeUsernameDialog() async {
    final usernameController = TextEditingController(text: _username);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Username'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'New Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              maxLength: 30,
            ),
            const SizedBox(height: 8),
            const Text(
              'Username must be at least 3 characters long',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUsername = usernameController.text.trim();
              
              if (newUsername.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Username cannot be empty'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (newUsername.length < 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Username must be at least 3 characters'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_currentUser!.uid)
                    .update({'username': newUsername});

                setState(() {
                  _username = newUsername;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Username updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update username: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Show dialog for changing email
  Future<void> _showChangeEmailDialog() async {
    final currentPasswordController = TextEditingController();
    final newEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newEmailController,
              decoration: const InputDecoration(
                labelText: 'New Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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

                await _currentUser!.reauthenticateWithCredential(credential);
                await _currentUser!.updateEmail(newEmailController.text);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email updated successfully'),
                    backgroundColor: Colors.green,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Show dialog for changing password
  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_reset),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text.isEmpty ||
                  currentPasswordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                  ),
                );
                return;
              }

              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 6 characters'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final credential = EmailAuthProvider.credential(
                  email: _currentUser!.email!,
                  password: currentPasswordController.text,
                );

                await _currentUser!.reauthenticateWithCredential(credential);
                await _currentUser!.updatePassword(newPasswordController.text);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password updated successfully'),
                    backgroundColor: Colors.green,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
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
        elevation: 0,
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(224, 167, 34, 1),
                          Color.fromRGBO(204, 147, 14, 1),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            (_username?.isNotEmpty == true ? _username![0].toUpperCase() : 'U'),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(224, 167, 34, 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _username ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _currentUser!.email ?? 'No email',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  // Profile Options
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // Account Management Section
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.manage_accounts, color: Color.fromRGBO(224, 167, 34, 1)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Account Management',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 20,
                                  child: Icon(Icons.person, color: Colors.white, size: 20),
                                ),
                                title: const Text('Change Username'),
                                subtitle: Text('Current: ${_username ?? 'Loading...'}'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: _showChangeUsernameDialog,
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 20,
                                  child: Icon(Icons.email, color: Colors.white, size: 20),
                                ),
                                title: const Text('Change Email'),
                                subtitle: Text(_currentUser!.email ?? 'No email'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: _showChangeEmailDialog,
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  radius: 20,
                                  child: Icon(Icons.lock, color: Colors.white, size: 20),
                                ),
                                title: const Text('Change Password'),
                                subtitle: const Text('Update your password'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: _showChangePasswordDialog,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // App Info Section
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.purple,
                              radius: 20,
                              child: Icon(Icons.info, color: Colors.white, size: 20),
                            ),
                            title: const Text('About UTMHUB'),
                            subtitle: const Text('App information and support'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('About UTMHUB'),
                                  content: const Text(
                                    'UTMHUB is a platform for UTM students to connect, share, and collaborate.\n\nVersion: 1.0.0\n\nDeveloped with ❤️ for UTM students.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Sign Out'),
                                  content: const Text('Are you sure you want to sign out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await FirebaseAuth.instance.signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              'Sign Out',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
