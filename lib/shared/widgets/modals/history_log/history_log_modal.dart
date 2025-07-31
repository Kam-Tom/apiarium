import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../domain/models/history_log.dart';

class HistoryLogModal extends StatelessWidget {
  final HistoryLog log;

  const HistoryLogModal({
    super.key,
    required this.log,
  });

  static void show(BuildContext context, HistoryLog log) {
    showDialog(
      context: context,
      builder: (context) => HistoryLogModal(log: log),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meaningfulChanges = _getMeaningfulChanges();

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(
            _getActionIcon(log.actionType),
            color: _getActionColor(log.actionType),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${'enums.history_action.${log.actionType.name}'.tr()} - ${log.entityName}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(log.timestamp),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            if (meaningfulChanges.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'modals.history_log.changes'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: _buildChangesList(),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'modals.history_log.no_meaningful_changes'.tr(),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('modals.history_log.close'.tr()),
        ),
      ],
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return '';
    if (value is String && value.isEmpty) return '';
    if (value is List && value.isEmpty) return '';
    if (value is Map && value.isEmpty) return '';
    if (value is List) return '[${value.join(', ')}]';
    if (value is Map) return value.toString();
    if (value is DateTime) return DateFormat('MMM dd, yyyy HH:mm').format(value);
    if (value is bool) return value ? 'common.yes'.tr() : 'common.no'.tr();
    return value.toString();
  }

  bool _isValueEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String && value.isEmpty) return true;
    if (value is List && value.isEmpty) return true;
    if (value is Map && value.isEmpty) return true;
    return false;
  }

  List<Widget> _buildChangesList() {
    final filteredChanges = _filterDisplayableFields(log.changedFields);
    final meaningfulChanges = <String, dynamic>{};

    for (final entry in filteredChanges.entries) {
      final fieldName = entry.key;
      final newValue = entry.value;
      final oldValue = log.previousValues[fieldName];
      if (_isValueEmpty(oldValue) && _isValueEmpty(newValue)) {
        continue;
      }
      meaningfulChanges[fieldName] = newValue;
    }

    if (meaningfulChanges.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'modals.history_log.no_meaningful_changes'.tr(),
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ];
    }

    return meaningfulChanges.entries.map((entry) {
      final fieldName = entry.key;
      final newValue = entry.value;
      final oldValue = log.previousValues[fieldName];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatFieldName(fieldName),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 40,
                      maxHeight: 80,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _isValueEmpty(oldValue)
                        ? const SizedBox.shrink()
                        : SingleChildScrollView(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _formatValue(oldValue),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.amber.shade700,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 40,
                      maxHeight: 80,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      border: Border.all(color: Colors.amber.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _isValueEmpty(newValue)
                        ? const SizedBox.shrink()
                        : SingleChildScrollView(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _formatValue(newValue),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Map<String, dynamic> _filterDisplayableFields(Map<String, dynamic> fields) {
    const excludedFields = {
      'id', 'createdAt', 'updatedAt', 'syncStatus', 'lastSyncedAt',
      'deleted', 'serverVersion', 'entityId', 'entityType', 'actionType',
      'timestamp', 'groupId'
    };
    return Map.fromEntries(
      fields.entries.where((entry) => !excludedFields.contains(entry.key)),
    );
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  IconData _getActionIcon(HistoryActionType actionType) {
    switch (actionType) {
      case HistoryActionType.create:
        return Icons.add_circle;
      case HistoryActionType.update:
        return Icons.edit;
      case HistoryActionType.delete:
        return Icons.delete;
    }
  }

  Color _getActionColor(HistoryActionType actionType) {
    switch (actionType) {
      case HistoryActionType.create:
        return Colors.green;
      case HistoryActionType.update:
        return Colors.amber.shade700;
      case HistoryActionType.delete:
        return Colors.red;
    }
  }

  Map<String, dynamic> _getMeaningfulChanges() {
    final filteredChanges = _filterDisplayableFields(log.changedFields);
    final meaningfulChanges = <String, dynamic>{};
    
    for (final entry in filteredChanges.entries) {
      final fieldName = entry.key;
      final newValue = entry.value;
      final oldValue = log.previousValues[fieldName];
      
      // Skip if both values are empty (no meaningful change)
      if (_isValueEmpty(oldValue) && _isValueEmpty(newValue)) {
        continue;
      }
      
      meaningfulChanges[fieldName] = newValue;
    }
    
    return meaningfulChanges;
  }
}
