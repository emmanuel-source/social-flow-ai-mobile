enum TeamRole { owner, admin, editor, analyst, approver, client }

class TeamMember {
  const TeamMember({required this.id, required this.displayName, required this.email, required this.role});

  final String id;
  final String displayName;
  final String email;
  final TeamRole role;
}
