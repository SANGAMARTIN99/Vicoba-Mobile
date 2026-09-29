import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/app_buttons.dart';
import '../../common/app_text_fields.dart';
import '../../common/glass_card.dart';
import '../../common/stat_cards.dart';
import '../../common/state_views.dart';
import '../../common/themed_loader.dart';
import '../federation/federation_screen.dart';
import '../loans/apply_loan_screen.dart';
import '../loans/guarantees_screen.dart';
import '../meetings/meeting_mode_screen.dart';
import '../receipts/receipt_detail_screen.dart';
import '../receipts/verify_receipt_screen.dart';
import '../reconciliation/reconciliation_screen.dart';
import '../reports/reports_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupData = context.watch<GroupDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (groupData.isLoading && groupData.metrics == null) {
      return const Center(child: ThemedLoader(message: 'Loading financial overview...'));
    }

    if (groupData.error != null && groupData.metrics == null) {
      return ErrorStateView(
        message: groupData.error!,
        onRetry: () => groupData.loadAllData(),
      );
    }

    final metrics = groupData.metrics ??
        DashboardMetrics(
          totalSharesValue: 12500000,
          totalVoluntarySavings: 3840000,
          outstandingLoansBalance: 8400000,
          groupCashInVault: 1650000,
          totalMembersCount: 28,
          activeMeeting: ActiveMeetingBanner(
            id: 'm-active-1',
            meetingNumber: 14,
            meetingDate: DateTime.now().toIso8601String(),
            status: 'IN_PROGRESS',
          ),
          recentTransactions: [
            RecentTransaction(
              id: 'tx-1',
              type: 'SHARE_PURCHASE',
              amount: 50000,
              memberName: 'Neema Mwamburi',
              date: DateTime.now().toIso8601String(),
              receiptNumber: 'REC-2026-00412',
            ),
            RecentTransaction(
              id: 'tx-2',
              type: 'SAVINGS_DEPOSIT',
              amount: 20000,
              memberName: 'Baraka Joseph',
              date: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
              receiptNumber: 'REC-2026-00411',
            ),
            RecentTransaction(
              id: 'tx-3',
              type: 'LOAN_REPAYMENT',
              amount: 125000,
              memberName: 'Amina Salum',
              date: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
              receiptNumber: 'REC-2026-00410',
            ),
          ],
        );

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await groupData.loadAllData();
      },
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          // Active Meeting Alert Banner
          if (metrics.activeMeeting != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppDimensions.roundedMd,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(radius: 3, backgroundColor: Colors.black),
                            SizedBox(width: 5),
                            Text(
                              'LIVE MEETING',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        Formatters.date(metrics.activeMeeting!.meetingDate),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.translate(
                      'activeMeetingAlert',
                      {'number': metrics.activeMeeting!.meetingNumber.toString()},
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MeetingModeScreen(
                              meetingId: metrics.activeMeeting!.id,
                              meetingNumber: metrics.activeMeeting!.meetingNumber,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.meeting_room_rounded, size: 18),
                      label: Text(
                        l10n.translate('enterMeeting'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Financial Summary Grid
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: l10n.translate('vaultCash'),
                  value: Formatters.currency(metrics.groupCashInVault),
                  icon: Icons.savings_rounded,
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: l10n.translate('totalShares'),
                  value: Formatters.currency(metrics.totalSharesValue),
                  icon: Icons.pie_chart_rounded,
                  iconColor: AppColors.accentHover,
                  iconBgColor: isDark ? AppColors.accentLightDark : AppColors.accentLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: l10n.translate('voluntarySavings'),
                  value: Formatters.currency(metrics.totalVoluntarySavings),
                  icon: Icons.account_balance_rounded,
                  iconColor: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: l10n.translate('outstandingLoans'),
                  value: Formatters.currency(metrics.outstandingLoansBalance),
                  icon: Icons.credit_score_rounded,
                  iconColor: const Color(0xFF2563EB),
                  iconBgColor: isDark ? const Color(0xFF172B4D) : const Color(0xFFEFF6FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Actions Bar
          Text(
            l10n.translate('quickActions'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                QuickActionItem(
                  title: l10n.translate('buyShares'),
                  icon: Icons.add_chart_rounded,
                  color: AppColors.primary,
                  onTap: () => _showQuickShareDialog(context),
                ),
                QuickActionItem(
                  title: l10n.translate('depositSavings'),
                  icon: Icons.savings_outlined,
                  color: AppColors.accentHover,
                  onTap: () => _showQuickSavingsDialog(context),
                ),
                QuickActionItem(
                  title: l10n.translate('applyLoan'),
                  icon: Icons.monetization_on_outlined,
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ApplyLoanScreen()),
                    );
                  },
                ),
                QuickActionItem(
                  title: 'M-Pesa STK',
                  icon: Icons.phone_android_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReconciliationScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                QuickActionItem(
                  title: l10n.translate('reports'),
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportsScreen()),
                    );
                  },
                ),
                QuickActionItem(
                  title: l10n.translate('federation'),
                  icon: Icons.account_balance_rounded,
                  color: const Color(0xFFD97706),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FederationScreen()),
                    );
                  },
                ),
                QuickActionItem(
                  title: l10n.translate('verifyReceipt'),
                  icon: Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VerifyReceiptScreen()),
                    );
                  },
                ),
                QuickActionItem(
                  title: l10n.translate('myGuarantees'),
                  icon: Icons.verified_user_rounded,
                  color: const Color(0xFF059669),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GuaranteesScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Passbook Ledger Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate('recentActivity'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              Text(
                '${metrics.totalMembersCount} ${l10n.translate("activeMembers")}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (metrics.recentTransactions.isEmpty)
            EmptyStateView(
              title: 'No Recent Transactions',
              message: 'Transactions recorded in meetings will appear here with cryptographic receipts.',
            )
          else
            ...metrics.recentTransactions.map((tx) {
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                onTap: () {
                  if (tx.receiptNumber != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReceiptDetailScreen(
                          receiptNumber: tx.receiptNumber!,
                          receiptType: tx.type,
                          amount: tx.amount,
                          memberName: tx.memberName,
                          date: tx.date,
                        ),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getTransactionColor(tx.type).withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: AppDimensions.roundedSm,
                      ),
                      child: Icon(
                        _getTransactionIcon(tx.type),
                        color: _getTransactionColor(tx.type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.memberName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatTxType(tx.type)} • ${Formatters.date(tx.date)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${Formatters.currency(tx.amount)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        if (tx.receiptNumber != null)
                          Text(
                            tx.receiptNumber!,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showQuickShareDialog(BuildContext context) {
    final sharesController = TextEditingController(text: '1');
    final groupData = context.read<GroupDataProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.xxl),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Record Share Purchase',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Each share is fixed at TZS 10,000 as per group constitution.',
                  style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Number of Shares',
                  controller: sharesController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                AppPrimaryButton(
                  text: 'Submit Share Purchase',
                  onPressed: () async {
                    final count = int.tryParse(sharesController.text) ?? 1;
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Purchased $count share(s) successfully!')),
                    );
                    groupData.loadAllData();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQuickSavingsDialog(BuildContext context) {
    final amountController = TextEditingController();
    final groupData = context.read<GroupDataProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.xxl),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Deposit Voluntary Savings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Member savings accrue independently from weekly shares.',
                  style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
                ),
                const SizedBox(height: 16),
                AppCurrencyField(
                  label: 'Deposit Amount',
                  controller: amountController,
                ),
                const SizedBox(height: 20),
                AppPrimaryButton(
                  text: 'Confirm Savings Deposit',
                  onPressed: () {
                    final amt = double.tryParse(amountController.text) ?? 0;
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deposited ${Formatters.currency(amt)} into savings!')),
                    );
                    groupData.loadAllData();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'SHARE_PURCHASE':
        return AppColors.primary;
      case 'SAVINGS_DEPOSIT':
        return AppColors.accentHover;
      case 'LOAN_REPAYMENT':
        return const Color(0xFF10B981);
      case 'FINE_PAYMENT':
        return AppColors.danger;
      default:
        return const Color(0xFF2563EB);
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'SHARE_PURCHASE':
        return Icons.pie_chart_rounded;
      case 'SAVINGS_DEPOSIT':
        return Icons.savings_rounded;
      case 'LOAN_REPAYMENT':
        return Icons.check_circle_outline_rounded;
      case 'FINE_PAYMENT':
        return Icons.gavel_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  String _formatTxType(String type) {
    switch (type) {
      case 'SHARE_PURCHASE':
        return 'Share Purchase';
      case 'SAVINGS_DEPOSIT':
        return 'Savings Deposit';
      case 'LOAN_REPAYMENT':
        return 'Loan Repayment';
      case 'FINE_PAYMENT':
        return 'Fine Payment';
      default:
        return type;
    }
  }
}
