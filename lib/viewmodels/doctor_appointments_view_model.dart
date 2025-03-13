import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class DoctorAppointmentsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime? _selectedDate;
  List<UserModel> _appointmentsForDate = [];
  bool _isLoading = false;
  String? _errorMessage;

  DateTime? get selectedDate => _selectedDate;
  List<UserModel> get appointmentsForDate => _appointmentsForDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Returns the next 7 days as available appointment dates.
  List<DateTime> get availableDates {
    final today = DateTime.now();
    return List.generate(7, (index) => today.add(Duration(days: index)));
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _fetchAppointmentsForDate();
    notifyListeners();
  }

  Future<void> _fetchAppointmentsForDate() async {
    if (_selectedDate == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check if user is authenticated
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not authenticated");
      }

      print("Current user ID: ${currentUser.uid}");
      print("Current user email: ${currentUser.email}");

      // Get the user document to check userType
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw Exception("User document not found in Firestore");
      }

      final userType = userDoc.data()?['userType'];
      print("User type: $userType");

      if (userType != 'doctor') {
        throw Exception("User is not a doctor");
      }

      // Format the date to match how it's stored in Firestore
      final formattedDate =
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

      print("Fetching appointments for date: $formattedDate");

      // First try a simpler query to test permissions
      try {
        final testQuery = await _firestore.collection('users').limit(1).get();
        print(
            "Test query successful, found ${testQuery.docs.length} documents");
      } catch (e) {
        print("Test query failed: $e");
        throw Exception("Firebase permission error: $e");
      }

      // Query users who have appointments on the selected date
      final querySnapshot = await _firestore
          .collection('users')
          .where('nextVisit', isGreaterThanOrEqualTo: formattedDate)
          .where('nextVisit', isLessThan: '${formattedDate}z')
          .get();

      print("Found ${querySnapshot.docs.length} appointments");

      _appointmentsForDate = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching appointments: $e");
      _errorMessage = "Failed to load appointments: $e";

      // Fallback to empty list
      _appointmentsForDate = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAppointmentComplete(UserModel patient) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Extract the appointment date from nextVisit field
      final nextVisit = patient.nextVisit ?? 'N/A';

      // Update the patient record
      await _firestore.collection('users').doc(patient.uid).update({
        'lastVisited': nextVisit,
        'nextVisit': 'N/A',
        'appointmentStatus': 'completed'
      });

      // Refresh the appointments list
      await _fetchAppointmentsForDate();
    } catch (e) {
      print("Error marking appointment complete: $e");
      _errorMessage = "Failed to update appointment: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Call this when the view model is initialized
  void initialize() {
    if (availableDates.isNotEmpty) {
      selectDate(availableDates.first);
    }
  }
}
