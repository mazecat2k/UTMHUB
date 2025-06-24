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

                            // Return a card widget for each report
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12), // Space between cards
                              color: const Color.fromARGB(255, 37, 37, 37), // Dark card background
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // Rounded corners
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16), // Internal card padding
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Left-align content
                                  children: [
                                    // Report header with ID and delete button
                                    Row(
                                      children: [
                                        // Report icon for visual identification
                                        const Icon(
                                          Icons.report,
                                          color: Colors.red, // Red for warning/danger
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8), // Spacing
                                        // Report ID display (expandable to take remaining space)
                                        Expanded(
                                          child: Text(
                                            'Report ID: ${report.id}', // Show Firestore document ID
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold, // Bold for emphasis
                                              color: Colors.white, // White text
                                            ),
                                          ),
                                        ),
                                        // Delete report button
                                        IconButton(
                                          onPressed: () => _deleteReport(report.id), // Call delete function
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red, // Red delete icon
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8), // Spacing                                    
                                    // Reason for report with styled container
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12, // Horizontal padding for pill shape
                                        vertical: 6, // Vertical padding for height
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2), // Semi-transparent red background
                                        borderRadius: BorderRadius.circular(20), // Pill-shaped container
                                      ),
                                      child: Text(
                                        'Reason: ${reportData['reason'] ?? 'No reason provided'}', // Show reason or fallback
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.red, // Red text to match background theme
                                          fontWeight: FontWeight.bold, // Bold for emphasis
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12), // Spacing
                                    
                                    // Post details section in a styled container
                                    Container(
                                      padding: const EdgeInsets.all(12), // Internal padding
                                      decoration: BoxDecoration(
                                        color: Colors.black26, // Dark background for contrast
                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Section title
                                          Text(
                                            'Reported Post:',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold, // Bold section title
                                              color: Colors.white, // White text
                                            ),
                                          ),
                                          const SizedBox(height: 8), // Spacing
                                          // Check if post data exists before displaying
                                          if (reportData['postData'] != null)
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Post title
                                                Text(
                                                  'Title: ${reportData['postData']['title'] ?? 'No title'}',
                                                  style: const TextStyle(
                                                    color: Colors.white70, // Slightly faded white
                                                  ),
                                                ),
                                                const SizedBox(height: 4), // Small spacing
                                                // Post author
                                                Text(
                                                  'Author: ${reportData['postData']['username'] ?? 'Unknown'}',
                                                  style: const TextStyle(
                                                    color: Colors.white70, // Consistent styling
                                                  ),
                                                ),
                                                const SizedBox(height: 4), // Small spacing
                                                // Post description with text overflow handling
                                                Text(
                                                  'Description: ${reportData['postData']['description'] ?? 'No description'}',
                                                  style: const TextStyle(
                                                    color: Colors.white70, // Consistent styling
                                                  ),
                                                  maxLines: 3, // Limit to 3 lines
                                                  overflow: TextOverflow.ellipsis, // Show ... if text is too long
                                                ),
                                              ],
                                            )
                                          else
                                            // Fallback when post data is missing
                                            const Text(
                                              'Post data not available',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontStyle: FontStyle.italic, // Italic for emphasis on missing data
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12), // Spacing                                    
                                    // Timestamp display with icon
                                    Row(
                                      children: [
                                        // Clock icon to indicate time information
                                        const Icon(
                                          Icons.access_time,
                                          size: 16, // Small icon
                                          color: Colors.grey, // Grey for secondary information
                                        ),
                                        const SizedBox(width: 4), // Small spacing
                                        // Formatted timestamp display
                                        Text(
                                          'Reported: ${_formatTimestamp(reportData['timestamp'])}', // Call helper function
                                          style: const TextStyle(
                                            fontSize: 12, // Small font for secondary info
                                            color: Colors.grey, // Grey for secondary information
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12), // Spacing
                                    
                                    // Action buttons for admin to manage reports
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
                                      children: [
                                        // Delete post button - permanent action
                                        ElevatedButton.icon(
                                          onPressed: () => _deletePost(reportData['postId']), // Call delete function
                                          icon: const Icon(Icons.delete_forever, size: 16), // Delete icon
                                          label: const Text('Delete Post'), // Button text
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red, // Red for dangerous action
                                            foregroundColor: Colors.white, // White text for contrast
                                          ),
                                        ),
                                        // Dismiss report button - keeps post but removes report
                                        ElevatedButton.icon(
                                          onPressed: () => _dismissReport(report.id), // Call dismiss function
                                          icon: const Icon(Icons.check, size: 16), // Check/approve icon
                                          label: const Text('Dismiss'), // Button text
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green, // Green for positive action
                                            foregroundColor: Colors.white, // White text for contrast
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
}
