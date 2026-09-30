import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../common/glass_card.dart';
import '../../common/stat_cards.dart';

class MemberDetailScreen extends StatelessWidget {
  final Member member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('memberDetail')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          // Header Card with Profile Info
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : 'M',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatPhone(member.phone),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              member.role,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: member.status == 'ACTIVE' ? AppColors.successLight : AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              member.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: member.status == 'ACTIVE' ? AppColors.success : AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Member Financial Position
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: l10n.translate('sharesHeld'),
                  value: '${member.sharesCount} shares',
                  subtitle: Formatters.currency(member.totalSharesAmount),
                  icon: Icons.pie_chart_rounded,
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: l10n.translate('savingsBalance'),
                  value: Formatters.currency(member.voluntarySavingsBalance),
                  icon: Icons.savings_rounded,
                  iconColor: AppColors.accentHover,
                  iconBgColor: isDark ? AppColors.accentLightDark : AppColors.accentLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StatCard(
            title: l10n.translate('loanBalance'),
            value: Formatters.currency(member.activeLoanBalance),
            icon: Icons.credit_score_rounded,
            iconColor: member.activeLoanBalance > 0 ? AppColors.danger : AppColors.success,
            iconBgColor: member.activeLoanBalance > 0
                ? (isDark ? AppColors.darkDangerLight : AppColors.dangerLight)
                : (isDark ? AppColors.darkSuccessLight : AppColors.successLight),
          ),
          const SizedBox(height: 24),

          // Passbook Statement History
          Text(
            'Member Passbook Statement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 12),

          _buildStatementItem(
            date: 'Meeting #14 • Today',
            type: 'Share Purchase (2 Shares)',
            amount: 'TZS 20,000',
            hash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
            isCredit: true,
            isDark: isDark,
          ),
          _buildStatementItem(
            date: 'Meeting #13 • 7 Days ago',
            type: 'Voluntary Savings Deposit',
            amount: 'TZS 15,000',
            hash: '7d5be52427ae41e4649b934ca495991b7852b855e3b0c44298fc1c149afbf4c8',
            isCredit: true,
            isDark: isDark,
          ),
          _buildStatementItem(
            date: 'Meeting #12 • 14 Days ago',
            type: 'Social Fund Contribution',
            amount: 'TZS 2,000',
            hash: '3ca495991b7852b855e3b0c44298fc1c149afbf4c87d5be52427ae41e4649b9',
            isCredit: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatementItem({
    required String date,
    required String type,
    required String amount,
    required String hash,
    required bool isCredit,
    required bool isDark,
  }) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              Text(
                isCredit ? '+$amount' : '-$amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? AppColors.primary : AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            type,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.lock_clock_rounded, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Hash: ${Formatters.truncateHash(hash)}',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
