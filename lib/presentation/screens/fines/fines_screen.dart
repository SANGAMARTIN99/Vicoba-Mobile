import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/app_buttons.dart';
import '../../common/glass_card.dart';
import '../../common/state_views.dart';

class FinesScreen extends StatefulWidget {
  const FinesScreen({super.key});

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupData = context.watch<GroupDataProvider>();
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fines = groupData.fines.isNotEmpty
        ? groupData.fines
        : _getDemoFines();

    final filtered = fines.where((f) {
      if (_selectedFilter == 'UNPAID') return f.status == 'UNPAID';
      if (_selectedFilter == 'PAID') return f.status == 'PAID';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('fines')),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
            color: isDark ? AppColors.darkBg : AppColors.lightBg,
            child: Row(
              children: [
                _buildFilterChip('ALL', 'All Penalties (${fines.length})', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('UNPAID', 'Unpaid (${fines.where((f) => f.status == "UNPAID").length})', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('PAID', 'Paid (${fines.where((f) => f.status == "PAID").length})', isDark),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateView(
                    title: 'No Fines Recorded',
                    message: 'Constitutional fines for meeting delays, absenteeism, or phone disruptions appear here.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final fine = filtered[index];
                      final isUnpaid = fine.status == 'UNPAID';

                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isUnpaid
                                            ? AppColors.danger.withValues(alpha: 0.15)
                                            : AppColors.success.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.gavel_rounded,
                                        color: isUnpaid ? AppColors.danger : AppColors.success,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      fine.memberName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.darkText : AppColors.lightText,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isUnpaid ? AppColors.dangerLight : AppColors.successLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    fine.status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isUnpaid ? AppColors.danger : AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              fine.reason,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  fine.issuedAt != null ? Formatters.date(fine.issuedAt!) : '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                ),
                                Text(
                                  Formatters.currency(fine.amount),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isUnpaid ? AppColors.danger : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            if (isUnpaid && auth.isLeader) ...[
                              const SizedBox(height: 12),
                              AppPrimaryButton(
                                text: 'Clear / Settle Fine',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Fine for ${fine.memberName} marked as PAID!')),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, bool isDark) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightBgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: BorderSide(
        color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      onSelected: (_) => setState(() => _selectedFilter = key),
    );
  }

  List<Fine> _getDemoFines() {
    return [
      Fine(
        id: 'fn-1',
        memberId: 'mem-5',
        memberName: 'Fatma Bakari',
        reason: 'Unexcused Meeting Absence (Meeting #14)',
        amount: 5000,
        status: 'UNPAID',
        issuedAt: DateTime.now().toIso8601String(),
      ),
      Fine(
        id: 'fn-2',
        memberId: 'mem-4',
        memberName: 'Juma Hassan',
        reason: 'Late arrival beyond 30 minutes',
        amount: 2000,
        status: 'PAID',
        issuedAt: DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      ),
      Fine(
        id: 'fn-3',
        memberId: 'mem-2',
        memberName: 'Baraka Joseph',
        reason: 'Phone ringing during agenda discussion',
        amount: 1000,
        status: 'PAID',
        issuedAt: DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
      ),
    ];
  }
}
