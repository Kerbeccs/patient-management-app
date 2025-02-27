import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/database_service.dart';
import '../models/report_model.dart';

class ReportViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;
  List<ReportModel>? _patientReports;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;
  List<ReportModel>? get patientReports => _patientReports;

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  Future<bool> uploadReport(String patientId, String description) async {
    if (_selectedImage == null) {
      _errorMessage = 'Please select an image first';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Upload image to Firebase Storage with patient's UID in filename
      final String fileName =
          'reports/${patientId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      await ref.putFile(_selectedImage!);
      final String fileUrl = await ref.getDownloadURL();

      // Create report with patient's UID
      final report = ReportModel(
        reportId: '',
        patientId: patientId, // Using patient's UID here
        description: description,
        fileUrl: fileUrl,
        uploadedAt: DateTime.now(),
      );

      await _databaseService.addReport(report);

      _selectedImage = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error uploading report: $e'); // Add debug print
      _errorMessage = 'Failed to upload report: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

  Future<void> fetchPatientReports(String patientId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Fetching reports for patient: $patientId'); // Debug print
      _patientReports = await _databaseService.getPatientReports(patientId);
      print('Fetched ${_patientReports?.length} reports'); // Debug print

      notifyListeners();
    } catch (e) {
      print('Error fetching reports: $e'); // Debug print
      _errorMessage = 'Failed to fetch reports: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
