import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String postId;
  final String reporterId;
  final String reason;
  final String postAuthor;

  ReportModel({
    required this.reportId,
    required this.postId,
    required this.reporterId,
    required this.reason,
    required this.postAuthor,
  });

  // Take post from firestore and convert to ReportModel
  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      reportId: doc.id,
      postId: data['postId'] ?? '',
      reporterId: data['reporterId'] ?? '',
      reason: data['reason'] ?? '',
      postAuthor: data['postAuthor'] ?? '',
    );
  }

  // Convert ReportModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason,
      'postAuthor': postAuthor,
    };
  }
}