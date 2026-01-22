class StudentProfile {

  String name;
  String email;
  String phone;
  String dob;
  String address;

  // Parent Details
  String parentName;
  String parentContact;

  // Base64 Image String
  String profileImage;
  String year;
  String department;


  StudentProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    required this.address,
    required this.parentName,
    required this.parentContact,
    required this.profileImage,
    required this.year,
    required this.department,

  });

  // Convert Model -> Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
      'address': address,
      'parentName': parentName,
      'parentContact': parentContact,
      'profileImage': profileImage,
      'createdAt': DateTime.now(),
      'year': year,
      'department': department,
    };
  }

  // Convert Firestore -> Model
  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    return StudentProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dob: map['dob'] ?? '',
      address: map['address'] ?? '',
      parentName: map['parentName'] ?? '',
      parentContact: map['parentContact'] ?? '',
      profileImage: map['profileImage'] ?? '',
      year: map['year'] ?? '',
      department: map['department'] ?? '',
    );
  }
}
