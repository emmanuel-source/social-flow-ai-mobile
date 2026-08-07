enum AgentAutonomy { approvalRequired, supervised, autonomous }

class AutomationAgent {
  const AutomationAgent({required this.name, required this.template, required this.autonomy, required this.active, required this.permissions});
  final String name;
  final String template;
  final AgentAutonomy autonomy;
  final bool active;
  final Set<String> permissions;

  AutomationAgent copyWith({String? name, String? template, AgentAutonomy? autonomy, bool? active, Set<String>? permissions}) => AutomationAgent(name: name ?? this.name, template: template ?? this.template, autonomy: autonomy ?? this.autonomy, active: active ?? this.active, permissions: permissions ?? this.permissions);
}
