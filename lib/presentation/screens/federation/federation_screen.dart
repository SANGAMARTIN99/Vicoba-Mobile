import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/glass_card.dart';
import '../../common/state_views.dart';
import '../../common/themed_loader.dart';

class FederationScreen extends StatefulWidget {
  const FederationScreen({super.key});

  @override
  State<FederationScreen> createState() => _FederationScreenState();
}

class _FederationScreenState extends State<FederationScreen> {
  Federation? _selectedFederation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final groupData = context.read<GroupDataProvider>();
    await groupData.loadFederations();
    if (groupData.federations.isNotEmpty && mounted) {
      setState(() {
        _selectedFederation = groupData.federations.first;
      });
    }
  }

  List<Federation> _getDemoFederations() {
    return [
      Federation(
        id: 'fed-1',
        name: 'Dar es Salaam Apex VICOBA Alliance',
        code: 'APEX-DSM-01',
        description: 'Cooperative umbrella uniting 45 grassroots VICOBA groups for liquidity sharing and risk mitigation.',
        totalGroups: 45,
        totalMembers: 1240,
        combinedCapital: 485000000,
        interLendingPool: 120000000,
        solvencyIndex: 94.2,
        metrics: FederationMetrics(
          totalGroups: 45,
          totalCapital: 485000000,
          totalMembers: 1240,
          averageSolvencyScore: 94.2,
          interLendingAvailable: 120000000,
          defaultRate: 1.4,
        ),
        peerGroups: [
          FederationPeerGroup(
            groupId: 'grp-01',
            groupName: 'Umoja Ni Nguvu VICOBA',
            region: 'Kinondoni, DSM',
            memberCount: 28,
            totalSavings: 42000000,
            solvencyScore: 96.5,
            riskGrade: 'AAA',
          ),
          FederationPeerGroup(
            groupId: 'grp-02',
            groupName: 'Maendeleo Women Trust',
            region: 'Ilala, DSM',
            memberCount: 35,
            totalSavings: 58000000,
            solvencyScore: 92.0,
            riskGrade: 'AA',
          ),
          FederationPeerGroup(
            groupId: 'grp-03',
            groupName: 'Tumaini Youth Microfinance',
            region: 'Ubungo, DSM',
            memberCount: 22,
            totalSavings: 28500000,
            solvencyScore: 88.5,
            riskGrade: 'A',
          ),
          FederationPeerGroup(
            groupId: 'grp-04',
            groupName: 'Kilimo Kwanza Group',
            region: 'Kigamboni, DSM',
            memberCount: 30,
            totalSavings: 36000000,
            solvencyScore: 84.0,
            riskGrade: 'BBB',
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupData = context.watch<GroupDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final federations = groupData.federations.isNotEmpty
        ? groupData.federations
        : _getDemoFederations();

    final activeFed = _selectedFederation ?? (federations.isNotEmpty ? federations.first : null);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('federation')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => groupData.loadFederations(),
          ),
        ],
      ),
      body: groupData.isLoading && groupData.federations.isEmpty
          ? const Center(child: ThemedLoader(message: 'Loading Apex Federation Network...'))
          : activeFed == null
              ? EmptyStateView(
                  title: 'No Federation',
                  message: 'This group is not currently affiliated with an Apex Federation.',
                  actionTitle: l10n.translate('affiliateGroup'),
                  onAction: () {},
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => groupData.loadFederations(),
                  child: ListView(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    children: [
                      // Federation Switcher / Header Card
                      _buildApexHeader(activeFed, federations, isDark, l10n),
                      const SizedBox(height: 20),

                      // Aggregated Network KPIs
                      _buildNetworkMetricsGrid(activeFed, isDark, l10n),
                      const SizedBox(height: 24),

                      // Inter-Lending Pool Banner
                      _buildInterLendingBanner(activeFed, isDark, l10n),
                      const SizedBox(height: 24),

                      // Peer Groups Benchmark List
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.hub_rounded, size: 20, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                l10n.translate('peerGroups'),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            '${activeFed.peerGroups.length} Groups',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...activeFed.peerGroups.map((g) => _buildPeerGroupCard(g, isDark)),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildApexHeader(
    Federation fed,
    List<Federation> allFeds,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryHover,
            const Color(0xFF1E3A8A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'APEX COOPERATIVE NETWORK',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      fed.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  fed.code,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (fed.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              fed.description,
              style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNetworkMetricsGrid(Federation fed, bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: l10n.translate('combinedCapital'),
                value: Formatters.currency(fed.combinedCapital),
                icon: Icons.monetization_on_rounded,
                accentColor: AppColors.primary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: l10n.translate('solvencyIndex'),
                value: '${fed.solvencyIndex.toStringAsFixed(1)}%',
                icon: Icons.shield_rounded,
                accentColor: AppColors.success,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'Affiliated Groups',
                value: '${fed.totalGroups}',
                icon: Icons.group_work_rounded,
                accentColor: AppColors.accent,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: 'Aggregate Members',
                value: '${fed.totalMembers}',
                icon: Icons.people_alt_rounded,
                accentColor: const Color(0xFF8B5CF6),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInterLendingBanner(Federation fed, bool isDark, AppLocalizations l10n) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.swap_horizontal_circle_rounded, color: AppColors.accent, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('interLendingPool'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.currency(fed.interLendingPool),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Liquidity buffer available for inter-group emergency loans',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerGroupCard(FederationPeerGroup group, bool isDark) {
    Color gradeColor;
    switch (group.riskGrade) {
      case 'AAA':
        gradeColor = const Color(0xFF10B981);
        break;
      case 'AA':
        gradeColor = AppColors.primary;
        break;
      case 'A':
        gradeColor = AppColors.accent;
        break;
      default:
        gradeColor = AppColors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                group.groupName.substring(0, 1),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.groupName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${group.region} • ${group.memberCount} members',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Savings: ${Formatters.currency(group.totalSavings)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: gradeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    group.riskGrade,
                    style: TextStyle(
                      color: gradeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${group.solvencyScore}% Solvency',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
