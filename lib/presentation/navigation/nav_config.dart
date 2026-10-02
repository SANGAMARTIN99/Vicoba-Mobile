import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../screens/ai/ai_advisor_screen.dart';
import '../screens/audit/audit_logs_screen.dart';
import '../screens/cycles/cycles_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/federation/federation_screen.dart';
import '../screens/fines/fines_screen.dart';
import '../screens/governance/governance_screen.dart';
import '../screens/loans/guarantees_screen.dart';
import '../screens/loans/loans_screen.dart';
import '../screens/meetings/meetings_screen.dart';
import '../screens/members/members_screen.dart';
import '../screens/receipts/receipts_screen.dart';
import '../screens/reconciliation/reconciliation_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/subscription/subscription_screen.dart';

enum NavSection {
  core,
  operations,
  leadership,
  intelligence,
  system,
}

class NavItem {
  final String id;
  final String labelKey;
  final IconData icon;
  final NavSection section;
  final List<String> allowedRoles;
  final Widget Function(BuildContext)? screenBuilder;
  final bool isCoreTab;
  final int? tabIndex;
  final Color? iconColor;

  const NavItem({
    required this.id,
    required this.labelKey,
    required this.icon,
    required this.section,
    required this.allowedRoles,
    this.screenBuilder,
    this.isCoreTab = false,
    this.tabIndex,
    this.iconColor,
  });

  bool isAllowedForRole(String role) {
    if (allowedRoles.contains('ALL')) return true;
    final r = role.toUpperCase();
    if (r == 'PLATFORM_ADMIN') return true;
    return allowedRoles.map((e) => e.toUpperCase()).contains(r);
  }
}

