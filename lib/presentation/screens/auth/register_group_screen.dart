import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/app_buttons.dart';
import '../../common/app_text_fields.dart';
import '../shell/main_shell.dart';

class RegisterGroupScreen extends StatefulWidget {
  const RegisterGroupScreen({super.key});

  @override
  State<RegisterGroupScreen> createState() => _RegisterGroupScreenState();
}

class _RegisterGroupScreenState extends State<RegisterGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _groupCodeController = TextEditingController();
  final _chairpersonNameController = TextEditingController();
  final _chairpersonPhoneController = TextEditingController();
  final _chairpersonEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupCodeController.dispose();
    _chairpersonNameController.dispose();
    _chairpersonPhoneController.dispose();
    _chairpersonEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final groupData = context.read<GroupDataProvider>();

    final success = await auth.registerTenant(
      groupName: _groupNameController.text.trim(),
      groupCode: _groupCodeController.text.trim().toUpperCase(),
      chairpersonFullName: _chairpersonNameController.text.trim(),
      chairpersonPhone: _chairpersonPhoneController.text.trim(),
      chairpersonEmail: _chairpersonEmailController.text.trim().isEmpty
          ? null
          : _chairpersonEmailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      groupData.loadAllData();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('registerNewGroup')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.translate('registerGroupDesc'),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                if (auth.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkDangerLight : AppColors.dangerLight,
                      borderRadius: AppDimensions.roundedSm,
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(color: AppColors.danger, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Group Information
                Text(
                  'Group Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 8),

                AppTextField(
                  label: l10n.translate('groupName'),
                  hint: 'e.g., Mshikamano Women VICOBA',
                  controller: _groupNameController,
                  prefixIcon: const Icon(Icons.groups_rounded, size: 20),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Group name is required';
                    }
                    return null;
                  },
                ),

                AppTextField(
                  label: l10n.translate('groupCode'),
                  hint: 'e.g., MSHIK01',
                  controller: _groupCodeController,
                  prefixIcon: const Icon(Icons.tag_rounded, size: 20),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Group code is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Chairperson Information
                Text(
                  'Founding Chairperson (Admin)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 8),

                AppTextField(
                  label: l10n.translate('leaderName'),
                  hint: 'Full Name',
                  controller: _chairpersonNameController,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Chairperson name is required';
                    }
                    return null;
                  },
                ),

                AppPhoneField(
                  label: l10n.translate('leaderPhone'),
                  controller: _chairpersonPhoneController,
                ),

                AppTextField(
                  label: l10n.translate('leaderEmail'),
                  hint: 'chairperson@example.com',
                  controller: _chairpersonEmailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                ),

                AppTextField(
                  label: l10n.translate('passwordLabel'),
                  hint: 'Create a secure password',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password is required';
                    }
                    if (val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                AppPrimaryButton(
                  text: auth.isLoading
                      ? l10n.translate('registering')
                      : l10n.translate('registerBtn'),
                  isLoading: auth.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
