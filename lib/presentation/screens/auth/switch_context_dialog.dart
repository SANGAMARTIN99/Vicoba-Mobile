import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/group_data_provider.dart';

class SwitchContextDialog extends StatelessWidget {
  const SwitchContextDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final groupData = context.read<GroupDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.roundedLg),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      title: Text(
        l10n.translate('switchGroup'),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: auth.availableContexts.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No other groups available for this account.',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: auth.availableContexts.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final ctx = auth.availableContexts[index];
                  final isSelected = ctx.groupId == auth.activeContext?.groupId;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        color: isSelected ? Colors.white : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      ctx.groupName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    subtitle: Text(
                      'Role: ${ctx.role} ${ctx.groupCode != null ? "• (${ctx.groupCode})" : ""}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: isSelected
                        ? null
                        : () async {
                            Navigator.of(context).pop();
                            await auth.switchContext(ctx.groupId);
                            groupData.loadAllData();
                          },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.translate('close')),
        ),
      ],
    );
  }
}
