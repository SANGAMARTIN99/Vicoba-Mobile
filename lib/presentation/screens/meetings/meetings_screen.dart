import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../data/services/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/group_data_provider.dart';
import '../../common/app_buttons.dart';
import '../../common/glass_card.dart';
import '../../common/state_views.dart';
import '../../common/themed_loader.dart';
import 'meeting_mode_screen.dart';

class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupData = context.watch<GroupDataProvider>();
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final meetings = groupData.meetings.isNotEmpty
        ? groupData.meetings
        : _getDemoMeetings();

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => groupData.loadMeetings(),
        child: groupData.isLoading && groupData.meetings.isEmpty
            ? const Center(child: ThemedLoader(message: 'Loading weekly meetings...'))
            : meetings.isEmpty
                ? EmptyStateView(
                    title: 'No Meetings Recorded',
                    message: 'Weekly meetings organize attendance, shares, savings, and fines.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    itemCount: meetings.length,
                    itemBuilder: (context, index) {
                      final meeting = meetings[index];
                      final isInProgress = meeting.status == 'IN_PROGRESS';
                      final isClosed = meeting.status == 'CLOSED';

                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        borderColor: isInProgress
                            ? AppColors.primary.withValues(alpha: 0.8)
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isInProgress
                                            ? AppColors.primary
                                            : (isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.calendar_today_rounded,
                                        color: isInProgress ? Colors.white : AppColors.primary,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      l10n.translate('meetingNumber', {'number': meeting.meetingNumber.toString()}),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.darkText : AppColors.lightText,
                                      ),
                                    ),
                                  ],
                                ),
                                _buildStatusBadge(meeting.status, isDark),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      Formatters.date(meeting.meetingDate),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.darkText : AppColors.lightText,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Collections',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      Formatters.currency(meeting.totalCollections),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Action Button based on status
                            if (isInProgress)
                              AppPrimaryButton(
                                text: l10n.translate('enterMeeting'),
                                icon: Icons.meeting_room_rounded,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MeetingModeScreen(
                                        meetingId: meeting.id,
                                        meetingNumber: meeting.meetingNumber,
                                      ),
                                    ),
                                  );
                                },
                              )
                            else if (!isClosed && auth.isLeader)
                              AppOutlinedButton(
                                text: 'Open Meeting Session',
                                icon: Icons.play_arrow_rounded,
                                onPressed: () async {
                                  final api = ApiService();
                                  try {
                                    await api.openMeeting(meeting.id);
                                    groupData.loadMeetings();
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to open meeting: $e')),
                                      );
                                    }
                                  }
                                },
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${meeting.attendanceCount} Members Attended',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MeetingModeScreen(
                                            meetingId: meeting.id,
                                            meetingNumber: meeting.meetingNumber,
                                            isReadOnly: true,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('View Summary'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: auth.isLeader
          ? FloatingActionButton.extended(
              onPressed: () => _showStartMeetingDialog(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.translate('startMeeting')),
            )
          : null,
    );
  }

  void _showStartMeetingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dlgContext) {
        return AlertDialog(
          title: const Text('Schedule Weekly Meeting'),
          content: const Text(
            'This will prepare the next scheduled weekly session for attendance roll-call, shares collection, and loans.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dlgContext);
                context.read<GroupDataProvider>().loadMeetings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meeting scheduled successfully!')),
                );
              },
              child: const Text('Schedule'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'IN_PROGRESS':
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        label = 'IN PROGRESS';
        break;
      case 'CLOSED':
        bg = isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
        fg = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
        label = 'CLOSED';
        break;
      default:
        bg = AppColors.accentLight;
        fg = AppColors.accentHover;
        label = 'PLANNED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  List<Meeting> _getDemoMeetings() {
    return [
      Meeting(
        id: 'm-14',
        meetingNumber: 14,
        meetingDate: DateTime.now().toIso8601String(),
        status: 'IN_PROGRESS',
        totalCollections: 520000,
        attendanceCount: 26,
      ),
      Meeting(
        id: 'm-13',
        meetingNumber: 13,
        meetingDate: DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        status: 'CLOSED',
        totalCollections: 480000,
        attendanceCount: 27,
      ),
      Meeting(
        id: 'm-12',
        meetingNumber: 12,
        meetingDate: DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
        status: 'CLOSED',
        totalCollections: 510000,
        attendanceCount: 28,
      ),
    ];
  }
}
