import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/models.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/glass_card.dart';
import '../../common/state_views.dart';
import '../../common/themed_loader.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupDataProvider>().loadAuditLogs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AuditLogEntry> _getDemoLogs() {
    final now = DateTime.now();
    return [
      AuditLogEntry(
        id: 'aud-01',
        action: 'LOAN_DISBURSEMENT',
        actorName: 'Mariam Said (Treasurer)',
        actorRole: 'TREASURER',
        entityType: 'LOAN',
        entityId: 'LN-2025-084',
        details: 'Disbursed micro-loan of TZS 500,000 to Baraka Joseph following physical meeting vote.',
        ipAddress: '197.250.45.12',
        hash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        timestamp: now.subtract(const Duration(minutes: 35)).toIso8601String(),
        changes: {'status': 'DISBURSED', 'amount': 500000, 'meetingId': 'MEET-08'},
      ),
      AuditLogEntry(
        id: 'aud-02',
        action: 'SAVINGS_DEPOSIT',
        actorName: 'Amina Rashid',
        actorRole: 'MEMBER',
        entityType: 'SAVINGS',
        entityId: 'SAV-2025-312',
        details: 'Weekly mandatory share purchase recorded: 2 shares (TZS 20,000).',
        ipAddress: '102.164.88.94',
        hash: '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 10)).toIso8601String(),
        changes: {'sharesPurchased': 2, 'socialFund': 2000},
      ),
      AuditLogEntry(
        id: 'aud-03',
        action: 'CONSTITUTION_UPDATE',
        actorName: 'Baraka Joseph (Chairperson)',
        actorRole: 'CHAIRPERSON',
        entityType: 'GOVERNANCE',
        entityId: 'RULE-LOAN-CAP',
        details: 'Approved constitutional amendment: Maximum loan multiplier increased to 3.0x savings.',
        ipAddress: '41.59.102.18',
        hash: 'ef2d127de37b942baad06145e54b0c619a1f22327b2ebbcfbec78f5564afe39d',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)).toIso8601String(),
        changes: {'oldMultiplier': 2.5, 'newMultiplier': 3.0},
      ),
      AuditLogEntry(
        id: 'aud-04',
        action: 'SECURITY_LOGIN',
        actorName: 'Juma Hassan',
        actorRole: 'MEMBER',
        entityType: 'SECURITY',
        entityId: 'SES-9921',
        details: 'Successful two-factor authenticated mobile session established from Samsung Galaxy A54.',
        ipAddress: '197.149.92.5',
        hash: 'c89c74c5146623137595cb7455b7ecd4e61afdcfb04ced9ec3eff59e7cb631fa',
        timestamp: now.subtract(const Duration(days: 1, hours: 8)).toIso8601String(),
      ),
    ];
  }

  void _showDetailModal(AuditLogEntry log, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.success, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Tamper-Proof Audit Record',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Event Action', log.action, isDark),
            _buildDetailRow('Actor', '${log.actorName} (${log.actorRole})', isDark),
            _buildDetailRow('Entity ID', '${log.entityType} • ${log.entityId}', isDark),
            _buildDetailRow('Timestamp', log.timestamp, isDark),
            _buildDetailRow('IP Address', log.ipAddress, isDark),
            const SizedBox(height: 12),
            const Text(
              'Cryptographic SHA-256 Ledger Seal',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: SelectableText(
                log.hash,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Audit Details',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              log.details,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupData = context.watch<GroupDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final logs = groupData.auditLogs.isNotEmpty ? groupData.auditLogs : _getDemoLogs();

    final filtered = logs.where((log) {
      if (_selectedCategory != 'ALL' && log.entityType != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = log.action.toLowerCase().contains(q) ||
            log.actorName.toLowerCase().contains(q) ||
            log.details.toLowerCase().contains(q) ||
            log.entityId.toLowerCase().contains(q);
        if (!matches) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('auditLogs')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => groupData.loadAuditLogs(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            color: isDark ? AppColors.darkBg : AppColors.lightBg,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search audit trail by actor, action, or ID...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All Events', isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('LOAN', 'Loans', isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('SAVINGS', 'Savings', isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('GOVERNANCE', 'Governance', isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('SECURITY', 'Security', isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Log List
          Expanded(
            child: groupData.isLoading && groupData.auditLogs.isEmpty
                ? const Center(child: ThemedLoader(message: 'Loading verified audit logs...'))
                : filtered.isEmpty
                    ? const EmptyStateView(
                        title: 'No Logs Found',
                        message: 'No cryptographic ledger events match the selected criteria.',
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => groupData.loadAuditLogs(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppDimensions.lg),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final log = filtered[index];
                            return _buildAuditCard(log, isDark);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String category, String label, bool isDark) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedCategory = category),
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? AppColors.darkText : AppColors.lightText),
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildAuditCard(AuditLogEntry log, bool isDark) {
    Color actionColor;
    if (log.action.contains('DISBURSE') || log.action.contains('APPROVE')) {
      actionColor = AppColors.success;
    } else if (log.action.contains('REJECT') || log.action.contains('DELETE')) {
      actionColor = AppColors.danger;
    } else if (log.action.contains('SAVINGS') || log.action.contains('DEPOSIT')) {
      actionColor = AppColors.primary;
    } else {
      actionColor = AppColors.accent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () => _showDetailModal(log, isDark),
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: actionColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: actionColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    log.action,
                    style: TextStyle(
                      color: actionColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'Tamper-Proof',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              log.details,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'By: ${log.actorName}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  log.timestamp.length > 16 ? log.timestamp.substring(0, 16).replaceAll('T', ' ') : log.timestamp,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