class RoleBadgeInfo {
  final String roleKey;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const RoleBadgeInfo({
    required this.roleKey,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}

class NavConfig {
  static const List<NavItem> allNavItems = [
    // --- Section 1: Core Navigation Tabs ---
    NavItem(
      id: 'dashboard',
      labelKey: 'dashboard',
      icon: Icons.dashboard_outlined,
      section: NavSection.core,
      allowedRoles: ['ALL'],
      isCoreTab: true,
      tabIndex: 0,
      screenBuilder: _buildDashboard,
    ),
    NavItem(
      id: 'members',
      labelKey: 'members',
      icon: Icons.people_alt_outlined,
      section: NavSection.core,
      allowedRoles: ['ALL'],
      isCoreTab: true,
      tabIndex: 1,
      screenBuilder: _buildMembers,
    ),
    NavItem(
      id: 'meetings',
      labelKey: 'meetings',
      icon: Icons.event_available_outlined,
      section: NavSection.core,
      allowedRoles: ['ALL'],
      isCoreTab: true,
      tabIndex: 2,
      screenBuilder: _buildMeetings,
    ),
    NavItem(
      id: 'loans',
      labelKey: 'loans',
      icon: Icons.credit_score_outlined,
      section: NavSection.core,
      allowedRoles: ['ALL'],
      isCoreTab: true,
      tabIndex: 3,
      screenBuilder: _buildLoans,
    ),
    NavItem(
      id: 'receipts',
      labelKey: 'receipts',
      icon: Icons.receipt_long_outlined,
      section: NavSection.core,
      allowedRoles: ['ALL'],
      isCoreTab: true,
      tabIndex: 4,
      screenBuilder: _buildReceipts,
    ),

    // --- Section 2: Financial & Group Operations ---
    NavItem(
      id: 'cycles',
      labelKey: 'cycles',
      icon: Icons.autorenew_rounded,
      section: NavSection.operations,
      allowedRoles: ['ALL'],
      screenBuilder: _buildCycles,
    ),
    NavItem(
      id: 'fines',
      labelKey: 'fines',
      icon: Icons.gavel_outlined,
      section: NavSection.operations,
      allowedRoles: ['ALL'],
      screenBuilder: _buildFines,
    ),
    NavItem(
      id: 'myGuarantees',
      labelKey: 'myGuarantees',
      icon: Icons.verified_user_outlined,
      section: NavSection.operations,
      allowedRoles: ['ALL'],
      screenBuilder: _buildGuarantees,
    ),
    NavItem(
      id: 'reconciliation',
      labelKey: 'reconciliation',
      icon: Icons.phone_android_rounded,
      section: NavSection.operations,
      allowedRoles: ['TREASURER', 'CHAIRPERSON', 'AUDITOR', 'PLATFORM_ADMIN'],
      screenBuilder: _buildReconciliation,
    ),

    // --- Section 3: Leadership & Oversight ---
    NavItem(
      id: 'governance',
      labelKey: 'governance',
      icon: Icons.how_to_vote_outlined,
      section: NavSection.leadership,
      allowedRoles: ['ALL'],
      screenBuilder: _buildGovernance,
    ),
    NavItem(
      id: 'reports',
      labelKey: 'reports',
      icon: Icons.bar_chart_rounded,
      section: NavSection.leadership,
      allowedRoles: [
        'CHAIRPERSON',
        'SECRETARY',
        'TREASURER',
        'AUDITOR',
        'LOAN_OFFICER',
        'PLATFORM_ADMIN',
      ],
      screenBuilder: _buildReports,
    ),
    NavItem(
      id: 'subscription',
      labelKey: 'subscription',
      icon: Icons.workspace_premium_outlined,
      section: NavSection.leadership,
      allowedRoles: ['CHAIRPERSON', 'TREASURER', 'PLATFORM_ADMIN'],
      screenBuilder: _buildSubscription,
    ),
    NavItem(
      id: 'federation',
      labelKey: 'federation',
      icon: Icons.account_balance_outlined,
      iconColor: AppColors.accent,
      section: NavSection.leadership,
      allowedRoles: ['CHAIRPERSON', 'SECRETARY', 'TREASURER', 'PLATFORM_ADMIN'],
      screenBuilder: _buildFederation,
    ),
    NavItem(
      id: 'auditLogs',
      labelKey: 'auditLogs',
      icon: Icons.security_outlined,
      section: NavSection.leadership,
      allowedRoles: ['AUDITOR', 'CHAIRPERSON', 'SECRETARY', 'PLATFORM_ADMIN'],
      screenBuilder: _buildAuditLogs,
    ),

    // --- Section 4: Intelligence ---
    NavItem(
      id: 'aiAdvisor',
      labelKey: 'aiAdvisor',
      icon: Icons.auto_awesome_rounded,
      iconColor: AppColors.accent,
      section: NavSection.intelligence,
      allowedRoles: ['ALL'],
      screenBuilder: _buildAiAdvisor,
    ),

    // --- Section 5: Preferences & System ---
    NavItem(
      id: 'settings',
      labelKey: 'settings',
      icon: Icons.settings_outlined,
      section: NavSection.system,
      allowedRoles: ['ALL'],
      screenBuilder: _buildSettings,
    ),
  ];

  static Widget _buildDashboard(BuildContext context) => const DashboardScreen();
  static Widget _buildMembers(BuildContext context) => const MembersScreen();
  static Widget _buildMeetings(BuildContext context) => const MeetingsScreen();
  static Widget _buildLoans(BuildContext context) => const LoansScreen();
  static Widget _buildReceipts(BuildContext context) => const ReceiptsScreen();
  static Widget _buildCycles(BuildContext context) => const CyclesScreen();
  static Widget _buildFines(BuildContext context) => const FinesScreen();
  static Widget _buildGuarantees(BuildContext context) => const GuaranteesScreen();
  static Widget _buildReconciliation(BuildContext context) => const ReconciliationScreen();
  static Widget _buildGovernance(BuildContext context) => const GovernanceScreen();
  static Widget _buildReports(BuildContext context) => const ReportsScreen();
  static Widget _buildSubscription(BuildContext context) => const SubscriptionScreen();
  static Widget _buildFederation(BuildContext context) => const FederationScreen();
  static Widget _buildAuditLogs(BuildContext context) => const AuditLogsScreen();
  static Widget _buildAiAdvisor(BuildContext context) => const AiAdvisorScreen();
  static Widget _buildSettings(BuildContext context) => const SettingsScreen();

  /// Filters all navigation items that the specified role has permission to access.
  static List<NavItem> getNavItemsForRole(String role) {
    return allNavItems.where((item) => item.isAllowedForRole(role)).toList();
  }

  /// Groups items permitted for [role] by their respective [NavSection].
  static Map<NavSection, List<NavItem>> getGroupedNavItemsForRole(String role) {
    final permitted = getNavItemsForRole(role);
    final grouped = <NavSection, List<NavItem>>{};

    for (final item in permitted) {
      grouped.putIfAbsent(item.section, () => []).add(item);
    }

    return grouped;
  }

  /// Returns styling and iconography for a given role badge.
  static RoleBadgeInfo getRoleBadgeInfo(String role, bool isDark) {
    final r = role.toUpperCase();
    switch (r) {
      case 'CHAIRPERSON':
        return RoleBadgeInfo(
          roleKey: 'role_CHAIRPERSON',
          icon: Icons.workspace_premium_rounded,
          color: Colors.amber.shade800,
          backgroundColor: isDark
              ? Colors.amber.shade900.withValues(alpha: 0.3)
              : Colors.amber.shade100,
        );
      case 'TREASURER':
        return RoleBadgeInfo(
          roleKey: 'role_TREASURER',
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.success,
          backgroundColor: isDark
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.success.withValues(alpha: 0.1),
        );
      case 'SECRETARY':
        return RoleBadgeInfo(
          roleKey: 'role_SECRETARY',
          icon: Icons.edit_note_rounded,
          color: Colors.blue.shade600,
          backgroundColor: isDark
              ? Colors.blue.shade900.withValues(alpha: 0.3)
              : Colors.blue.shade100,
        );
      case 'AUDITOR':
        return RoleBadgeInfo(
          roleKey: 'role_AUDITOR',
          icon: Icons.verified_rounded,
          color: Colors.purple.shade600,
          backgroundColor: isDark
              ? Colors.purple.shade900.withValues(alpha: 0.3)
              : Colors.purple.shade100,
        );
      case 'LOAN_OFFICER':
        return RoleBadgeInfo(
          roleKey: 'role_LOAN_OFFICER',
          icon: Icons.credit_score_rounded,
          color: Colors.teal.shade600,
          backgroundColor: isDark
              ? Colors.teal.shade900.withValues(alpha: 0.3)
              : Colors.teal.shade100,
        );
      case 'PLATFORM_ADMIN':
        return RoleBadgeInfo(
          roleKey: 'role_PLATFORM_ADMIN',
          icon: Icons.admin_panel_settings_rounded,
          color: Colors.deepOrange.shade600,
          backgroundColor: isDark
              ? Colors.deepOrange.shade900.withValues(alpha: 0.3)
              : Colors.deepOrange.shade100,
        );
      case 'MEMBER':
      default:
        return RoleBadgeInfo(
          roleKey: 'role_MEMBER',
          icon: Icons.person_rounded,
          color: AppColors.primary,
          backgroundColor: isDark
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.primaryLight,
        );
    }
  }
}
