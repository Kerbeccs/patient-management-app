import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Patients Collection Methods
  Future<void> updatePatient(UserModel patient) async {
    await _db.collection('users').doc(patient.uid).set(patient.toMap());
  }

  Future<UserModel?> getPatient(String patientId) async {
    final doc = await _db.collection('users').doc(patientId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Reports Collection Methods
  Future<String> addReport(ReportModel report) async {
    try {
      print('Adding report for patient: ${report.patientId}');
      print('Full report data: ${report.toMap()}');

      final docRef = _db.collection('reports').doc();
      final reportWithId = ReportModel(
        reportId: docRef.id,
        patientId: report.patientId,
        description: report.description,
        fileUrl: report.fileUrl,
        uploadedAt: report.uploadedAt,
      );

      await docRef.set(reportWithId.toMap());
      print('Report saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving report: $e');
      rethrow;
    }
  }

  Future<List<ReportModel>> getPatientReports(String patientId) async {
    try {
      print('Fetching reports for patient ID: $patientId'); // Debug print

      // First get the patient data to get the lastVisited field
      final patientDoc = await _db.collection('users').doc(patientId).get();
      String? lastVisited;

      if (patientDoc.exists) {
        final patientData = patientDoc.data();
        lastVisited = patientData?['lastVisited'];
        print('Patient last visited: $lastVisited'); // Debug print
      }

      // Get reports for specific patient
      final querySnapshot = await _db
          .collection('reports')
          .where('patientId', isEqualTo: patientId)
          .get();

      print(
          'Found ${querySnapshot.docs.length} reports for this patient'); // Debug print

      if (querySnapshot.docs.isNotEmpty) {
        print(
            'Sample report data: ${querySnapshot.docs.first.data()}'); // Debug print
      }

      // Map the reports and include the lastVisited field
      return querySnapshot.docs.map((doc) {
        final reportData = doc.data();
        return ReportModel(
          reportId: reportData['reportId'] ?? '',
          patientId: reportData['patientId'] ?? '',
          description: reportData['description'] ?? '',
          fileUrl: reportData['fileUrl'] ?? '',
          uploadedAt: DateTime.parse(reportData['uploadedAt']),
          lastVisited: lastVisited, // Include the lastVisited field
        );
      }).toList();
    } catch (e) {
      print('Error fetching reports: $e');
      print('Error details: ${e.toString()}');
      return [];
    }
  }

  // Update last visited
  Future<void> updateLastVisited(String patientId) async {
    await _db.collection('users').doc(patientId).update({
      'lastVisited': DateTime.now().toIso8601String(),
    });
  }

  Future<List<UserModel>> getAllPatients() async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .where('userType', isEqualTo: 'patient')
          .get();

      print('Found ${querySnapshot.docs.length} patients');
      print(
          'Patient names: ${querySnapshot.docs.map((doc) => doc.data()['patientName'])}');

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching patients: $e');
      return [];
    }
  }
}
