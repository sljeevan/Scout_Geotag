class UserProfile {
  UserProfile({
    required this.id,
    required this.orgId,
    required this.email,
    required this.role,
    required this.fullName,
    this.phone,
    this.company,
    this.designation,
    this.employeeId,
    this.location,
    this.avatarUrl,
  });

  final String id;
  final String orgId;
  final String email;
  final String role;
  final String fullName;
  final String? phone;
  final String? company;
  final String? designation;
  final String? employeeId;
  final String? location;
  final String? avatarUrl;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] ?? '').toString(),
      orgId: (json['orgId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phone: json['phone']?.toString(),
      company: json['company']?.toString(),
      designation: json['designation']?.toString(),
      employeeId: json['employeeId']?.toString(),
      location: json['location']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'fullName': fullName,
      'phone': phone,
      'company': company,
      'designation': designation,
      'employeeId': employeeId,
      'location': location,
      'avatarUrl': avatarUrl,
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? company,
    String? designation,
    String? employeeId,
    String? location,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      orgId: orgId,
      email: email,
      role: role,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      designation: designation ?? this.designation,
      employeeId: employeeId ?? this.employeeId,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
