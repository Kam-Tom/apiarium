import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/shared/shared.dart';

class InspectionTile extends StatelessWidget {
  final Inspection inspection;
  final VoidCallback onTap;

  const InspectionTile({
    super.key,
    required this.inspection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.search, color: Colors.blue.shade700),
        ),
        title: Text('${inspection.hiveName} - ${inspection.apiaryName ?? 'details.queen.unknown_apiary'.tr()}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy HH:mm').format(inspection.createdAt)),
            if (inspection.data != null && inspection.data!.isNotEmpty)
              Text(
                'details.queen.data_points'.tr(args: [inspection.data!.length.toString()]),
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
}
