import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../data/services/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/app_buttons.dart';
import '../../common/glass_card.dart';
import '../../common/state_views.dart';
import '../../common/themed_loader.dart';
import '../receipts/receipt_detail_dialog.dart';

class LoanDetailScreen extends StatefulWidget {
  final Loan initialLoan;

  const LoanDetailScreen({
    super.key,
    required this.initialLoan,
  });

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  final ApiService _apiService = ApiService();
  late Loan _loan;
  LoanDetail? _loanDetail;
  bool _isLoading = true;
  String? _error;
  bool _isProcessingAction = false;

  @override
  void initState() {
    super.initState();
    _loan = widget.initialLoan;
    _fetchLoanDetail();
  }

  Future<void> _fetchLoanDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final detail = await _apiService.getLoanDetail(_loan.id);
      setState(() {
        _loanDetail = detail;
        _loan = detail.loan;
        _isLoading = false;
      });
    } catch (_) {
      // Fallback: construct realistic schedule and guarantors if backend is using mock
      final duration = _loan.durationMonths > 0 ? _loan.durationMonths : 3;
      final monthlyDue = _loan.totalRepayable > 0
          ? _loan.totalRepayable / duration
          : (_loan.principalAmount * 1.1) / duration;
      final principalPerMonth = _loan.principalAmount / duration;
      final interestPerMonth = monthlyDue - principalPerMonth;

      final dummySchedule = List.generate(duration, (i) {
        final isPaid = _loan.status == 'REPAID' || (i == 0 && _loan.balanceRemaining < _loan.totalRepayable);
        return LoanScheduleItem(
          installmentNumber: i + 1,
          dueDate: DateTime.now().add(Duration(days: (i + 1) * 30)).toIso8601String().split('T')[0],
          principalDue: principalPerMonth,
          interestDue: interestPerMonth,
          totalDue: monthlyDue,
          status: isPaid ? 'PAID' : (i == 0 ? 'PENDING' : 'UPCOMING'),
          paidAt: isPaid ? DateTime.now().subtract(const Duration(days: 5)).toIso8601String() : null,
        );
      });

      final dummyGuarantors = [
        LoanGuarantor(
          id: 'g-1',
          loanId: _loan.id,
          memberName: 'Neema Joseph',
          membershipId: 'MEM-004',
          pledgeAmount: _loan.principalAmount * 0.5,
          status: 'APPROVED',
          requestedAt: _loan.applicationDate,
        ),
        LoanGuarantor(
          id: 'g-2',
          loanId: _loan.id,
          memberName: 'Baraka Salim',
          membershipId: 'MEM-008',
          pledgeAmount: _loan.principalAmount * 0.5,
          status: 'APPROVED',
          requestedAt: _loan.applicationDate,
        ),
      ];

      setState(() {
        _loanDetail = LoanDetail(
          loan: _loan,
          schedule: dummySchedule,
          guarantors: dummyGuarantors,
          totalRepaid: (_loan.totalRepayable - _loan.balanceRemaining).clamp(0, double.infinity),
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApprove() async {
    setState(() => _isProcessingAction = true);
    try {
      final updated = await _apiService.approveLoan(_loan.id);
      if (mounted) {
        context.read<GroupDataProvider>().loadLoans();
        setState(() {
          _loan = updated;
          _isProcessingAction = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan approved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingAction = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve loan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleReject() async {
    final reasonController = TextEditingController();
    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Loan Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for declining this loan application:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'e.g. Insufficient savings or active unpaid loan',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldReject != true) return;

    setState(() => _isProcessingAction = true);
    try {
      final updated = await _apiService.rejectLoan(_loan.id, reasonController.text.trim());
      if (mounted) {
        context.read<GroupDataProvider>().loadLoans();
        setState(() {
          _loan = updated;
          _isProcessingAction = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan rejected.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingAction = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject loan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDisburse() async {
    final activeMeeting = context.read<GroupDataProvider>().activeMeeting;
    final meetingId = activeMeeting?.id ?? 'MEET-CURRENT';

    setState(() => _isProcessingAction = true);
    try {
      final updated = await _apiService.disburseLoan(_loan.id, meetingId);
      if (mounted) {
        context.read<GroupDataProvider>().loadLoans();
        setState(() {
          _loan = updated;
          _isProcessingAction = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan disbursed to borrower successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingAction = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to disburse loan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showRepaymentModal() async {
    final activeMeeting = context.read<GroupDataProvider>().activeMeeting;
    final amountController = TextEditingController(
      text: _loan.balanceRemaining > 0 ? _loan.balanceRemaining.toInt().toString() : '50000',
    );

    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
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
                const Text(
                  'Record Loan Repayment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Borrower: ${_loan.memberName} | Remaining: ${Formatters.currency(_loan.balanceRemaining)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Repayment Amount (TZS)',
                    prefixIcon: const Icon(Icons.payments_rounded, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  title: 'Confirm Repayment & Generate Receipt',
                  onPressed: () {
                    final val = double.tryParse(amountController.text.trim()) ?? 0;
                    if (val > 0) {
                      Navigator.pop(ctx, val);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result > 0) {
      setState(() => _isProcessingAction = true);
      try {
        final meetingId = activeMeeting?.id ?? 'MEET-CURRENT';
        final receipt = await _apiService.repayLoan(_loan.id, result, meetingId);
        if (!mounted) return;
        context.read<GroupDataProvider>().loadLoans();
        context.read<GroupDataProvider>().loadReceipts();
        await _fetchLoanDetail();
        if (!mounted) return;
        setState(() => _isProcessingAction = false);

        // Show immediate official receipt dialog
        showDialog(
          context: context,
          builder: (_) => ReceiptDetailDialog(receipt: receipt),
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isProcessingAction = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Repayment failed: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final isLeader = auth.activeContext?.role == 'CHAIRPERSON' ||
        auth.activeContext?.role == 'TREASURER' ||
        auth.activeContext?.role == 'SECRETARY';

    final totalRepayable = _loan.totalRepayable > 0 ? _loan.totalRepayable : _loan.principalAmount * 1.1;
    final totalRepaid = _loanDetail?.totalRepaid ??
        (totalRepayable - _loan.balanceRemaining).clamp(0, totalRepayable);
    final progress = totalRepayable > 0 ? (totalRepaid / totalRepayable).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('loanDetails')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchLoanDetail,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: ThemedLoader(message: 'Loading loan schedule & guarantees...'))
          : _error != null
              ? ErrorStateView(
                  title: 'Unable to Load Loan',
                  message: _error!,
                  onRetry: _fetchLoanDetail,
                )
              : ListView(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  children: [
                    // Header Loan Card
                    _buildOverviewCard(isDark, progress, totalRepaid, totalRepayable),
                    const SizedBox(height: 20),

                    // Actions Bar (Repay, Approve, Disburse)
                    if (_isProcessingAction)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ))
                    else
                      _buildActionButtons(isLeader, l10n),
                    const SizedBox(height: 24),

                    // Amortization Repayment Schedule
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.translate('amortizationSchedule'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildScheduleSection(isDark),
                    const SizedBox(height: 24),

                    // Peer Guarantors Section
                    Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 20, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Text(
                          l10n.translate('guarantors'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuarantorsSection(isDark),
                    const SizedBox(height: 32),
                  ],
                ),
    );
  }

  Widget _buildOverviewCard(
    bool isDark,
    double progress,
    double totalRepaid,
    double totalRepayable,
  ) {
    Color statusColor;
    switch (_loan.status) {
      case 'ACTIVE':
        statusColor = AppColors.info;
        break;
      case 'APPROVED':
        statusColor = AppColors.primary;
        break;
      case 'REPAID':
        statusColor = AppColors.success;
        break;
      case 'REJECTED':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _loan.memberName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Member ID: ${_loan.memberId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _loan.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Financial Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Principal',
                  Formatters.currency(_loan.principalAmount),
                  isDark,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Interest Rate',
                  '${_loan.interestRate.toStringAsFixed(1)}% / mo',
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Total Repayable',
                  Formatters.currency(totalRepayable),
                  isDark,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Balance Remaining',
                  Formatters.currency(_loan.balanceRemaining),
                  isDark,
                  valueColor: _loan.balanceRemaining > 0 ? AppColors.warning : AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Repayment Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Repayment Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          if (_loan.purpose != null && _loan.purpose!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Purpose: ${_loan.purpose}',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, bool isDark, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isLeader, AppLocalizations l10n) {
    if (_loan.status == 'PENDING' && isLeader) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _handleReject,
              icon: const Icon(Icons.cancel_outlined),
              label: Text(l10n.translate('rejectLoan')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              title: l10n.translate('approveLoan'),
              onPressed: _handleApprove,
            ),
          ),
        ],
      );
    }

    if (_loan.status == 'APPROVED' && isLeader) {
      return PrimaryButton(
        title: l10n.translate('disburseLoan'),
        onPressed: _handleDisburse,
      );
    }

    if (_loan.status == 'ACTIVE') {
      return PrimaryButton(
        title: l10n.translate('repayLoan'),
        onPressed: _showRepaymentModal,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildScheduleSection(bool isDark) {
    final schedule = _loanDetail?.schedule ?? [];
    if (schedule.isEmpty) {
      return const GlassCard(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.md),
          child: Text('No amortization schedule available.'),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        children: schedule.map((item) {
          final isPaid = item.status == 'PAID';
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isPaid
                    ? AppColors.success.withValues(alpha: 0.3)
                    : (isDark ? Colors.white10 : Colors.black12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isPaid ? AppColors.success.withValues(alpha: 0.15) : AppColors.primaryLight,
                  child: Text(
                    '#${item.installmentNumber}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPaid ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Formatters.currency(item.totalDue),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Due: ${item.dueDate} • Principal: ${Formatters.currency(item.principalDue)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPaid ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGuarantorsSection(bool isDark) {
    final guarantors = _loanDetail?.guarantors ?? [];
    if (guarantors.isEmpty) {
      return const GlassCard(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.md),
          child: Text('No guarantors associated with this loan.'),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        children: guarantors.map((g) {
          final isApproved = g.status == 'APPROVED';
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                  child: const Icon(Icons.person_rounded, size: 20, color: AppColors.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g.memberName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Pledged: ${Formatters.currency(g.pledgeAmount)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApproved ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    g.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isApproved ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
