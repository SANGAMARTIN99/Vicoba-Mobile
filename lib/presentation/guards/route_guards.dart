import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../common/state_views.dart';

/// Route guard widget that prevents unauthorized users from accessing
/// screens not permitted for their active role.
class ProtectedRoute extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const ProtectedRoute({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAllowed = auth.hasRole(allowedRoles);

    if (isAllowed) {
      return child;
    }

    if (fallback != null) {
      return fallback!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Access'),
      ),
      body: NoPermissionView(
        roleRequired: allowedRoles.join(', '),
      ),
    );
  }
}

/// Conditional widget rendering helper based on role authorization.
/// Example:
/// Can(
///   allowedRoles: ['CHAIRPERSON', 'TREASURER'],
///   child: FloatingActionButton(...),
/// )
class Can extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const Can({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAllowed = auth.hasRole(allowedRoles);

    if (isAllowed) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
