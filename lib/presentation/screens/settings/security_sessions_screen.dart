import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/models.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/glass_card.dart';
import '../../common/themed_loader.dart';

class SecuritySessionsScreen extends StatefulWidget {
  const SecuritySessionsScreen({super.key});

  @override
  State<SecuritySessionsScreen> createState() => _SecuritySessionsScreenState();
}

class _SecuritySessionsScreenState extends State<SecuritySessionsScreen> {
  bool _isRevoking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GroupDataProvider>().loadSessions();
      }
    });
  }

  Future<void> _revokeSession(String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Device Session?'),
        content: const Text(
          'This will immediately log out the selected device. Any unsaved offline actions from that device must be re-authenticated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revoke Session', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRevoking = true);
    try {
      if (!mounted) return;
      await context.read<GroupDataProvider>().revokeSession(sessionId);
      if (!mounted) return;
      setState(() => _isRevoking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session revoked successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRevoking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to revoke session: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _revokeAllOthers() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke All Other Devices?'),
        content: const Text(
          'Are you sure you want to terminate all other active login sessions except this current phone?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revoke All Others', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRevoking = true);
    try {
      if (!mounted) return;
      await context.read<GroupDataProvider>().revokeAllOtherSessions();
      if (!mounted) return;
      setState(() => _isRevoking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All other sessions terminated.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRevoking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  List<UserSession> _getDemoSessions() {
    return [
      UserSession(
        id: 'ses-curr',
        deviceInfo: 'Current Mobile Device (Android App)',
        ipAddress: '197.250.45.12',
        lastActive: 'Just now',
        isCurrent: true,
      ),
      UserSession(
        id: 'ses-web',
        deviceInfo: 'Google Chrome on Ubuntu (Web Portal)',
        ipAddress: '197.250.45.12',
        lastActive: '25 minutes ago',
        isCurrent: false,
      ),
      UserSession(
        id: 'ses-tablet',
        deviceInfo: 'iPad Pro (Safari Browser)',
        ipAddress: '102.164.88.94',
        lastActive: 'Yesterday at 18:42',
        isCurrent: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupData = context.watch<GroupDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sessions = groupData.sessions.isNotEmpty
        ? groupData.sessions
        : _getDemoSessions();

    final otherSessions = sessions.where((s) => !s.isCurrent).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('securitySessions')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => groupData.loadSessions(),
          ),
        ],
      ),
      body: groupData.isLoading && groupData.sessions.isEmpty
          ? const Center(child: ThemedLoader(message: 'Checking active device sessions...'))
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.lg),
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You are logged into VicobaPlus on these devices. If you see an unrecognized device, revoke its session immediately.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Current Device Card
                Text(
                  'Current Device',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                ...sessions.where((s) => s.isCurrent).map((s) => _buildSessionCard(s, isDark, true)),

                const SizedBox(height: 24),

                // Other Devices Section
                if (otherSessions.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Other Active Devices (${otherSessions.length})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      if (!_isRevoking)
                        TextButton(
                          onPressed: _revokeAllOthers,
                          child: Text(
                            l10n.translate('revokeAllOthers'),
                            style: TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...otherSessions.map((s) => _buildSessionCard(s, isDark, false)),
                ],
              ],
            ),
    );
  }

  Widget _buildSessionCard(UserSession s, bool isDark, bool isCurrent) {
    IconData deviceIcon;
    final dev = s.deviceInfo.toLowerCase();
    if (dev.contains('chrome') || dev.contains('web')) {
      deviceIcon = Icons.laptop_chromebook_rounded;
    } else if (dev.contains('ipad') || dev.contains('tablet')) {
      deviceIcon = Icons.tablet_mac_rounded;
    } else {
      deviceIcon = Icons.smartphone_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderColor: isCurrent ? AppColors.primary.withValues(alpha: 0.4) : null,
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primaryLight : (isDark ? Colors.white10 : Colors.black12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                deviceIcon,
                color: isCurrent ? AppColors.primary : (isDark ? Colors.white70 : Colors.black54),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.deviceInfo,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'THIS DEVICE',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'IP: ${s.ipAddress} • Last active: ${s.lastActive}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isCurrent)
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                tooltip: 'Revoke Session',
                onPressed: () => _revokeSession(s.id),
              ),
          ],
        ),
      ),
    );
  }
}
