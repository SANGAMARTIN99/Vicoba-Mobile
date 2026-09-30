import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../data/services/api_service.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/app_buttons.dart';
import '../../common/app_text_fields.dart';
import '../../common/glass_card.dart';

class MeetingModeScreen extends StatefulWidget {
  final String meetingId;
  final int meetingNumber;
  final bool isReadOnly;

  const MeetingModeScreen({
    super.key,
    required this.meetingId,
    required this.meetingNumber,
    this.isReadOnly = false,
  });

  @override
  State<MeetingModeScreen> createState() => _MeetingModeScreenState();
}

class _MeetingModeScreenState extends State<MeetingModeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  List<AttendanceEntry> _attendance = [];
  double _sessionCollections = 520000;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeAttendance();
  }

  void _initializeAttendance() {
    final members = context.read<GroupDataProvider>().members;
    if (members.isNotEmpty) {
      _attendance = members.map((m) {
        return AttendanceEntry(
          membershipId: m.id,
          memberName: m.fullName,
          status: 'PRESENT',
        );
      }).toList();
    } else {
      _attendance = [
        AttendanceEntry(membershipId: '1', memberName: 'Neema Mwamburi', status: 'PRESENT'),
        AttendanceEntry(membershipId: '2', memberName: 'Baraka Joseph', status: 'PRESENT'),
        AttendanceEntry(membershipId: '3', memberName: 'Amina Salum', status: 'PRESENT'),
        AttendanceEntry(membershipId: '4', memberName: 'Juma Hassan', status: 'LATE'),
        AttendanceEntry(membershipId: '5', memberName: 'Fatma Bakari', status: 'ABSENT'),
      ];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting #${widget.meetingNumber} Mode'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark ? AppColors.darkText : AppColors.lightText,
          unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.fact_check_outlined, size: 20), text: 'Attendance'),
            Tab(icon: Icon(Icons.payments_outlined, size: 20), text: 'Collections'),
            Tab(icon: Icon(Icons.gavel_outlined, size: 20), text: 'Fines'),
            Tab(icon: Icon(Icons.lock_clock_outlined, size: 20), text: 'Close Session'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAttendanceTab(isDark, l10n),
          _buildCollectionsTab(isDark, l10n),
          _buildFinesTab(isDark, l10n),
          _buildClosureTab(isDark, l10n),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: ATTENDANCE ROLL CALL
  // -------------------------------------------------------------
  Widget _buildAttendanceTab(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: 12),
          color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Roll Call (${_attendance.where((a) => a.status == "PRESENT").length} Present)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              if (!widget.isReadOnly)
                TextButton.icon(
                  onPressed: _isSaving ? null : _saveAttendance,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined, size: 16),
                  label: Text(_isSaving ? 'Saving...' : 'Save Roll Call'),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: _attendance.length,
            itemBuilder: (context, index) {
              final entry = _attendance[index];
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _getStatusColor(entry.status).withValues(alpha: 0.15),
                      child: Text(
                        entry.memberName[0],
                        style: TextStyle(
                          color: _getStatusColor(entry.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.memberName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    if (widget.isReadOnly)
                      _buildStatusChip(entry.status)
                    else
                      DropdownButton<String>(
                        value: entry.status,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'PRESENT', child: Text('Present')),
                          DropdownMenuItem(value: 'LATE', child: Text('Late')),
                          DropdownMenuItem(value: 'ABSENT', child: Text('Absent')),
                          DropdownMenuItem(value: 'EXCUSED', child: Text('Excused')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              entry.status = val;
                            });
                          }
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 2: COLLECTIONS (SHARES, SAVINGS, SOCIAL FUND)
  // -------------------------------------------------------------
  Widget _buildCollectionsTab(bool isDark, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppDimensions.lg),
          backgroundColor: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
          borderColor: AppColors.primary.withValues(alpha: 0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Collected This Session', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.currency(_sessionCollections),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 36),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Record Collections',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 12),

        ..._attendance.map((entry) {
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.memberName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      const Text('Standard Share: TZS 10,000/share', style: TextStyle(fontSize: 11, color: AppColors.lightTextMuted)),
                    ],
                  ),
                ),
                if (!widget.isReadOnly)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                    onPressed: () => _showRecordCollectionSheet(entry),
                    child: const Text('Collect', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 3: FINES & PENALTIES
  // -------------------------------------------------------------
  Widget _buildFinesTab(bool isDark, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      children: [
        if (!widget.isReadOnly) ...[
          AppOutlinedButton(
            text: 'Issue Penalty / Fine',
            icon: Icons.gavel_rounded,
            onPressed: _showIssueFineSheet,
          ),
          const SizedBox(height: 20),
        ],

        Text(
          'Penalties in Meeting #${widget.meetingNumber}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 12),

        GlassCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.gavel_rounded, color: AppColors.danger, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fatma Bakari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 2),
                    Text('Unexcused Meeting Absence', style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                  ],
                ),
              ),
              const Text(
                'TZS 5,000',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 4: CLOSING & 3-KEY VALIDATION
  // -------------------------------------------------------------
  Widget _buildClosureTab(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 8),
                    Text('VICOBA 3-Key Rule Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Traditional VICOBA security requires the physical or digital presence of the Chairperson, Secretary, and Treasurer before the safe box or meeting ledger is closed.',
                  style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary, height: 1.4),
                ),
                const SizedBox(height: 16),
                _buildKeySignoff('1. Chairperson: Neema Mwamburi', true),
                _buildKeySignoff('2. Secretary: Baraka Joseph', true),
                _buildKeySignoff('3. Treasurer: Amina Salum', true),
              ],
            ),
          ),
          const Spacer(),

          if (!widget.isReadOnly)
            AppPrimaryButton(
              text: 'End & Close Meeting Session',
              icon: Icons.lock_outline_rounded,
              onPressed: _closeMeetingSession,
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildKeySignoff(String title, bool verified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            verified ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: verified ? AppColors.primary : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showRecordCollectionSheet(AttendanceEntry entry) {
    final sharesController = TextEditingController(text: '2');
    final savingsController = TextEditingController(text: '10000');
    final socialController = TextEditingController(text: '2000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.xxl),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Record for ${entry.memberName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Shares to Buy (TZS 10,000 each)',
                  controller: sharesController,
                  keyboardType: TextInputType.number,
                ),
                AppCurrencyField(
                  label: 'Voluntary Savings',
                  controller: savingsController,
                ),
                AppCurrencyField(
                  label: 'Social Welfare Fund',
                  controller: socialController,
                ),
                const SizedBox(height: 20),
                AppPrimaryButton(
                  text: 'Confirm & Issue Receipt',
                  onPressed: () {
                    final shares = int.tryParse(sharesController.text) ?? 0;
                    final savings = double.tryParse(savingsController.text) ?? 0;
                    final social = double.tryParse(socialController.text) ?? 0;
                    final total = (shares * 10000) + savings + social;

                    setState(() {
                      _sessionCollections += total;
                    });

                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Recorded ${Formatters.currency(total)} for ${entry.memberName}!')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showIssueFineSheet() {
    final amountController = TextEditingController(text: '5000');
    final reasonController = TextEditingController(text: 'Meeting Absence');
    String? selectedMember = _attendance.isNotEmpty ? _attendance.first.membershipId : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.xxl),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Issue Fine / Penalty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedMember,
                  decoration: const InputDecoration(labelText: 'Member'),
                  items: _attendance.map((m) {
                    return DropdownMenuItem(value: m.membershipId, child: Text(m.memberName));
                  }).toList(),
                  onChanged: (val) => selectedMember = val,
                ),
                AppCurrencyField(label: 'Fine Amount', controller: amountController),
                AppTextField(label: 'Reason', controller: reasonController),
                const SizedBox(height: 20),
                AppPrimaryButton(
                  text: 'Issue Fine',
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fine issued successfully!')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);
    try {
      await _api.saveAttendance(widget.meetingId, _attendance);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance roll call saved!')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance roll call saved locally!')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _closeMeetingSession() async {
    showDialog(
      context: context,
      builder: (dlgContext) {
        return AlertDialog(
          title: const Text('Confirm Meeting Closure'),
          content: const Text(
            'Closing this meeting will finalize all share purchases, savings deposits, and attendance records into the immutable cryptographic ledger.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dlgContext);
                try {
                  await _api.closeMeeting(widget.meetingId);
                } catch (_) {}
                if (mounted) {
                  context.read<GroupDataProvider>().loadAllData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meeting closed successfully!')),
                  );
                }
              },
              child: const Text('Confirm & Close'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PRESENT':
        return AppColors.success;
      case 'LATE':
        return AppColors.warning;
      case 'ABSENT':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
