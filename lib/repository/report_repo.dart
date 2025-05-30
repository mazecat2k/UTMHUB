import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepository(this._firestore);

  Stream<List<ReportModel>> getReport() {
    return _firestore
        .collection('reports')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromFirestore(doc))
            .toList());
  }

  reportPost({required String postId, required String reporterId, required String reason, required String postTitle, required String postAuthor}) {}
}