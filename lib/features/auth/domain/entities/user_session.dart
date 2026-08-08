class UserSession {
  const UserSession({
    required this.userId,
    required this.name,
    required this.email,
    required this.accessToken,
  });

  final String userId;
  final String name;
  final String email;
  final String accessToken;
}
