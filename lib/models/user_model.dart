class UserModel {
  final String uid;
  final String email;
  final String patientName;
  final String phoneNumber;
  final int age;
  final String userType = 'patient';
  final String? problemDescription;
  final DateTime? lastVisited;
  final List<String>? imageUrls;

  UserModel({
    required this.uid,
    required this.email,
    required this.patientName,
    required this.phoneNumber,
    required this.age,
    this.problemDescription,
    this.lastVisited,
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
      'lastVisited': lastVisited?.toIso8601String(),
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
      problemDescription: map['problemDescription'],
      lastVisited: map['lastVisited'] != null
          ? DateTime.parse(map['lastVisited'])
          : null,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }
}
