import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/glass_card.dart';
import '../../common/state_views.dart';
import '../../common/themed_loader.dart';

class GuaranteesScreen extends StatefulWidget {
  const GuaranteesScreen({super.key});

  @override
  State<GuaranteesScreen> createState() => _GuaranteesScreenState();
}

class _GuaranteesScreenState extends State<GuaranteesScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupDataProvider>().loadGuarantees();
    });
  }

  Future<void> _handleResponse(String guarantorId, bool accept) async {
    setState(() => _isProcessing = true);
    try {
      await context.read<GroupDataProvider>().respondToGuarantee(guarantorId, accept);
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accept ? 'Guarantee accepted!' : 'Guarantee declined.'),
            backgroundColor: accept ? AppColors.success : AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update guarantee: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<LoanGuarantor> _getDemoGuarantees() {
    return [
      LoanGuarantor(
        id: 'g-demo-1',
        loanId: 'loan-1',
        memberName: 'Amina Rashid',
        membershipId: 'MEM-003',
        pledgeAmount: 300000,
        status: 'PENDING',
        requestedAt: DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        borrowerName: 'Amina Rashid',
        loanAmount: 600000,
      ),
      LoanGuarantor(
        id: 'g-demo-2',
        loanId: 'loan-2',
        memberName: 'Daudi Bakari',
        membershipId: 'MEM-007',
        pledgeAmount: 200000,
        status: 'APPROVED',
        requestedAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        borrowerName: 'Daudi Bakari',
        loanAmount: 400000,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupData = context.watch<GroupDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final guarantees = groupData.guarantees.isNotEmpty
        ? groupData.guarantees
        : _getDemoGuarantees();

    final pendingCount = guarantees.where((g) => g.status == 'PENDING').length;
    final totalPledged = guarantees
        .where((g) => g.status == 'APPROVED')
        .fold<double>(0, (sum, g) => sum + g.pledgeAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('myGuarantees')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => groupData.loadGuarantees(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => groupData.loadGuarantees(),
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          children: [
            // KPI Summary Cards
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.pending_actions_rounded, size: 18, color: AppColors.warning),
                            const SizedBox(width: 6),
                            Text(
                              'Pending Requests',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$pendingCount',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.security_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Total Pledged',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.currency(totalPledged),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              'Peer Guarantee Requests',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 10),

            if (groupData.isLoading && groupData.guarantees.isEmpty)
              const Center(child: ThemedLoader(message: 'Loading peer guarantees...'))
            else if (guarantees.isEmpty)
              const EmptyStateView(
                title: 'No Guarantees',
                message: 'You have not been requested to guarantee any loans yet.',
              )
            else
              ...guarantees.map((g) => _buildGuaranteeCard(g, isDark, l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuaranteeCard(LoanGuarantor g, bool isDark, AppLocalizations l10n) {
    final isPending = g.status == 'PENDING';
    final isApproved = g.status == 'APPROVED';

    Color badgeColor;
    if (isApproved) {
      badgeColor = AppColors.success;
    } else if (isPending) {
      badgeColor = AppColors.warning;
    } else {
      badgeColor = AppColors.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.person_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g.borrowerName ?? g.memberName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Member ID: ${g.membershipId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    g.status,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('pledgedAmount'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.currency(g.pledgeAmount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (g.loanAmount != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Loan Request',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.currency(g.loanAmount!),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
              ],
            ),

            if (isPending) ...[
              const SizedBox(height: 16),
              if (_isProcessing)
                const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ))
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _handleResponse(g.id, false),
                        child: Text(l10n.translate('declineGuarantee')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _handleResponse(g.id, true),
                        child: Text(l10n.translate('acceptGuarantee')),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
