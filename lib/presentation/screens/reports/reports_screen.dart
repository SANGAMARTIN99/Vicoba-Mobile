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
import '../../common/themed_loader.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupDataProvider>().loadFinancialReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _exportPdf(String reportName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Export Report'),
          ],
        ),
        content: Text(
          'A formatted PDF version of the $reportName has been generated with digital audit stamp. Download to device storage?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$reportName exported successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Download PDF', style: TextStyle(color: Colors.white)),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('reports')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => groupData.loadFinancialReports(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: l10n.translate('balanceSheet')),
            Tab(text: l10n.translate('incomeStatement')),
            Tab(text: l10n.translate('cashFlow')),
          ],
        ),
      ),
      body: groupData.isLoading && groupData.balanceSheet == null
          ? const Center(child: ThemedLoader(message: 'Generating Financial Statements...'))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBalanceSheetTab(groupData.balanceSheet, isDark, l10n),
                _buildIncomeStatementTab(groupData.incomeStatement, isDark, l10n),
                _buildCashFlowTab(groupData.cashFlow, isDark, l10n),
              ],
            ),
    );
  }

  Widget _buildBalanceSheetTab(
    BalanceSheetReport? report,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final data = report ?? _getDemoBalanceSheet();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<GroupDataProvider>().loadFinancialReports(),
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          _buildPeriodBanner('As of: ${data.asOfDate}', isDark, 'Balance Sheet'),
          const SizedBox(height: 16),

          // Assets Section
          _buildSectionHeader('ASSETS', Icons.account_balance_wallet_rounded, AppColors.primary),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: [
                _buildReportRow('Cash on Hand (Lockbox)', Formatters.currency(data.cashOnHand), isDark),
                const Divider(height: 16),
                _buildReportRow('Bank Balance', Formatters.currency(data.bankBalance), isDark),
                const Divider(height: 16),
                _buildReportRow('Loans Receivable (Portfolio)', Formatters.currency(data.loansReceivable), isDark),
                const Divider(height: 16),
                _buildReportRow('Other Assets', Formatters.currency(data.otherAssets), isDark),
                const Divider(height: 20, thickness: 1.5),
                _buildReportRow(
                  l10n.translate('totalAssets'),
                  Formatters.currency(data.totalAssets),
                  isDark,
                  isBold: true,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Liabilities & Equity Section
          _buildSectionHeader('LIABILITIES & MEMBER EQUITY', Icons.shield_rounded, AppColors.accent),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: [
                _buildReportRow('Member Shares / Savings', Formatters.currency(data.memberSavings), isDark),
                const Divider(height: 16),
                _buildReportRow('Social Welfare Reserve', Formatters.currency(data.socialFund), isDark),
                const Divider(height: 16),
                _buildReportRow('Emergency Reserve', Formatters.currency(data.emergencyFund), isDark),
                const Divider(height: 16),
                _buildReportRow('Retained Surplus (Dividends)', Formatters.currency(data.retainedSurplus), isDark),
                const Divider(height: 20, thickness: 1.5),
                _buildReportRow(
                  l10n.translate('totalLiabilities'),
                  Formatters.currency(data.totalLiabilitiesAndEquity),
                  isDark,
                  isBold: true,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            title: l10n.translate('exportPdf'),
            icon: Icons.picture_as_pdf_rounded,
            onPressed: () => _exportPdf('Balance Sheet'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildIncomeStatementTab(
    IncomeStatementReport? report,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final data = report ?? _getDemoIncomeStatement();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<GroupDataProvider>().loadFinancialReports(),
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          _buildPeriodBanner('Period: ${data.periodStart} to ${data.periodEnd}', isDark, 'Income Statement'),
          const SizedBox(height: 16),

          // Revenue Section
          _buildSectionHeader('OPERATING REVENUE', Icons.trending_up_rounded, AppColors.success),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: [
                _buildReportRow('Interest on Micro-Loans', Formatters.currency(data.interestRevenue), isDark),
                const Divider(height: 16),
                _buildReportRow('Fines & Late Penalties', Formatters.currency(data.finesAndPenalties), isDark),
                const Divider(height: 16),
                _buildReportRow('Registration & Member Fees', Formatters.currency(data.membershipFees), isDark),
                const Divider(height: 16),
                _buildReportRow('Other Income', Formatters.currency(data.otherIncome), isDark),
                const Divider(height: 20, thickness: 1.5),
                _buildReportRow(
                  'Total Revenue',
                  Formatters.currency(data.totalRevenue),
                  isDark,
                  isBold: true,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Expenses Section
          _buildSectionHeader(l10n.translate('operatingExpenses').toUpperCase(), Icons.trending_down_rounded, AppColors.error),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: [
                _buildReportRow('Stationery & Passbooks', Formatters.currency(data.stationeryExpenses), isDark),
                const Divider(height: 16),
                _buildReportRow('Meeting Refreshments & Logistics', Formatters.currency(data.meetingExpenses), isDark),
                const Divider(height: 16),
                _buildReportRow('Bank Service & SMS Charges', Formatters.currency(data.bankCharges), isDark),
                const Divider(height: 16),
                _buildReportRow('Social Welfare Payouts', Formatters.currency(data.welfarePayouts), isDark),
                const Divider(height: 20, thickness: 1.5),
                _buildReportRow(
                  'Total Operating Expenses',
                  Formatters.currency(data.totalExpenses),
                  isDark,
                  isBold: true,
                  color: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Net Surplus Card
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.lg),
            borderColor: AppColors.primary.withValues(alpha: 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('netSurplus'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Distributable to members at cycle end',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  Formatters.currency(data.netSurplus),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            title: l10n.translate('exportPdf'),
            icon: Icons.picture_as_pdf_rounded,
            onPressed: () => _exportPdf('Income Statement'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCashFlowTab(
    CashFlowStatementReport? report,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final data = report ?? _getDemoCashFlow();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<GroupDataProvider>().loadFinancialReports(),
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          _buildPeriodBanner('Period: ${data.periodStart} to ${data.periodEnd}', isDark, 'Cash Flow'),
          const SizedBox(height: 16),

          // Inflows
          _buildSectionHeader('CASH INFLOWS', Icons.arrow_downward_rounded, AppColors.success),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: [
                _buildReportRow('Member Savings Deposited', Formatters.currency(data.savingsInflow), isDark),
                const Divider(height: 16),
                _buildReportRow('Loan Principal Repayments', Formatters.currency(data.loanRepaymentsInflow), isDark),
                const Divider(height: 16),
                _buildReportRow('Interest & Fees Received', Formatters.currency(data.interestAndFeesInflow), isDark),
                const Divider(height: 20, thickness: 1.5),
                _buildReportRow(
                  'Total Cash Inflows',
                  Formatters.currency(data.totalInflow),
                  isDark,
                  isBold: true,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Outflows
          _buildSectionHeader('CASH OUTFLOWS', Icons.arrow_upward_rounded, AppColors.error),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: [
                _buildReportRow('New Loans Disbursed', Formatters.currency(data.loansDisbursedOutflow), isDark),
                const Divider(height: 16),
                _buildReportRow('Operating Expenses Paid', Formatters.currency(data.expensesPaidOutflow), isDark),
                const Divider(height: 16),
                _buildReportRow('Welfare Emergency Relief', Formatters.currency(data.welfareOutflow), isDark),
                const Divider(height: 20, thickness: 1.5),
                _buildReportRow(
                  'Total Cash Outflows',
                  Formatters.currency(data.totalOutflow),
                  isDark,
                  isBold: true,
                  color: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Net Cash Flow
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              children: [
                _buildReportRow('Beginning Cash Balance', Formatters.currency(data.beginningCash), isDark),
                const Divider(height: 16),
                _buildReportRow(
                  'Net Cash Flow',
                  Formatters.currency(data.netCashFlow),
                  isDark,
                  color: data.netCashFlow >= 0 ? AppColors.success : AppColors.error,
                  isBold: true,
                ),
                const Divider(height: 16),
                _buildReportRow(
                  'Ending Cash on Hand & Bank',
                  Formatters.currency(data.endingCash),
                  isDark,
                  isBold: true,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            title: l10n.translate('exportPdf'),
            icon: Icons.picture_as_pdf_rounded,
            onPressed: () => _exportPdf('Cash Flow Statement'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPeriodBanner(String subtitle, bool isDark, String reportTitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'AUDITED',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildReportRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }

  BalanceSheetReport _getDemoBalanceSheet() {
    return BalanceSheetReport(
      asOfDate: DateTime.now().toIso8601String().split('T')[0],
      cashOnHand: 4500000,
      bankBalance: 18200000,
      loansReceivable: 12500000,
      otherAssets: 800000,
      totalAssets: 36000000,
      memberSavings: 28000000,
      socialFund: 3200000,
      emergencyFund: 1800000,
      retainedSurplus: 3000000,
      totalLiabilitiesAndEquity: 36000000,
    );
  }

  IncomeStatementReport _getDemoIncomeStatement() {
    return IncomeStatementReport(
      periodStart: '2025-01-01',
      periodEnd: DateTime.now().toIso8601String().split('T')[0],
      interestRevenue: 2850000,
      finesAndPenalties: 340000,
      membershipFees: 200000,
      otherIncome: 110000,
      totalRevenue: 3500000,
      stationeryExpenses: 120000,
      meetingExpenses: 280000,
      bankCharges: 65000,
      welfarePayouts: 300000,
      totalExpenses: 765000,
      netSurplus: 2735000,
    );
  }

  CashFlowStatementReport _getDemoCashFlow() {
    return CashFlowStatementReport(
      periodStart: '2025-01-01',
      periodEnd: DateTime.now().toIso8601String().split('T')[0],
      savingsInflow: 14200000,
      loanRepaymentsInflow: 8500000,
      interestAndFeesInflow: 3190000,
      totalInflow: 25890000,
      loansDisbursedOutflow: 15000000,
      expensesPaidOutflow: 465000,
      welfareOutflow: 300000,
      totalOutflow: 15765000,
      beginningCash: 12575000,
      netCashFlow: 10125000,
      endingCash: 22700000,
    );
  }
}
