class TeacherProfile {

  final String name;
  final String email;
  final String phone;
  final String subject;
  final String experience;

  // NEW FIELD
  final String profileImage;

  TeacherProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.subject,
    required this.experience,
    required this.profileImage,
  });

  // ================= FIRESTORE MAP =================

  Map<String, dynamic> toMap() {

    return {
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
      'experience': experience,
      'profileImage': profileImage,
    };
  }

  // ================= FROM FIRESTORE =================

  factory TeacherProfile.fromMap(Map<String, dynamic> map) {

    return TeacherProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      subject: map['subject'] ?? '',
      experience: map['experience'] ?? '',
      profileImage: map['profileImage'] ?? '',
    );
  }
}
