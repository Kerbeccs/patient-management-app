class UserModel {
  final String uid;
  final String email;
  final String patientName;
  final String phoneNumber;
  final int age;
  final String userType = 'patient';

  UserModel({
    required this.uid,
    required this.email,
    required this.patientName,
    required this.phoneNumber,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'patientName': patientName,
      'phoneNumber': phoneNumber,
      'age': age,
      'userType': userType,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      patientName: map['patientName'],
      phoneNumber: map['phoneNumber'],
      age: map['age'],
    );
  }
}
