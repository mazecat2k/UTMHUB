// Import necessary packages for UI components, Firebase Firestore, and navigation
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For accessing Firestore database
import 'package:utmhub/screens/login_screen.dart'; // For logout navigation
import 'package:utmhub/screens/revenue_analytics_screen.dart'; // Import Revenue Analytics Screen
import 'package:utmhub/screens/ad_config_screen.dart'; // Import Ad Config Screen

// AdminDashboard is a StatefulWidget because it manages dynamic state (loading, data updates)
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Create a Firestore instance to interact with the database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to ban a user for 10 minutes
  Future<void> _banUser(String? userId, String? username) async {
    if (userId == null) return;
    
    try {
      final banUntil = DateTime.now().add(const Duration(minutes: 10));
      
      await _firestore.collection('users').doc(userId).update({
        'isBanned': true,
        'banUntil': Timestamp.fromDate(banUntil),
        'banReason': 'Content violation - reported post',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${username ?? 'Unknown'} banned for 10 minutes'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error banning user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Function to get user data by ID
  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.exists ? userDoc.data() : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with admin title and logout functionality
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Bold text for better visibility
            color: Colors.white, // White text for contrast against orange background
          ),
        ),
        backgroundColor: const Color.fromRGBO(224, 167, 34, 1), 
        elevation: 0, 
        actions: [
          // Logout button
          IconButton(
            onPressed: () {
              _showLogoutDialog(); // Show confirmation dialog before logout
            },
            icon: const Icon(Icons.logout, color: Colors.white), // White logout icon
          ),
        ],
      ),      body: Column(
        children: [
          // Header section with admin deets
          Container(
            width: double.infinity, // Full width container
            padding: const EdgeInsets.all(20), // Internal spacing
            decoration: const BoxDecoration(
              color: Color.fromRGBO(224, 167, 34, 1), 
              borderRadius: BorderRadius.only(
                // Rounded bottom corners
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Admin panel settings icon 
                const Icon(
                  Icons.admin_panel_settings,
                  size: 60, 
                  color: Colors.white, 
                ),
                const SizedBox(height: 10), 
                // Welcome message for admin user
                const Text(
                  'Welcome, Admin',
                  style: TextStyle(
                    fontSize: 24, // Large font for main heading
                    fontWeight: FontWeight.bold, // Bold for emphasis
                    color: Colors.white, // White text on orange background
                  ),
                ),
                const SizedBox(height: 5), // Small spacing
                // Subtitle explaining the purpose of this screen
                const Text(
                  'Manage reported posts',
                  style: TextStyle(
                    fontSize: 16, // Medium font for subtitle
                    color: Colors.white70, // Slightly transparent white for hierarchy
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Spacing between header and content
          
          // Admin Navigation Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: const Color.fromARGB(255, 37, 37, 37),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RevenueAnalyticsScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.analytics,
                                  size: 40,
                                  color: Color.fromRGBO(224, 167, 34, 1),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Revenue Analytics',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        color: const Color.fromARGB(255, 37, 37, 37),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdConfigScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.settings,
                                  size: 40,
                                  color: Colors.blue,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Ad Configuration',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  color: const Color.fromARGB(255, 37, 37, 37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.report,
                          size: 40,
                          color: Colors.red,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Reported Posts Management',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Reports section - main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16), // Side margins
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Left-align content
                children: [
                  // Section title for reported posts
                  const Text(
                    'Reported Posts',
                    style: TextStyle(
                      fontSize: 20, // Large font for section heading
                      fontWeight: FontWeight.bold, // Bold for emphasis
                      color: Colors.white, // White text for dark theme
                    ),
                  ),
                  const SizedBox(height: 16), // Spacing below title
                  // Expanded widget to fill remaining space with scrollable content
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      // Real-time stream of reports from Firestore, ordered by newest first
                      stream: _firestore
                          .collection('reports') // Access 'reports' collection
                          .orderBy('timestamp', descending: true) // Sort by timestamp, newest first
                          .snapshots(), // Get real-time updates
                      builder: (context, snapshot) {
                        // Show loading spinner while waiting for data
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color.fromRGBO(224, 167, 34, 1), // Brand color loading indicator
                            ),
                          );
                        }

                        // Show error message if something goes wrong
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}', // Display the actual error
                              style: const TextStyle(color: Colors.red), // Red text for errors
                            ),
                          );
                        }

                        // Show empty state when no reports exist
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon indicating no reports
                                Icon(
                                  Icons.report_off,
                                  size: 80, // Large icon for visibility
                                  color: Colors.grey, // Grey for inactive state
                                ),
                                SizedBox(height: 16), // Spacing
                                // Message explaining no reports
                                Text(
                                  'No reported posts',
                                  style: TextStyle(
                                    fontSize: 18, // Medium font
                                    color: Colors.grey, // Grey for inactive state
                                  ),
                                ),
                              ],
                            ),
                          );
                        }                        // Build scrollable list of report cards
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length, // Number of reports
                          itemBuilder: (context, index) {
                            // Get individual report document
                            DocumentSnapshot report = snapshot.data!.docs[index];
                            // Extract report data as a map for easy access
                            Map<String, dynamic> reportData = 
                                report.data() as Map<String, dynamic>;

                            // Get post and user data
                            final postData = reportData['postData'] as Map<String, dynamic>?;
                            final postAuthorId = postData?['authorId'] as String?;
                            final authorName = postData?['authorName'] ?? postData?['username'] ?? 'Unknown User';

                            // Return a card widget for each report
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16), // More space between cards
                              color: const Color.fromARGB(255, 45, 45, 45), // Slightly lighter dark background
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16), // More rounded corners
                              ),
                              elevation: 4, // Add shadow for depth
                              child: Padding(
                                padding: const EdgeInsets.all(20), // More padding for better spacing
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Left-align content
                                  children: [
                                    // Enhanced report header
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.report_problem,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Report #${report.id.substring(0, 8)}...', // Shorter ID display
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => _deleteReport(report.id),
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            tooltip: 'Delete Report',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Report reason with better styling
                                    Row(
                                      children: [
                                        const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Reason:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              reportData['reason'] ?? 'No reason provided',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Enhanced post details section
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black26,
                                            Colors.black12,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Section header
                                          Row(
                                            children: [
                                              const Icon(Icons.article_outlined, color: Color.fromRGBO(224, 167, 34, 1), size: 20),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Reported Post Details',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(224, 167, 34, 1),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          
                                          if (postData != null) ...[
                                            // Post title
                                            _buildDetailRow(
                                              Icons.title,
                                              'Title',
                                              postData['title'] ?? 'No title',
                                              Colors.blue,
                                            ),
                                            const SizedBox(height: 8),
                                            
                                            // Post author (fixed to show correct name)
                                            _buildDetailRow(
                                              Icons.person,
                                              'Author',
                                              authorName,
                                              Colors.green,
                                            ),
                                            const SizedBox(height: 8),
                                            
                                            // Post tags if available
                                            if (postData['tags'] != null && postData['tags'].toString().isNotEmpty)
                                              _buildDetailRow(
                                                Icons.tag,
                                                'Tags',
                                                postData['tags'].toString(),
                                                Colors.purple,
                                              ),
                                            const SizedBox(height: 8),
                                            
                                            // Post description
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.description, color: Colors.grey, size: 16),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'Description:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white70,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    postData['description'] ?? 'No description',
                                                    style: const TextStyle(
                                                      color: Colors.white60,
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ] else
                                            const Center(
                                              child: Text(
                                                'Post data not available',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Timestamp with better styling
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.schedule,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Reported: ${_formatTimestamp(reportData['timestamp'])}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // Enhanced action buttons
                                    Row(
                                      children: [
                                        // Delete post button
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _showDeleteConfirmation(reportData['postId'], postData?['title'] ?? 'this post'),
                                            icon: const Icon(Icons.delete_forever, size: 16),
                                            label: const Text('Delete Post'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        
                                        // Ban user button
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _showBanConfirmation(postAuthorId, authorName),
                                            icon: const Icon(Icons.block, size: 16),
                                            label: const Text('Ban User'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        
                                        // Dismiss report button
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _dismissReport(report.id),
                                            icon: const Icon(Icons.check_circle, size: 16),
                                            label: const Text('Dismiss'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Helper function to format Firestore timestamps into readable format
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time'; // Handle null timestamps
    
    DateTime dateTime;
    // Handle different timestamp types from Firestore
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
    } else if (timestamp is DateTime) {
      dateTime = timestamp; // Already a DateTime object
    } else {
      return 'Invalid timestamp'; // Handle unexpected timestamp types
    }
    
    // Format as DD/MM/YYYY HH:MM for readability
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Function to permanently delete a post from the database
  Future<void> _deletePost(String? postId) async {
    if (postId == null) return; // Safety check for null postId
    
    try {
      // Delete the post document from Firestore
      await _firestore.collection('posts').doc(postId).delete();
      // Show success message to admin
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post deleted successfully'),
          backgroundColor: Colors.red, // Red for deletion action
        ),
      );
    } catch (e) {
      // Show error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting post: $e'), // Show actual error
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to dismiss a report (remove report but keep post)
  Future<void> _dismissReport(String reportId) async {
    try {
      // Delete the report document from Firestore
      await _firestore.collection('reports').doc(reportId).delete();
      // Show success message to admin
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report dismissed'),
          backgroundColor: Colors.green, // Green for positive action
        ),
      );
    } catch (e) {
      // Show error message if dismissal fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error dismissing report: $e'), // Show actual error
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to delete a report entry (alternative to dismiss)
  Future<void> _deleteReport(String reportId) async {
    try {
      // Delete the report document from Firestore
      await _firestore.collection('reports').doc(reportId).delete();
      // Show confirmation message to admin
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report deleted'),
          backgroundColor: Colors.orange, // Orange for neutral action
        ),
      );
    } catch (e) {
      // Show error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting report: $e'), // Show actual error
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // Function to show logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 37, 37, 37), // Dark background for consistency
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white), // White title text
          ),
          content: const Text(
            'Are you sure you want to logout?', // Confirmation message
            style: TextStyle(color: Colors.white70), // Slightly faded white text
          ),
          actions: [
            // Cancel button - stays in admin dashboard
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without logging out
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey), // Grey for secondary action
              ),
            ),
            // Logout button - returns to login screen
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog first
                // Navigate back to login screen and clear navigation stack
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red), // Red for logout action
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // Show confirmation dialog before deleting a post
  Future<void> _showDeleteConfirmation(String? postId, String postTitle) async {
    if (postId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 45, 45, 45),
        title: const Text(
          'Delete Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to permanently delete "$postTitle"?\n\nThis action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deletePost(postId);
    }
  }

  // Show confirmation dialog before banning a user
  Future<void> _showBanConfirmation(String? userId, String username) async {
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 45, 45, 45),
        title: const Text(
          'Ban User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to ban "$username" for 10 minutes?\n\nThey will not be able to use their account during this time.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Ban User', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _banUser(userId, username);
    }
  }
}
