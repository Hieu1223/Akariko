import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/permission_manager.dart';
import '../data/native/permission_service.dart';

final permissionManagerProvider =
    Provider<PermissionManager>((ref) => PermissionService());
