class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });
}

class RemoteUser {
  final String id;
  final String orgId;
  final String email;
  final String role;
  final bool isActive;

  const RemoteUser({
    required this.id,
    required this.orgId,
    required this.email,
    required this.role,
    required this.isActive,
  });
}
