class LocalUser {
  final int? id;
  final String email;
  final String orgId;
  final String role;
  final bool isActive;

  const LocalUser({
    this.id,
    required this.email,
    required this.orgId,
    required this.role,
    required this.isActive,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'org_id': orgId,
        'role': role,
        'is_active': isActive ? 1 : 0,
      };

  factory LocalUser.fromMap(Map<String, dynamic> map) => LocalUser(
        id: map['id'] as int?,
        email: map['email'] as String,
        orgId: map['org_id'] as String,
        role: map['role'] as String,
        isActive: (map['is_active'] as int) == 1,
      );
}
