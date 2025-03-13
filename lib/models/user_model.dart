class UserModel {
  final String uid;
  final String email;
  final String patientName;
  final String phoneNumber;
  final int age;
  final String userType;
  final String? problemDescription;
  final String? lastVisited;
  final String? nextVisit;
  final String? appointmentStatus;
  final List<String>? imageUrls;

  UserModel({
    required this.uid,
    required this.email,
    required this.patientName,
    required this.phoneNumber,
    required this.age,
    this.userType = 'patient',
    this.problemDescription,
    this.lastVisited,
    this.nextVisit,
    this.appointmentStatus,
    this.imageUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'patientName': patientName,
      'phoneNumber': phoneNumber,
      'age': age,
      'userType': userType,
      'problemDescription': problemDescription,
      'lastVisited': lastVisited,
      'nextVisit': nextVisit,
      'appointmentStatus': appointmentStatus,
      'imageUrls': imageUrls,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      patientName: map['patientName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      age: map['age'] ?? 0,
      userType: map['userType'] ?? 'patient',
      problemDescription: map['problemDescription'],
      lastVisited: map['lastVisited'],
      nextVisit: map['nextVisit'],
      appointmentStatus: map['appointmentStatus'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }
}
