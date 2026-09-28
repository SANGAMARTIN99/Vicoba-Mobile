import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            validator: widget.validator,
            style: TextStyle(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}

class AppPhoneField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppPhoneField({
    super.key,
    required this.label,
    this.hint = '07XXXXXXXX',
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      keyboardType: TextInputType.phone,
      prefixIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_android_rounded, size: 20, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              '+255',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 20,
              width: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ],
        ),
      ),
      validator: validator ??
          (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Phone number is required';
            }
            final clean = val.replaceAll(RegExp(r'\D'), '');
            if (clean.length < 9 || clean.length > 12) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}

class AppCurrencyField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppCurrencyField({
    super.key,
    required this.label,
    this.hint = '0',
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      keyboardType: TextInputType.number,
      prefixIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TZS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? AppColors.accent : AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 20,
              width: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ],
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
