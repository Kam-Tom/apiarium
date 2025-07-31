import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/shared/shared.dart';

class HistoryLogTile extends StatelessWidget {
  final HistoryLog historyLog;
  final VoidCallback onTap;

  const HistoryLogTile({
    super.key,
    required this.historyLog,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: _buildActionIcon(),
        title: Text('${'enums.history_action.${historyLog.actionType.name}'.tr()} - ${historyLog.entityName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy HH:mm').format(historyLog.timestamp)),
            if (historyLog.changedFields.isNotEmpty)
              Text(
                'details.queen.fields_changed'.tr(args: [historyLog.changedFields.length.toString()]),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.amber.shade600),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionIcon() {
    switch (historyLog.actionType) {
      case HistoryActionType.create:
        return CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.add, color: Colors.green.shade700),
        );
      case HistoryActionType.update:
        return CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(Icons.edit, color: Colors.orange.shade700),
        );
      case HistoryActionType.delete:
        return CircleAvatar(
          backgroundColor: Colors.red.shade100,
          child: Icon(Icons.delete, color: Colors.red.shade700),
        );
    }
  }
}
