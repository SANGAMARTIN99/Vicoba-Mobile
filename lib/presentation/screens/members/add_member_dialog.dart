import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/services/api_service.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/app_buttons.dart';
import '../../common/app_text_fields.dart';

class AddMemberDialog extends StatefulWidget {
  const AddMemberDialog({super.key});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'MEMBER';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ApiService();
      await api.addMember(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        role: _selectedRole,
      );

      if (mounted) {
        context.read<GroupDataProvider>().loadMembers();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.roundedLg),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      title: Text(
        l10n.translate('addMember'),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkDangerLight : AppColors.dangerLight,
                    borderRadius: AppDimensions.roundedSm,
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              AppTextField(
                label: 'Full Name',
                hint: 'e.g. Grace Makundi',
                controller: _nameController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              AppPhoneField(
                label: 'Phone Number',
                controller: _phoneController,
              ),
              AppTextField(
                label: 'Email (Optional)',
                hint: 'grace@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                    items: const [
                      DropdownMenuItem(value: 'MEMBER', child: Text('Regular Member')),
                      DropdownMenuItem(value: 'SECRETARY', child: Text('Secretary')),
                      DropdownMenuItem(value: 'TREASURER', child: Text('Treasurer')),
                      DropdownMenuItem(value: 'AUDITOR', child: Text('Auditor')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRole = val);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.translate('cancel')),
        ),
        SizedBox(
          width: 120,
          child: AppPrimaryButton(
            text: l10n.translate('save'),
            isLoading: _isLoading,
            onPressed: _handleSubmit,
          ),
        ),
      ],
    );
  }
}
