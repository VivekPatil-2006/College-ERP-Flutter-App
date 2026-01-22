class AdminStudent {

  String id;
  String name;
  String email;
  String phone;

  AdminStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory AdminStudent.fromMap(String id, Map<String, dynamic> map) {

    return AdminStudent(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
