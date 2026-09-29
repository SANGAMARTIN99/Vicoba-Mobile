import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/glass_card.dart';
import '../../common/state_views.dart';
import '../../common/themed_loader.dart';
import 'add_member_dialog.dart';
import 'member_detail_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupData = context.watch<GroupDataProvider>();
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final members = groupData.members.isNotEmpty
        ? groupData.members
        : _getDemoMembers();

    final filtered = members.where((m) {
      final query = _searchController.text.toLowerCase();
      final matchesQuery = m.fullName.toLowerCase().contains(query) ||
          m.phone.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      if (_selectedFilter == 'LEADERS') {
        final r = m.role.toUpperCase();
        return r == 'CHAIRPERSON' || r == 'SECRETARY' || r == 'TREASURER';
      } else if (_selectedFilter == 'ACTIVE') {
        return m.status == 'ACTIVE';
      }
      return true;
    }).toList();

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => groupData.loadMembers(),
        child: Column(
          children: [
            // Search & Filter Header
            Container(
              padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.sm, AppDimensions.lg, AppDimensions.md),
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: l10n.translate('search'),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'All Members (${members.length})', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('LEADERS', 'Leadership Committee', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('ACTIVE', 'Active Members', isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Members List or State Views
            Expanded(
              child: groupData.isLoading && groupData.members.isEmpty
                  ? const Center(child: ThemedLoader(message: 'Loading member directory...'))
                  : filtered.isEmpty
                      ? EmptyStateView(
                          title: 'No Members Found',
                          message: _searchController.text.isEmpty
                              ? 'Your VICOBA group has no members yet.'
                              : 'No members match your search criteria.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppDimensions.lg),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final member = filtered[index];
                            return _buildMemberCard(context, member, isDark, l10n);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: auth.isLeader
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AddMemberDialog(),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_rounded),
              label: Text(l10n.translate('addMember')),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String filterKey, String label, bool isDark) {
    final isSelected = _selectedFilter == filterKey;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightBgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      onSelected: (val) {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
    );
  }

  Widget _buildMemberCard(BuildContext context, Member member, bool isDark, AppLocalizations l10n) {
    final isLeader = member.role != 'MEMBER';

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MemberDetailScreen(member: member),
          ),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isLeader
                ? AppColors.accent.withValues(alpha: isDark ? 0.3 : 0.2)
                : AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.15),
            child: Text(
              member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : 'M',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLeader ? AppColors.accentHover : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.fullName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isLeader)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.accentLightDark : AppColors.accentLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          member.role,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentHover,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatPhone(member.phone),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${member.sharesCount} shares (${Formatters.currency(member.totalSharesAmount)})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Savings: ${Formatters.currency(member.voluntarySavingsBalance)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ],
      ),
    );
  }

  List<Member> _getDemoMembers() {
    return [
      Member(
        id: 'mem-1',
        fullName: 'Neema Mwamburi',
        phone: '0754123456',
        email: 'neema@example.com',
        role: 'CHAIRPERSON',
        status: 'ACTIVE',
        sharesCount: 35,
        totalSharesAmount: 350000,
        voluntarySavingsBalance: 180000,
        activeLoanBalance: 0,
        joinedAt: '2025-01-10',
      ),
      Member(
        id: 'mem-2',
        fullName: 'Baraka Joseph',
        phone: '0714987654',
        email: 'baraka@example.com',
        role: 'SECRETARY',
        status: 'ACTIVE',
        sharesCount: 28,
        totalSharesAmount: 280000,
        voluntarySavingsBalance: 140000,
        activeLoanBalance: 250000,
        joinedAt: '2025-01-10',
      ),
      Member(
        id: 'mem-3',
        fullName: 'Amina Salum',
        phone: '0784567890',
        email: 'amina@example.com',
        role: 'TREASURER',
        status: 'ACTIVE',
        sharesCount: 42,
        totalSharesAmount: 420000,
        voluntarySavingsBalance: 290000,
        activeLoanBalance: 0,
        joinedAt: '2025-01-10',
      ),
      Member(
        id: 'mem-4',
        fullName: 'Juma Hassan',
        phone: '0762112233',
        role: 'MEMBER',
        status: 'ACTIVE',
        sharesCount: 20,
        totalSharesAmount: 200000,
        voluntarySavingsBalance: 85000,
        activeLoanBalance: 150000,
        joinedAt: '2025-02-15',
      ),
      Member(
        id: 'mem-5',
        fullName: 'Fatma Bakari',
        phone: '0755334455',
        role: 'MEMBER',
        status: 'ACTIVE',
        sharesCount: 18,
        totalSharesAmount: 180000,
        voluntarySavingsBalance: 60000,
        activeLoanBalance: 0,
        joinedAt: '2025-03-01',
      ),
    ];
  }
}
