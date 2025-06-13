# Admin Dashboard Documentation

## Overview
The UTMHub app now includes admin functionality that allows administrators to manage reported posts. This implementation includes detailed code comments explaining each functionality.

## Code Structure & Comments
All modified files include comprehensive comments explaining:
- **Purpose**: Why each line or block of code exists
- **Functionality**: What each piece of code does
- **Implementation details**: How the code achieves its goals
- **UI/UX reasoning**: Why specific styling and layout choices were made
- **Database interactions**: How data is stored and retrieved from Firestore
- **Error handling**: How errors are managed and displayed to users

## Admin Login
- **Admin Email**: `basil22@gmail.com`
- **Admin Password**: `Basil22!!`

**Implementation Details:**
- Login credentials are checked before Firebase authentication
- Admin users bypass normal Firebase auth flow
- Hardcoded credentials allow admin access without user account creation
- Navigation uses `pushReplacement` to prevent back navigation to login

## Admin Dashboard Features

### 1. Real-time Report Monitoring
**Technical Implementation:**
- Uses `StreamBuilder` with Firestore `snapshots()` for real-time updates
- Reports ordered by timestamp (newest first) using `orderBy('timestamp', descending: true)`
- Handles loading states, errors, and empty states with appropriate UI feedback
- Data retrieved from 'reports' collection in Firestore

### 2. Report Display & Management
**UI Components:**
- **Card-based Layout**: Each report displayed in styled cards with rounded corners
- **Color Coding**: Red for reports/danger actions, green for positive actions, grey for secondary info
- **Information Hierarchy**: Important info (report reason) highlighted with colored containers
- **Responsive Design**: Uses `Expanded` and `Row` widgets for proper layout distribution

### 3. Admin Actions
**Delete Post:**
- Permanently removes post from 'posts' collection
- Includes error handling with try-catch blocks
- Shows confirmation via `SnackBar` with red background

**Dismiss Report:**
- Removes report while keeping the original post
- Provides positive feedback with green `SnackBar`
- Maintains post integrity while clearing the report

**Report Management:**
- Delete report functionality for removing report entries
- Logout with confirmation dialog to prevent accidental logouts

### 4. Data Formatting & Display
**Timestamp Handling:**
- Converts Firestore `Timestamp` objects to readable format
- Handles multiple timestamp types (Timestamp, DateTime)
- Displays as DD/MM/YYYY HH:MM format for user readability
- Includes null checking for data safety

## Database Structure & Comments

### Reports Collection
```json
{
  "postId": "string",           // Links to original post for admin actions
  "reportedBy": "string",       // User UID who made the report
  "reason": "string",           // Dropdown-selected reason for reporting
  "postData": {                 // Complete post data for admin context
    "title": "string",          // Post title for quick identification
    "username": "string",       // Author name for moderation decisions
    "description": "string",    // Post content for review
    // ... other post fields preserved for complete context
  },
  "timestamp": "Timestamp",     // When report was created (Firestore Timestamp)
  "status": "string"            // Report workflow status (pending/reviewed/resolved)
}
```

## Enhanced Report Functionality
**User Reporting Process:**
- Users select from predefined reasons (reduces spam reports)
- Complete post data stored with report for admin context
- Uses `mounted` check to prevent UI updates on disposed widgets
- Confirmation feedback provided via `SnackBar`

## Code Quality & Best Practices
**Error Handling:**
- Try-catch blocks around all Firestore operations
- User-friendly error messages displayed via `SnackBar`
- Null checking for data safety (postId, timestamp, etc.)

**UI/UX Considerations:**
- Loading indicators during async operations
- Color consistency across the application
- Proper spacing and typography hierarchy
- Responsive design for different screen sizes
- Empty states for when no reports exist

**State Management:**
- Proper `setState()` usage for UI updates
- Loading states to prevent double-taps
- Error states for user feedback
- Real-time updates without manual refresh

## Security & Production Notes
- Admin credentials currently hardcoded for demo purposes
- Production implementation should use Firebase Authentication roles
- Consider implementing Firebase Security Rules for admin operations
- Add audit logging for admin actions in production
- Implement rate limiting for report submissions
