class ReportModel {
  final String reportId;
  final String patientId;
  final String description;
  final String fileUrl;
  final DateTime uploadedAt;

  ReportModel({
    required this.reportId,
    required this.patientId,
    required this.description,
    required this.fileUrl,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'patientId': patientId,
      'description': description,
      'fileUrl': fileUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportId: map['reportId'] ?? '',
      patientId: map['patientId'] ?? '',
      description: map['description'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      uploadedAt: DateTime.parse(map['uploadedAt']),
    );
  }
} 