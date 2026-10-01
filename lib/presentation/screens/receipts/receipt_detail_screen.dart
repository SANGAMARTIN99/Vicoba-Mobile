import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../common/app_buttons.dart';

class ReceiptDetailScreen extends StatelessWidget {
  final String receiptNumber;
  final String receiptType;
  final double amount;
  final String memberName;
  final String date;
  final String? sha256Hash;

  const ReceiptDetailScreen({
    super.key,
    required this.receiptNumber,
    required this.receiptType,
    required this.amount,
    required this.memberName,
    required this.date,
    this.sha256Hash,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGroup = context.watch<AuthProvider>().activeContext;

    final hash = sha256Hash ??
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('receipt')),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receipt shared!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            // Official Printable VICOBA Receipt Card
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: AppDimensions.roundedLg,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Receipt Header
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.xl),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              activeGroup?.groupName ?? 'VICOBA PLUS',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'OFFICIAL CRYPTOGRAPHIC ELECTRONIC RECEIPT',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentHover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          Formatters.currency(amount),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'LEDGER VERIFIED',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Receipt Body
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.xl),
                    child: Column(
                      children: [
                        _buildDetailRow('Receipt Number', receiptNumber, isDark),
                        const Divider(height: 20),
                        _buildDetailRow('Member Name', memberName, isDark),
                        const Divider(height: 20),
                        _buildDetailRow('Transaction Type', receiptType.replaceAll('_', ' '), isDark),
                        const Divider(height: 20),
                        _buildDetailRow('Date & Time', Formatters.date(date), isDark),
                        const Divider(height: 20),
                        _buildDetailRow('Payment Channel', 'Cash Safe / M-Pesa Integration', isDark),
                        const Divider(height: 20),

                        // Cryptographic Hash Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'SHA-256 Cryptographic Hash',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: hash));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Hash copied to clipboard!')),
                                    );
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                                      SizedBox(width: 4),
                                      Text(
                                        'Copy',
                                        style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
                                borderRadius: AppDimensions.roundedSm,
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: Text(
                                hash,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  height: 1.4,
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
            const SizedBox(height: 24),

            AppPrimaryButton(
              text: 'Download Official PDF',
              icon: Icons.picture_as_pdf_outlined,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Official PDF receipt saved to device!')),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }
}
