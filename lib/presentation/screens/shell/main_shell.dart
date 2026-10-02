import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../guards/route_guards.dart';
import '../../navigation/nav_config.dart';
import '../auth/login_screen.dart';
import '../auth/switch_context_dialog.dart';
import '../dashboard/dashboard_screen.dart';
import '../loans/loans_screen.dart';
import '../meetings/meetings_screen.dart';
import '../members/members_screen.dart';
import '../receipts/receipts_screen.dart';

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
    final activeRole = auth.currentRole;
    final badgeInfo = NavConfig.getRoleBadgeInfo(activeRole, isDark);
    final groupedItems = NavConfig.getGroupedNavItemsForRole(activeRole);

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
                        '${l10n.translate(badgeInfo.roleKey)} • Tap to switch',
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
            // Drawer Header with Dynamic Role Identity
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: isDark ? AppColors.primaryLightDark : AppColors.primaryLight,
                        child: Text(
                          auth.user?.fullName.isNotEmpty == true
                              ? auth.user!.fullName[0].toUpperCase()
                              : 'V',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Context switch button in drawer
                      IconButton(
                        tooltip: l10n.translate('switchGroup'),
                        icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white70),
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (_) => const SwitchContextDialog(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.user?.fullName ?? 'VICOBA Member',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${auth.user?.phone ?? ""} • ${activeGroup?.groupName ?? ""}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Role Badge Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? badgeInfo.backgroundColor
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? badgeInfo.color.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          badgeInfo.icon,
                          size: 14,
                          color: isDark ? badgeInfo.color : Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.translate(badgeInfo.roleKey),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkText : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Modules Navigation filtered by Role
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // --- Core Navigation ---
                  if (groupedItems.containsKey(NavSection.core)) ...[
                    _buildSectionHeader(
                      context,
                      l10n.translate('navSectionCore'),
                      isDark,
                    ),
                    ...groupedItems[NavSection.core]!.map(
                      (item) => _DrawerItem(
                        icon: item.icon,
                        label: l10n.translate(item.labelKey),
                        selected: _currentIndex == item.tabIndex,
                        iconColor: item.iconColor,
                        onTap: () {
                          Navigator.pop(context);
                          if (item.tabIndex != null) {
                            _onTabTapped(item.tabIndex!);
                          }
                        },
                      ),
                    ),
                  ],

                  // --- Operations Section ---
                  if (groupedItems.containsKey(NavSection.operations)) ...[
                    const Divider(height: 16),
                    _buildSectionHeader(
                      context,
                      l10n.translate('navSectionOperations'),
                      isDark,
                    ),
                    ...groupedItems[NavSection.operations]!.map(
                      (item) => _DrawerItem(
                        icon: item.icon,
                        label: l10n.translate(item.labelKey),
                        iconColor: item.iconColor,
                        onTap: () {
                          Navigator.pop(context);
                          if (item.screenBuilder != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => ProtectedRoute(
                                  allowedRoles: item.allowedRoles,
                                  child: item.screenBuilder!(ctx),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],

                  // --- Leadership & Oversight Section ---
                  if (groupedItems.containsKey(NavSection.leadership)) ...[
                    const Divider(height: 16),
                    _buildSectionHeader(
                      context,
                      l10n.translate('navSectionLeadership'),
                      isDark,
                    ),
                    ...groupedItems[NavSection.leadership]!.map(
                      (item) => _DrawerItem(
                        icon: item.icon,
                        label: l10n.translate(item.labelKey),
                        iconColor: item.iconColor,
                        onTap: () {
                          Navigator.pop(context);
                          if (item.screenBuilder != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => ProtectedRoute(
                                  allowedRoles: item.allowedRoles,
                                  child: item.screenBuilder!(ctx),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],

                  // --- Intelligence Section ---
                  if (groupedItems.containsKey(NavSection.intelligence)) ...[
                    const Divider(height: 16),
                    ...groupedItems[NavSection.intelligence]!.map(
                      (item) => _DrawerItem(
                        icon: item.icon,
                        label: l10n.translate(item.labelKey),
                        iconColor: item.iconColor ?? AppColors.accent,
                        onTap: () {
                          Navigator.pop(context);
                          if (item.screenBuilder != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => ProtectedRoute(
                                  allowedRoles: item.allowedRoles,
                                  child: item.screenBuilder!(ctx),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],

                  // --- System Section ---
                  const Divider(height: 16),
                  _buildSectionHeader(
                    context,
                    l10n.translate('navSectionPreferences'),
                    isDark,
                  ),
                  if (groupedItems.containsKey(NavSection.system)) ...[
                    ...groupedItems[NavSection.system]!.map(
                      (item) => _DrawerItem(
                        icon: item.icon,
                        label: l10n.translate(item.labelKey),
                        iconColor: item.iconColor,
                        onTap: () {
                          Navigator.pop(context);
                          if (item.screenBuilder != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => ProtectedRoute(
                                  allowedRoles: item.allowedRoles,
                                  child: item.screenBuilder!(ctx),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],

                  // Sign out item
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

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 8, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
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
        color: iconColor ??
            (selected
                ? AppColors.primary
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected
              ? AppColors.primary
              : (isDark ? AppColors.darkText : AppColors.lightText),
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      selected: selected,
      selectedTileColor: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.roundedSm),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      onTap: onTap,
    );
  }
}
