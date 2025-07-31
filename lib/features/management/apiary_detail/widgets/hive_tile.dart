import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/shared/shared.dart';

class HiveTile extends StatelessWidget {
  final Hive hive;
  final VoidCallback onTap;

  const HiveTile({
    super.key,
    required this.hive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(),
          child: Icon(
            Icons.home,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          hive.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'apiary_details.hive_type'.tr()}: ${hive.hiveType}'),
            if (hive.queenName != null)
              Text('${'apiary_details.queen'.tr()}: ${hive.queenName}'),
            Text('${'apiary_details.status'.tr()}: ${hive.status.name.tr()}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor() {
    switch (hive.status) {
      case HiveStatus.active:
        return Colors.green;
      case HiveStatus.inactive:
        return Colors.orange;
      case HiveStatus.archived:
        return Colors.red;
    }
  }
}
