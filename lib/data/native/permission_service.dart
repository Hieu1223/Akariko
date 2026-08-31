import 'package:permission_handler/permission_handler.dart';

import '../../core/permission_manager.dart';

/// `permission_handler` implementation of [PermissionManager].
class PermissionService implements PermissionManager {
  final Map<AppPermission, Permission?> _mapping = {
    AppPermission.internet: null, // normal permission, granted at install time
    AppPermission.storage: Permission.storage,
  };

  @override
  Future<List<PermissionInfo>> statuses() async {
    final infos = <PermissionInfo>[];
    for (final permission in AppPermission.values) {
      infos.add(await _resolve(permission));
    }
    return infos;
  }

  @override
  Future<PermissionInfo> request(AppPermission permission) async {
    final native = _mapping[permission];
    if (native == null) {
      // Normal permission — already granted at install once declared.
      return PermissionInfo(permission, PermissionState.always);
    }
    final result = await native.request();
    return PermissionInfo(permission, result.toAppState());
  }

  @override
  Future<void> openAppSettings() => openAppSettings();

  Future<PermissionInfo> _resolve(AppPermission permission) async {
    final native = _mapping[permission];
    if (native == null) {
      return PermissionInfo(permission, PermissionState.always);
    }
    return PermissionInfo(permission, (await native.status).toAppState());
  }
}

extension _PermissionStatusX on PermissionStatus {
  PermissionState toAppState() {
    switch (this) {
      case PermissionStatus.granted:
        return PermissionState.granted;
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        return PermissionState.limited;
      case PermissionStatus.denied:
        return PermissionState.denied;
      case PermissionStatus.permanentlyDenied:
        return PermissionState.permanentlyDenied;
      case PermissionStatus.restricted:
        return PermissionState.restricted;
    }
  }
}
