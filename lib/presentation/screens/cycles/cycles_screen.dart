import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/app_buttons.dart';
import '../../common/glass_card.dart';
import '../../common/stat_cards.dart';

class CyclesScreen extends StatefulWidget {
  const CyclesScreen({super.key});

  @override
  State<CyclesScreen> createState() => _CyclesScreenState();
}

class _CyclesScreenState extends State<CyclesScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupData = context.watch<GroupDataProvider>();
    final auth = context.watch<AuthProvider>();

    final totalSharesValue = groupData.metrics?.totalSharesValue ?? 12500000.0;
    final accumulatedInterest = 1450000.0;
    final accumulatedFines = 280000.0;
    final totalDivisibleProfit = accumulatedInterest + accumulatedFines;
    final totalPool = totalSharesValue + totalDivisibleProfit;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('cycles')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          // Active Cycle Progress Card
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.xl),
            borderColor: AppColors.primary.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Annual Cycle 2025/2026',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Week 14 of 52 completed • Total Pool: ${Formatters.currency(totalPool)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const LinearProgressIndicator(
                    value: 0.27,
                    minHeight: 8,
                    backgroundColor: AppColors.lightBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cycle Financial Summary Grid
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Share Capital',
                  value: Formatters.currency(totalSharesValue),
                  icon: Icons.pie_chart_rounded,
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Accumulated Profit',
                  value: Formatters.currency(totalDivisibleProfit),
                  subtitle: '+${Formatters.percent(totalDivisibleProfit / totalSharesValue * 100)} return',
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Share-Out Calculator Preview
          Text(
            'Projected Share-Out Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'At cycle completion, members receive their initial share principal plus their pro-rata share of all loan interest and penalties.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          _buildMemberProjection('Neema Mwamburi', 35, 350000, 48440, isDark),
          _buildMemberProjection('Baraka Joseph', 28, 280000, 38750, isDark),
          _buildMemberProjection('Amina Salum', 42, 420000, 58128, isDark),
          _buildMemberProjection('Juma Hassan', 20, 200000, 27680, isDark),
          _buildMemberProjection('Fatma Bakari', 18, 180000, 24912, isDark),
          const SizedBox(height: 20),

          if (auth.isLeader)
            AppPrimaryButton(
              text: 'Simulate Final Share-Out Audit',
              icon: Icons.calculate_outlined,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Simulated share-out verified against bank vault balance.')),
                );
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMemberProjection(String name, int shares, double principal, double profit, bool isDark) {
    final total = principal + profit;
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                '$shares shares • Capital: ${Formatters.currency(principal)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currency(total),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
              ),
              Text(
                '+${Formatters.currency(profit)} yield',
                style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
