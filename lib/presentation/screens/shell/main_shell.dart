import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/theme_provider.dart';
import '../ai/ai_advisor_screen.dart';
import '../audit/audit_logs_screen.dart';
import '../auth/login_screen.dart';
import '../auth/switch_context_dialog.dart';
import '../cycles/cycles_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../federation/federation_screen.dart';
import '../fines/fines_screen.dart';
import '../governance/governance_screen.dart';
import '../loans/guarantees_screen.dart';
import '../loans/loans_screen.dart';
import '../meetings/meetings_screen.dart';
import '../members/members_screen.dart';
import '../receipts/receipts_screen.dart';
import '../reconciliation/reconciliation_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../subscription/subscription_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MembersScreen(),
    const MeetingsScreen(),
    const LoansScreen(),
    const ReceiptsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeGroup = auth.activeContext;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const SwitchContextDialog(),
            );
          },
          borderRadius: AppDimensions.roundedSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        activeGroup?.groupName ?? 'VicobaPlus',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${activeGroup?.role ?? "MEMBER"} • Tap to switch',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ),
        actions: [
          // Language Switch
          TextButton(
            onPressed: () => localeProvider.toggleLanguage(),
            child: Text(
              localeProvider.isSwahili ? 'SW' : 'EN',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          // Theme Toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        child: Column(
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.primary,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: isDark ? AppColors.primaryLightDark : AppColors.primaryLight,
                child: Text(
                  auth.user?.fullName.isNotEmpty == true
                      ? auth.user!.fullName[0].toUpperCase()
                      : 'V',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              accountName: Text(
                auth.user?.fullName ?? 'VICOBA Member',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: Text(
                '${auth.user?.phone ?? ""} • ${activeGroup?.groupName ?? ""}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),

            // Modules Navigation
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: l10n.translate('dashboard'),
                    selected: _currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabTapped(0);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.people_alt_outlined,
                    label: l10n.translate('members'),
                    selected: _currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabTapped(1);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.event_available_outlined,
                    label: l10n.translate('meetings'),
                    selected: _currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabTapped(2);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.credit_score_outlined,
                    label: l10n.translate('loans'),
                    selected: _currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabTapped(3);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long_outlined,
                    label: l10n.translate('receipts'),
                    selected: _currentIndex == 4,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabTapped(4);
                    },
                  ),
                  const Divider(),

                  // Additional Core Modules
                  _DrawerItem(
                    icon: Icons.gavel_outlined,
                    label: l10n.translate('fines'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FinesScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.autorenew_rounded,
                    label: l10n.translate('cycles'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CyclesScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.how_to_vote_outlined,
                    label: l10n.translate('governance'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GovernanceScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.phone_android_rounded,
                    label: l10n.translate('reconciliation'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReconciliationScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.auto_awesome_rounded,
                    label: l10n.translate('aiAdvisor'),
                    iconColor: AppColors.accent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AiAdvisorScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.workspace_premium_outlined,
                    label: l10n.translate('subscription'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.verified_user_outlined,
                    label: l10n.translate('myGuarantees'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GuaranteesScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart_rounded,
                    label: l10n.translate('reports'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportsScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.account_balance_outlined,
                    label: l10n.translate('federation'),
                    iconColor: AppColors.accent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FederationScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.security_outlined,
                    label: l10n.translate('auditLogs'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AuditLogsScreen()),
                      );
                    },
                  ),
                  const Divider(),

                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: l10n.translate('settings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.logout_rounded,
                    label: l10n.translate('signOut'),
                    iconColor: AppColors.danger,
                    onTap: () async {
                      Navigator.pop(context);
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard_rounded),
            label: l10n.translate('dashboard'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline_rounded),
            activeIcon: const Icon(Icons.people_rounded),
            label: l10n.translate('members'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.event_note_outlined),
            activeIcon: const Icon(Icons.event_note_rounded),
            label: l10n.translate('meetings'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.credit_score_outlined),
            activeIcon: const Icon(Icons.credit_score_rounded),
            label: l10n.translate('loans'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long_rounded),
            label: l10n.translate('receipts'),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color? iconColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? (selected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.primary : (isDark ? AppColors.darkText : AppColors.lightText),
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      selected: selected,
      selectedTileColor: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.roundedSm),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: onTap,
    );
  }
}
