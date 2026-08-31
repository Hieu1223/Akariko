import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/permission_manager.dart';
import 'permissions_viewmodel.dart';

/// Permission manager screen: shows each app permission with its current state
/// and lets the user grant it, or jump to system settings to toggle it.
class PermissionsView extends ConsumerWidget {
  const PermissionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(permissionsViewModelProvider);
    final vm = ref.read(permissionsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final info in state.permissions)
                  _PermissionTile(
                    info: info,
                    onPressed: () {
                      if (info.state.canRequest) {
                        vm.request(info.permission);
                      } else {
                        vm.openSettings();
                      }
                    },
                  ),
                const Divider(height: 24),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Open app settings'),
                  subtitle: const Text(
                    'Toggle permissions in the system settings for this app.',
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: vm.openSettings,
                ),
              ],
            ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({required this.info, required this.onPressed});

  final PermissionInfo info;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final granted = info.state.isGranted;

    return ListTile(
      leading: Icon(info.permission.icon, color: scheme.onSurfaceVariant),
      title: Text(info.permission.title),
      subtitle: Text(info.permission.description),
      trailing: granted
          ? Chip(
              label: const Text('Granted'),
              backgroundColor: Colors.green.withValues(alpha: 0.12),
              labelStyle: const TextStyle(color: Colors.green),
              visualDensity: VisualDensity.compact,
            )
          : FilledButton(
              onPressed: onPressed,
              child: Text(info.state.canRequest ? 'Grant' : 'Settings'),
            ),
    );
  }
}
