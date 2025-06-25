import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BanService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if current user is banned
  static Future<Map<String, dynamic>> checkUserBanStatus(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return {'isBanned': false};
      }

      final userData = userDoc.data()!;
      final isBanned = userData['isBanned'] ?? false;
      
      if (!isBanned) {
        return {'isBanned': false};
      }

      // Check if ban has expired
      final banUntil = userData['banUntil'] as Timestamp?;
      if (banUntil == null) {
        // Permanent ban or malformed data
        return {
          'isBanned': true,
          'banReason': userData['banReason'] ?? 'Account suspended',
          'isPermanent': true,
        };
      }

      final now = DateTime.now();
      final banExpiryTime = banUntil.toDate();

      if (now.isAfter(banExpiryTime)) {
        // Ban has expired, remove ban status
        await _firestore.collection('users').doc(userId).update({
          'isBanned': false,
          'banUntil': FieldValue.delete(),
          'banReason': FieldValue.delete(),
        });
        
        return {'isBanned': false};
      }

      // User is still banned
      final remainingMinutes = banExpiryTime.difference(now).inMinutes;
      return {
        'isBanned': true,
        'banReason': userData['banReason'] ?? 'Account temporarily suspended',
        'remainingMinutes': remainingMinutes,
        'banUntil': banExpiryTime,
      };

    } catch (e) {
      // In case of error, allow user to continue
      return {'isBanned': false, 'error': e.toString()};
    }
  }

  // Check ban status for current authenticated user
  static Future<Map<String, dynamic>> checkCurrentUserBanStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'isBanned': false};
    }
    
    return await checkUserBanStatus(user.uid);
  }

  // Method to format remaining ban time
  static String formatBanTimeRemaining(int minutes) {
    if (minutes <= 0) return 'Ban expired';
    
    if (minutes < 60) {
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    }
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (remainingMinutes == 0) {
      return '$hours hour${hours == 1 ? '' : 's'}';
    }
    
    return '$hours hour${hours == 1 ? '' : 's'} and $remainingMinutes minute${remainingMinutes == 1 ? '' : 's'}';
  }

  // Helper method to check ban status and handle logout if banned
  // Returns true if user is banned, false if user can continue
  static Future<bool> checkAndHandleBan(BuildContext context, {VoidCallback? onBanned}) async {
    final banStatus = await checkCurrentUserBanStatus();
    
    if (banStatus['isBanned'] == true) {
      // User is banned, sign them out
      await FirebaseAuth.instance.signOut();
      
      String banMessage;
      if (banStatus['isPermanent'] == true) {
        banMessage = 'Your account has been permanently suspended.\n\nReason: ${banStatus['banReason']}';
      } else {
        final timeRemaining = formatBanTimeRemaining(banStatus['remainingMinutes'] ?? 0);
        banMessage = 'Your account is temporarily suspended.\n\nReason: ${banStatus['banReason']}\nTime remaining: $timeRemaining';
      }
      
      // Show ban message dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text(
              'Account Suspended',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(banMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onBanned != null) {
                    onBanned();
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
      return true; // User is banned
    }
    
    return false; // User is not banned
  }
}
