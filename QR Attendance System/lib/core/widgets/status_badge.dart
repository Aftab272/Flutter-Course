import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AttendanceStatusType { present, late, absent, pendingSync, serverConfirmed }
enum StatusType { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final dynamic status;
  final String? customLabel;
  final StatusType? type;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.type,
  });

  factory StatusBadge.fromString(String statusStr, {bool isOfflineSynced = true}) {
    if (!isOfflineSynced) {
      return const StatusBadge(status: AttendanceStatusType.pendingSync);
    }
    switch (statusStr.toLowerCase()) {
      case 'present':
        return const StatusBadge(status: AttendanceStatusType.present);
      case 'late':
        return const StatusBadge(status: AttendanceStatusType.late);
      case 'absent':
        return const StatusBadge(status: AttendanceStatusType.absent);
      default:
        return const StatusBadge(status: AttendanceStatusType.serverConfirmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (type != null) {
      switch (type!) {
        case StatusType.success:
          bg = AppColors.successLight;
          fg = AppColors.successDark;
          icon = Icons.check_circle_rounded;
          break;
        case StatusType.warning:
          bg = AppColors.warningLight;
          fg = AppColors.warningDark;
          icon = Icons.access_time_filled_rounded;
          break;
        case StatusType.error:
          bg = AppColors.errorLight;
          fg = AppColors.errorDark;
          icon = Icons.cancel_rounded;
          break;
        case StatusType.info:
          bg = AppColors.skyBlueLight;
          fg = AppColors.royalBlueDark;
          icon = Icons.info_outline_rounded;
          break;
        case StatusType.neutral:
          bg = AppColors.neutralSlate.withValues(alpha: 0.15);
          fg = AppColors.textSecondary;
          icon = Icons.circle_outlined;
          break;
      }
      label = customLabel ?? (status is String ? status as String : status.toString());
    } else if (status is AttendanceStatusType) {
      switch (status as AttendanceStatusType) {
        case AttendanceStatusType.present:
          bg = AppColors.successLight;
          fg = AppColors.successDark;
          icon = Icons.check_circle_rounded;
          label = customLabel ?? 'Present';
          break;
        case AttendanceStatusType.late:
          bg = AppColors.warningLight;
          fg = AppColors.warningDark;
          icon = Icons.access_time_filled_rounded;
          label = customLabel ?? 'Late';
          break;
        case AttendanceStatusType.absent:
          bg = AppColors.errorLight;
          fg = AppColors.errorDark;
          icon = Icons.cancel_rounded;
          label = customLabel ?? 'Absent';
          break;
        case AttendanceStatusType.pendingSync:
          bg = AppColors.warningLight;
          fg = AppColors.warningDark;
          icon = Icons.cloud_upload_outlined;
          label = customLabel ?? 'Pending Sync';
          break;
        case AttendanceStatusType.serverConfirmed:
          bg = AppColors.skyBlueLight;
          fg = AppColors.royalBlueDark;
          icon = Icons.verified_rounded;
          label = customLabel ?? 'Confirmed';
          break;
      }
    } else {
      bg = AppColors.skyBlueLight;
      fg = AppColors.royalBlueDark;
      icon = Icons.verified_rounded;
      label = customLabel ?? status.toString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: fg.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
