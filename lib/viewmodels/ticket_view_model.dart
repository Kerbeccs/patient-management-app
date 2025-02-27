import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class TicketViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  String patientName = 'Loading...';
  final String doctorName = "Dr. Rajneesh Chaudhary";
  final String slotTiming = "NA";
  final String rescheduledTo = "NA";
  bool isExpanded = false;

  TicketViewModel({required String userId}) {
    _loadPatientData(userId);
  }

  Future<void> _loadPatientData(String userId) async {
    try {
      final patient = await _databaseService.getPatient(userId);
      if (patient != null) {
        patientName = patient.patientName;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading patient data: $e');
    }
  }

  void toggleExpand() {
    isExpanded = !isExpanded;
    notifyListeners();
  }
}
