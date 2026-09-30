import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/services/api_service.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/app_buttons.dart';
import '../../common/app_text_fields.dart';
import '../../common/glass_card.dart';

class ApplyLoanScreen extends StatefulWidget {
  const ApplyLoanScreen({super.key});

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();

  int _durationMonths = 3;
  final double _interestRate = 10.0;
  String? _guarantor1Id;
  String? _guarantor2Id;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  double get _principal => double.tryParse(_amountController.text) ?? 0;
  double get _interestAmount => _principal * (_interestRate / 100);
  double get _totalRepayment => _principal + _interestAmount;
  double get _monthlyInstallment => _durationMonths > 0 ? _totalRepayment / _durationMonths : 0;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_guarantor1Id != null && _guarantor1Id == _guarantor2Id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guarantor 1 and Guarantor 2 must be different members.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      final guarantors = [_guarantor1Id, _guarantor2Id].whereType<String>().toList();

      await api.applyLoan(
        principal: _principal,
        durationMonths: _durationMonths,
        purpose: _purposeController.text.trim(),
        guarantorMembershipIds: guarantors,
      );

      if (mounted) {
        context.read<GroupDataProvider>().loadLoans();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan application submitted for committee review!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupData = context.watch<GroupDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final members = groupData.members;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('applyLoan')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Constitutional Guidelines Info Banner
              GlassCard(
                borderColor: AppColors.primary.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'VICOBA Rule: Max loan limit is 3x your total active shares balance. Two active member guarantors required.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              AppCurrencyField(
                label: 'Loan Amount',
                controller: _amountController,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please specify loan amount';
                  final num = double.tryParse(val);
                  if (num == null || num <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),

              // Duration Slider / Selector
              Text(
                'Repayment Duration: $_durationMonths Months',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              Slider(
                value: _durationMonths.toDouble(),
                min: 1,
                max: 6,
                divisions: 5,
                activeColor: AppColors.primary,
                label: '$_durationMonths Months',
                onChanged: (val) {
                  setState(() => _durationMonths = val.toInt());
                },
              ),
              const SizedBox(height: 8),

              AppTextField(
                label: 'Purpose of Loan',
                hint: 'e.g. Small business inventory expansion',
                controller: _purposeController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Purpose is required' : null,
              ),
              const SizedBox(height: 12),

              // Guarantors
              Text(
                'Select 2 Guarantors',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _guarantor1Id,
                decoration: const InputDecoration(labelText: 'Guarantor 1'),
                items: members.map((m) {
                  return DropdownMenuItem(value: m.id, child: Text(m.fullName));
                }).toList(),
                onChanged: (val) => setState(() => _guarantor1Id = val),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _guarantor2Id,
                decoration: const InputDecoration(labelText: 'Guarantor 2'),
                items: members.map((m) {
                  return DropdownMenuItem(value: m.id, child: Text(m.fullName));
                }).toList(),
                onChanged: (val) => setState(() => _guarantor2Id = val),
              ),
              const SizedBox(height: 20),

              // Repayment Summary Calculation
              GlassCard(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  children: [
                    _buildCalcRow('Principal', Formatters.currency(_principal)),
                    const SizedBox(height: 6),
                    _buildCalcRow('Interest Rate (Flat)', '$_interestRate%'),
                    const SizedBox(height: 6),
                    _buildCalcRow('Total Interest', Formatters.currency(_interestAmount)),
                    const Divider(height: 16),
                    _buildCalcRow(
                      'Total Repayment',
                      Formatters.currency(_totalRepayment),
                      isTotal: true,
                    ),
                    const SizedBox(height: 6),
                    _buildCalcRow(
                      'Monthly Installment',
                      Formatters.currency(_monthlyInstallment),
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppPrimaryButton(
                text: 'Submit Application',
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalcRow(String label, String value, {bool isTotal = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: FontWeight.bold,
            color: isHighlight
                ? AppColors.primary
                : (isTotal ? AppColors.accentHover : null),
          ),
        ),
      ],
    );
  }
}
