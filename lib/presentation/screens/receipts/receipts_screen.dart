import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/glass_card.dart';
import '../../common/state_views.dart';
import '../../common/themed_loader.dart';
import 'receipt_detail_screen.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupData = context.watch<GroupDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final receipts = groupData.receipts.isNotEmpty
        ? groupData.receipts
        : _getDemoReceipts();

    final filtered = receipts.where((r) {
      final q = _searchController.text.toLowerCase();
      final matchesQuery = r.receiptNumber.toLowerCase().contains(q) ||
          r.memberName.toLowerCase().contains(q);

      if (!matchesQuery) return false;

      if (_selectedFilter != 'ALL' && r.type != _selectedFilter) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => groupData.loadReceipts(),
        child: Column(
          children: [
            // Search & Verification Action Header
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by receipt number or member...',
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
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'All Receipts', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('SHARE_PURCHASE', 'Shares', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('SAVINGS_DEPOSIT', 'Savings', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('LOAN_REPAYMENT', 'Loan Repayments', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('FINE_PAYMENT', 'Fines', isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: groupData.isLoading && groupData.receipts.isEmpty
                  ? const Center(child: ThemedLoader(message: 'Loading ledger receipts...'))
                  : filtered.isEmpty
                      ? EmptyStateView(
                          title: 'No Receipts Found',
                          message: 'All completed contributions generate immutable cryptographic receipts.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppDimensions.lg),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final receipt = filtered[index];
                            return _buildReceiptCard(context, receipt, isDark);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, bool isDark) {
    final isSelected = _selectedFilter == key;
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
      onSelected: (_) => setState(() => _selectedFilter = key),
    );
  }

  Widget _buildReceiptCard(BuildContext context, Receipt receipt, bool isDark) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptDetailScreen(
              receiptNumber: receipt.receiptNumber,
              receiptType: receipt.type,
              amount: receipt.amount,
              memberName: receipt.memberName,
              date: receipt.createdAt,
              sha256Hash: receipt.digitalSignatureHash,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: AppDimensions.roundedSm,
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      receipt.receiptNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      Formatters.currency(receipt.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${receipt.memberName} • ${receipt.type.replaceAll('_', ' ')}',
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: AppColors.success, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.truncateHash(receipt.digitalSignatureHash),
                      style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
        ],
      ),
    );
  }

  List<Receipt> _getDemoReceipts() {
    return [
      Receipt(
        id: 'r-1',
        receiptNumber: 'REC-2026-00412',
        type: 'SHARE_PURCHASE',
        amount: 50000,
        memberName: 'Neema Mwamburi',
        createdAt: DateTime.now().toIso8601String(),
        digitalSignatureHash: 'a7b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091',
        qrPayload: 'https://vicobaplus.com/verify/REC-2026-00412',
      ),
      Receipt(
        id: 'r-2',
        receiptNumber: 'REC-2026-00411',
        type: 'SAVINGS_DEPOSIT',
        amount: 20000,
        memberName: 'Baraka Joseph',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        digitalSignatureHash: 'b8c4d5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091a7',
        qrPayload: 'https://vicobaplus.com/verify/REC-2026-00411',
      ),
      Receipt(
        id: 'r-3',
        receiptNumber: 'REC-2026-00410',
        type: 'LOAN_REPAYMENT',
        amount: 125000,
        memberName: 'Amina Salum',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        digitalSignatureHash: 'c9d5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091a7b8',
        qrPayload: 'https://vicobaplus.com/verify/REC-2026-00410',
      ),
      Receipt(
        id: 'r-4',
        receiptNumber: 'REC-2026-00409',
        type: 'FINE_PAYMENT',
        amount: 5000,
        memberName: 'Fatma Bakari',
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        digitalSignatureHash: 'd0e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091a7b8c9',
        qrPayload: 'https://vicobaplus.com/verify/REC-2026-00409',
      ),
    ];
  }
}
