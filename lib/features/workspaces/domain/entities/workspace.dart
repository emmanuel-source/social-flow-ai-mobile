enum WorkspaceType { personal, brand, company, agency }

class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    required this.type,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final WorkspaceType type;
  final String? avatarUrl;
}
