import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:apiarium/shared/shared.dart';

enum ActivityType { history, inspection }

class ActivityItem {
  final String id;
  final String title; 
  final String subtitle;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> details;
  final ActivityType type;
  final HistoryLog? historyLog;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
    required this.color,
    required this.details,
    required this.type,
    this.historyLog,
  });

  factory ActivityItem.fromHistoryLog(HistoryLog log) {
    Color color;
    IconData icon;
    
    switch (log.actionType) {
      case HistoryActionType.create:
        color = Colors.green;
        icon = Icons.add_circle_outline;
        break;
      case HistoryActionType.update:
        color = Colors.blue;
        icon = Icons.edit_outlined;
        break;
      case HistoryActionType.delete:
        color = Colors.red;
        icon = Icons.delete_outline;
        break;
    }

    return ActivityItem(
      id: log.id,
      title: '${'enums.history_action.${log.actionType.name}'.tr()} - ${log.entityName}',
      subtitle: log.entityName,
      timestamp: log.timestamp,
      icon: icon,
      color: color,
      details: log.changedFields,
      type: ActivityType.history,
      historyLog: log,
    );
  }

  factory ActivityItem.fromInspection(Inspection inspection) {
    return ActivityItem(
      id: inspection.id,
      title: 'Inspection completed',
      subtitle: '${inspection.hiveName} - ${inspection.apiaryName ?? 'Unknown apiary'}',
      timestamp: inspection.createdAt,
      icon: Icons.search,
      color: Colors.teal,
      details: inspection.data ?? {},
      type: ActivityType.inspection,
      historyLog: null,
    );
  }
}
