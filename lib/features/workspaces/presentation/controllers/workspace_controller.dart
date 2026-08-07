import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/workspace.dart';

class WorkspaceState {
  const WorkspaceState({required this.available, required this.current});

  final List<Workspace> available;
  final Workspace current;
}

class WorkspaceController extends Notifier<WorkspaceState> {
  @override
  WorkspaceState build() {
    const personal = Workspace(id: 'personal', name: 'Mon espace', type: WorkspaceType.personal);
    const brand = Workspace(id: 'socialflow', name: 'SocialFlow AI', type: WorkspaceType.brand);
    const available = [personal, brand];

    final persistedId = LocalStorage.selectedWorkspaceId;
    Workspace current = brand;
    for (final item in available) {
      if (item.id == persistedId) {
        current = item;
        break;
      }
    }
    return WorkspaceState(available: available, current: current);
  }

  Future<void> select(Workspace workspace) async {
    if (!state.available.any((item) => item.id == workspace.id)) return;
    state = WorkspaceState(available: state.available, current: workspace);
    await LocalStorage.setSelectedWorkspaceId(workspace.id);
  }
}

final workspaceControllerProvider =
    NotifierProvider<WorkspaceController, WorkspaceState>(WorkspaceController.new);
