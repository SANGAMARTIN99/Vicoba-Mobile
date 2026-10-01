import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../common/app_buttons.dart';
import '../../common/glass_card.dart';

class GovernanceScreen extends StatefulWidget {
  const GovernanceScreen({super.key});

  @override
  State<GovernanceScreen> createState() => _GovernanceScreenState();
}

class _GovernanceScreenState extends State<GovernanceScreen> {
  final List<_Resolution> _resolutions = [
    _Resolution(
      id: 'res-1',
      title: 'Increase Weekly Share Price to TZS 15,000',
      description:
          'Proposal to adjust the mandatory weekly minimum share unit from TZS 10,000 to TZS 15,000 starting in Q3 2026 to accelerate loan vault reserves.',
      yesVotes: 18,
      noVotes: 6,
      totalVoters: 28,
      status: 'OPEN',
      userVote: 'YES',
    ),
    _Resolution(
      id: 'res-2',
      title: 'Election of Assistant Treasurer for Mobile Money Audits',
      description:
          'Electing an assistant to help oversee weekly M-Pesa automated transaction reconciliations alongside Treasurer Amina Salum.',
      yesVotes: 24,
      noVotes: 1,
      totalVoters: 28,
      status: 'PASSED',
      userVote: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('governance')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          // Quorum Rule Banner
          GlassCard(
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              children: [
                const Icon(Icons.how_to_vote_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Democratic Rule: Constitutional changes require a 2/3 majority (minimum 19 votes) to become binding law.',
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
          const SizedBox(height: 16),

          Text(
            'Active Group Resolutions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 12),

          ..._resolutions.map((res) {
            final totalCasted = res.yesVotes + res.noVotes;
            final yesRatio = totalCasted > 0 ? res.yesVotes / totalCasted : 0.0;
            final isClosed = res.status == 'PASSED' || res.status == 'REJECTED';

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          res.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: res.status == 'OPEN' ? AppColors.accentLight : AppColors.successLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          res.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: res.status == 'OPEN' ? AppColors.accentHover : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    res.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Voting Tally Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yes: ${res.yesVotes} (${(yesRatio * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      Text(
                        'No: ${res.noVotes} (${((1 - yesRatio) * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: yesRatio,
                      minHeight: 8,
                      backgroundColor: AppColors.danger.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$totalCasted of ${res.totalVoters} members voted',
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                  ),

                  if (!isClosed) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppOutlinedButton(
                            text: 'Vote NO',
                            onPressed: () {
                              setState(() {
                                res.noVotes += 1;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vote recorded successfully!')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppPrimaryButton(
                            text: 'Vote YES',
                            onPressed: () {
                              setState(() {
                                res.yesVotes += 1;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vote recorded successfully!')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Resolution {
  final String id;
  final String title;
  final String description;
  int yesVotes;
  int noVotes;
  final int totalVoters;
  final String status;
  String? userVote;

  _Resolution({
    required this.id,
    required this.title,
    required this.description,
    required this.yesVotes,
    required this.noVotes,
    required this.totalVoters,
    required this.status,
    this.userVote,
  });
}
