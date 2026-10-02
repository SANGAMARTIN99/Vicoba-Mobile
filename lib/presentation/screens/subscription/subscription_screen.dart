import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../common/app_buttons.dart';
import '../../common/glass_card.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('subscription')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          // Current Subscription Plan Card
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.xl),
            borderColor: AppColors.primary.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CURRENT PLAN', style: TextStyle(fontSize: 10, letterSpacing: 1.0, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('Growth VICOBA Tier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('ACTIVE', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Renews on 15 Nov 2026 • TZS 25,000/month', style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary)),
                const SizedBox(height: 16),

                // Quota Progress Bars
                _buildQuotaBar('Member Accounts', 28, 50, isDark),
                const SizedBox(height: 12),
                _buildQuotaBar('Active Micro-Loans', 3, 20, isDark),
                const SizedBox(height: 12),
                _buildQuotaBar('Weekly Meetings Stored', 14, 100, isDark),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Upgrade Plan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 12),

          // Federation Tier Card
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Federation & SACCOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Text('TZS 60,000/mo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Designed for multi-branch umbrella associations, federations, and high-volume microfinance groups.',
                  style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                _buildFeatureCheck('Unlimited Member Accounts'),
                _buildFeatureCheck('Automated Multi-Group Consolidation'),
                _buildFeatureCheck('Direct Bank Vault & M-Pesa STK Gateway'),
                _buildFeatureCheck('Full AI Financial Risk Scoring & Copilot'),
                const SizedBox(height: 16),
                AppPrimaryButton(
                  text: 'Upgrade to Federation',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment gateway opened via M-Pesa!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaBar(String title, int used, int total, bool isDark) {
    final ratio = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text('$used / $total', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCheck(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
