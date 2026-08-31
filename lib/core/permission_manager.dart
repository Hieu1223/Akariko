import 'package:flutter/material.dart';

/// App-level permissions surfaced in the permission manager.
///
/// [internet] is a normal (install-time) permission on Android and is always
/// granted once declared in the manifest; it is listed so the user can see the
/// browser has network access (without it the WebView renders blank). [storage]
/// covers "Files & media", used when saving downloads to the device.
enum AppPermission {
  internet,
  storage;

  String get title {
    switch (this) {
      case AppPermission.internet:
        return 'Internet';
      case AppPermission.storage:
        return 'Files & media';
    }
  }

  String get description {
    switch (this) {
      case AppPermission.internet:
        return 'Required to load web pages and look up dictionary entries.';
      case AppPermission.storage:
        return 'Lets the browser save downloaded files to your device.';
    }
  }

  IconData get icon {
    switch (this) {
      case AppPermission.internet:
        return Icons.language;
      case AppPermission.storage:
        return Icons.folder_outlined;
    }
  }
}

/// Coarse permission state, decoupled from the platform plugin's enum so the
/// UI never imports `permission_handler` directly.
enum PermissionState {
  granted,
  limited,
  denied,
  permanentlyDenied,
  restricted,
  always;

  bool get isGranted =>
      this == PermissionState.granted ||
      this == PermissionState.limited ||
      this == PermissionState.always;

  /// True when the OS will still prompt if we call request().
  bool get canRequest => this == PermissionState.denied;
}

class PermissionInfo {
  const PermissionInfo(this.permission, this.state);
  final AppPermission permission;
  final PermissionState state;
}

/// Platform bridge for inspecting and requesting app permissions.
abstract class PermissionManager {
  /// Current state of every managed permission.
  Future<List<PermissionInfo>> statuses();

  /// Prompts the OS for [permission]; returns its resulting state.
  Future<PermissionInfo> request(AppPermission permission);

  /// Opens the OS app-settings screen where the user can toggle permissions.
  Future<void> openAppSettings();
}
