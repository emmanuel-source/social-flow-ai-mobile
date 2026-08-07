import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/automation_agent.dart';

final agentControllerProvider = NotifierProvider<AgentController, AutomationAgent>(AgentController.new);

class AgentController extends Notifier<AutomationAgent> {
  @override
  AutomationAgent build() => const AutomationAgent(name: 'Agent Contenu', template: 'Création de contenu', autonomy: AgentAutonomy.approvalRequired, active: false, permissions: {'Lire les statistiques'});

  void setTemplate(String value) => state = state.copyWith(template: value);
  void setName(String value) => state = state.copyWith(name: value);
  void setAutonomy(AgentAutonomy value) => state = state.copyWith(autonomy: value);
  void togglePermission(String permission) { final next = {...state.permissions}; next.contains(permission) ? next.remove(permission) : next.add(permission); state = state.copyWith(permissions: next); }
  void setActive(bool value) => state = state.copyWith(active: value);
}
