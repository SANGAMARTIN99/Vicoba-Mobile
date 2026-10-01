import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../common/app_buttons.dart';
import '../../common/app_text_fields.dart';
import '../../common/glass_card.dart';

class ReconciliationScreen extends StatefulWidget {
  const ReconciliationScreen({super.key});

  @override
  State<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends State<ReconciliationScreen> {
  final _phoneController = TextEditingController(text: '0754123456');
  final _amountController = TextEditingController(text: '20000');
  String _selectedProvider = 'MPESA';
  bool _isPrompting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _triggerStkPush() {
    setState(() => _isPrompting = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isPrompting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('M-Pesa STK Push sent! Prompt displayed on member phone.'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('reconciliation')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          // M-Pesa STK Push Card
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE11900), // Vodacom Red
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Mobile Money STK Push',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Instantly prompt a member phone for PIN entry to deposit shares or loan repayments directly into group safe account.',
                  style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                ),
                const SizedBox(height: 16),

                // Provider Selector
                Row(
                  children: [
                    _buildProviderRadio('MPESA', 'M-Pesa', const Color(0xFFE11900)),
                    const SizedBox(width: 12),
                    _buildProviderRadio('AIRTEL', 'Airtel Money', const Color(0xFFFF0000)),
                    const SizedBox(width: 12),
                    _buildProviderRadio('TIGO', 'Tigo Pesa', const Color(0xFF00377B)),
                  ],
                ),
                const SizedBox(height: 14),

                AppPhoneField(label: 'Member Phone', controller: _phoneController),
                AppCurrencyField(label: 'Amount to Collect', controller: _amountController),
                const SizedBox(height: 16),

                AppPrimaryButton(
                  text: _isPrompting ? 'Sending USSD Prompt...' : 'Send Instant STK Push',
                  isLoading: _isPrompting,
                  onPressed: _triggerStkPush,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Daily Vault Reconciliation Table
          Text(
            'Daily Vault & Mobile Reconciliation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              children: [
                _buildReconRow('Physical Cash in Safe Box', 'TZS 1,650,000', Icons.lock_clock_rounded, AppColors.primary),
                const Divider(height: 20),
                _buildReconRow('M-Pesa Till Account Balance', 'TZS 2,840,000', Icons.phone_android_rounded, const Color(0xFF10B981)),
                const Divider(height: 20),
                _buildReconRow('System Ledger Calculated Total', 'TZS 4,490,000', Icons.account_balance_rounded, AppColors.accentHover),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Reconciliation Variance',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    Text(
                      'TZS 0 (PERFECT MATCH)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProviderRadio(String key, String label, Color color) {
    final isSelected = _selectedProvider == key;
    return InkWell(
      onTap: () => setState(() => _selectedProvider = key),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : null,
          ),
        ),
      ),
    );
  }

  Widget _buildReconRow(String title, String amount, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 13)),
          ],
        ),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
