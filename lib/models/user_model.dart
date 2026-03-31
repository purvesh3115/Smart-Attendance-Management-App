enum UserRole { admin, instructor, student }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final UserRole role;
  final String? department;
  final String? enrollmentId; // for students
  final String? employeeId;  // for instructors

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    this.department,
    this.enrollmentId,
    this.employeeId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'role': role.name,
        'department': department,
        'enrollmentId': enrollmentId,
        'employeeId': employeeId,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        passwordHash: map['passwordHash'],
        role: UserRole.values.firstWhere((e) => e.name == map['role']),
        department: map['department'],
        enrollmentId: map['enrollmentId'],
        employeeId: map['employeeId'],
      );

  UserModel copyWith({
    String? name,
    String? email,
    String? department,
    String? enrollmentId,
    String? employeeId,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        passwordHash: passwordHash,
        role: role,
        department: department ?? this.department,
        enrollmentId: enrollmentId ?? this.enrollmentId,
        employeeId: employeeId ?? this.employeeId,
      );
}
