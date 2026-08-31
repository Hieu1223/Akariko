import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/permission_manager.dart';
import '../../modules/permission_module.dart';

class PermissionsState {
  const PermissionsState({this.permissions = const [], this.loading = false});
  final List<PermissionInfo> permissions;
  final bool loading;

  PermissionsState copyWith({
    List<PermissionInfo>? permissions,
    bool? loading,
  }) =>
      PermissionsState(
        permissions: permissions ?? this.permissions,
        loading: loading ?? this.loading,
      );
}

final permissionsViewModelProvider =
    NotifierProvider<PermissionsViewModel, PermissionsState>(
        PermissionsViewModel.new);

class PermissionsViewModel extends Notifier<PermissionsState> {
  PermissionManager get _manager => ref.read(permissionManagerProvider);

  @override
  PermissionsState build() {
    _refresh();
    return const PermissionsState(loading: true);
  }

  Future<void> _refresh() async {
    final list = await _manager.statuses();
    state = state.copyWith(permissions: list, loading: false);
  }

  /// Asks the OS for [permission]. If it was permanently denied, the OS will
  /// not prompt — the user must toggle it in system settings instead.
  Future<void> request(AppPermission permission) async {
    await _manager.request(permission);
    await _refresh();
  }

  /// Opens the system app-settings screen; re-reads state when we return.
  Future<void> openSettings() async {
    await _manager.openAppSettings();
    await _refresh();
  }
}
