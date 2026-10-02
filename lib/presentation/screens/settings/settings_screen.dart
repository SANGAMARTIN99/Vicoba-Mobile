import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../common/glass_card.dart';
import '../audit/audit_logs_screen.dart';
import '../federation/federation_screen.dart';
import '../receipts/verify_receipt_screen.dart';
import '../reports/reports_screen.dart';
import 'security_sessions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = true;
  bool _offlineModeSync = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();

    final activeGroup = auth.activeContext;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          // Active Group Details
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.groups_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeGroup?.groupName ?? 'VicobaPlus Group',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Group Code: ${activeGroup?.groupCode ?? "VICOBA-01"}',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      Text(
                        'Role: ${activeGroup?.role ?? "MEMBER"}',
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Preferences Header
          Text(
            'Preferences',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
          const SizedBox(height: 8),

          GlassCard(
            child: Column(
              children: [
                // Language
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                  title: const Text('Language / Lugha', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(localeProvider.isSwahili ? 'Kiswahili' : 'English (US)', style: const TextStyle(fontSize: 12)),
                  trailing: DropdownButton<String>(
                    value: localeProvider.locale.languageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'sw', child: Text('Kiswahili')),
                    ],
                    onChanged: (val) {
                      if (val != null) localeProvider.setLocale(Locale(val));
                    },
                  ),
                ),
                const Divider(height: 1),

                // Theme Mode
                ListTile(
                  leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
                  title: const Text('Theme Appearance', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    themeProvider.themeMode == ThemeMode.system
                        ? 'Follow System'
                        : (themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode'),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    activeThumbColor: AppColors.primary,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Financial Statements & Apex Federation Section
          Text(
            'Financial Statements & Governance',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
          const SizedBox(height: 8),

          GlassCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
                  title: const Text('Financial Reports', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Balance sheet, income statement & cash flow', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportsScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance_rounded, color: AppColors.primary),
                  title: const Text('Apex Federation Network', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Inter-lending liquidity pool & peer group ratings', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FederationScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history_edu_rounded, color: AppColors.primary),
                  title: const Text('Audit Trail & Compliance', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Cryptographically sealed immutable event log', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuditLogsScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined, color: AppColors.primary),
                  title: const Text('Verify Digital Receipt', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Validate authenticity against ledger hash', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VerifyReceiptScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Security & Device Management Section
          Text(
            'Security & Offline Ledger',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
          const SizedBox(height: 8),

          GlassCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.devices_rounded, color: AppColors.primary),
                  title: const Text('Active Login Sessions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Manage logged-in devices and revoke unauthorized access', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecuritySessionsScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.primary),
                  title: const Text('Biometric Authentication', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Require fingerprint/face to approve loans & share-out', style: TextStyle(fontSize: 12)),
                  value: _biometricEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _biometricEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.cloud_sync_outlined, color: AppColors.primary),
                  title: const Text('Offline Village Meeting Sync', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Auto-sync encrypted ledger when mobile connection returns', style: TextStyle(fontSize: 12)),
                  value: _offlineModeSync,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _offlineModeSync = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About App
          Center(
            child: Column(
              children: [
                Text(
                  'VicobaPlus Mobile v1.0.0',
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  'Digital Community Microfinance System',
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
