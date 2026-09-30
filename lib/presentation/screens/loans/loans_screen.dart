import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/app_buttons.dart';
import '../../common/glass_card.dart';
import '../../common/state_views.dart';
import '../../common/themed_loader.dart';
import 'apply_loan_screen.dart';
import 'guarantees_screen.dart';
import 'loan_detail_screen.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupData = context.watch<GroupDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final loans = groupData.loans.isNotEmpty
        ? groupData.loans
        : _getDemoLoans();

    final filtered = loans.where((loan) {
      if (_selectedFilter == 'ACTIVE') return loan.status == 'ACTIVE';
      if (_selectedFilter == 'PENDING') return loan.status == 'PENDING';
      if (_selectedFilter == 'REPAID') return loan.status == 'REPAID';
      return true;
    }).toList();

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => groupData.loadLoans(),
        child: Column(
          children: [
            // Filter Selector Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('ALL', 'All Loans (${loans.length})', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('ACTIVE', 'Active (${loans.where((l) => l.status == "ACTIVE").length})', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('PENDING', 'Pending Approval (${loans.where((l) => l.status == "PENDING").length})', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('REPAID', 'Fully Repaid', isDark),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.verified_user_rounded, size: 16, color: Colors.white),
                      backgroundColor: AppColors.accent,
                      label: const Text(
                        'Guarantees',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GuaranteesScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: groupData.isLoading && groupData.loans.isEmpty
                  ? const Center(child: ThemedLoader(message: 'Loading micro-loan portfolio...'))
                  : filtered.isEmpty
                      ? EmptyStateView(
                          title: 'No Loans Found',
                          message: 'No micro-loans match the selected category.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppDimensions.lg),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final loan = filtered[index];
                            return _buildLoanCard(context, loan, isDark, l10n);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApplyLoanScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: Text(l10n.translate('applyLoan')),
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, bool isDark) {
    final isSelected = _selectedFilter == filterKey;
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
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      onSelected: (val) {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
    );
  }

  Widget _buildLoanCard(BuildContext context, Loan loan, bool isDark, AppLocalizations l10n) {
    final progress = loan.principalAmount > 0
        ? ((loan.principalAmount - loan.balanceRemaining) / loan.principalAmount).clamp(0.0, 1.0)
        : 1.0;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoanDetailScreen(initialLoan: loan)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loan.memberName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              _buildStatusBadge(loan.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Principal: ${Formatters.currency(loan.principalAmount)} • Interest: ${loan.interestRate}%',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Repayment Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining Balance',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  Text(
                    Formatters.currency(loan.balanceRemaining),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
              if (loan.applicationDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Application Date',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    Text(
                      Formatters.date(loan.applicationDate!),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (loan.status == 'PENDING') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppOutlinedButton(
                    text: 'Reject',
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppPrimaryButton(
                    text: 'Approve',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Loan approved by committee!')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status) {
      case 'ACTIVE':
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        break;
      case 'PENDING':
        bg = AppColors.accentLight;
        fg = AppColors.accentHover;
        break;
      case 'REPAID':
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      default:
        bg = AppColors.dangerLight;
        fg = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  List<Loan> _getDemoLoans() {
    return [
      Loan(
        id: 'ln-1',
        memberId: 'mem-2',
        memberName: 'Baraka Joseph',
        principalAmount: 500000,
        balanceRemaining: 250000,
        interestRate: 10.0,
        durationMonths: 3,
        totalRepayable: 550000,
        status: 'ACTIVE',
        applicationDate: '2025-01-15',
      ),
      Loan(
        id: 'ln-2',
        memberId: 'mem-4',
        memberName: 'Juma Hassan',
        principalAmount: 300000,
        balanceRemaining: 150000,
        interestRate: 10.0,
        durationMonths: 2,
        totalRepayable: 330000,
        status: 'ACTIVE',
        applicationDate: '2025-02-01',
      ),
      Loan(
        id: 'ln-3',
        memberId: 'mem-5',
        memberName: 'Fatma Bakari',
        principalAmount: 400000,
        balanceRemaining: 400000,
        interestRate: 10.0,
        durationMonths: 3,
        totalRepayable: 440000,
        status: 'PENDING',
        applicationDate: '2025-03-01',
      ),
    ];
  }
}
